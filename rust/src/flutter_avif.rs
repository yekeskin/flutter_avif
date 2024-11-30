use allo_isolate::Isolate;
use async_std::task;
use libavif_sys::avifDecoder;
use protobuf::Message;
use std::collections::HashMap;
use std::mem;
use std::os::raw::c_uchar;
use std::slice;
use std::sync::RwLock;

use crate::models::avif_info::AvifInfo;
use crate::models::encode_request::EncodeRequest;
use crate::models::frame::Frame;
use crate::models::key_request::KeyRequest;

lazy_static::lazy_static! {
    static ref DECODERS: RwLock<HashMap<String, DecoderRef>> = {
        RwLock::new(HashMap::new())
    };
}

#[no_mangle]
pub extern "C" fn decode_single_frame_image(port: i64, ptr: *const c_uchar, len: usize) -> i64 {
    let pb_bytes = unsafe { slice::from_raw_parts(ptr, len) };
    let input = KeyRequest::parse_from_bytes(&Vec::from(pb_bytes)).unwrap();
    let isolate = Isolate::new(port);

    task::spawn(isolate.task(async move {
        let decoder = _init_memory_decoder(input.data.as_ptr(), input.data.len());
        let image = _get_next_frame(decoder);
        _dispose_decoder(decoder);

        return image.write_to_bytes().unwrap();
    }));

    return port;
}

#[no_mangle]
pub extern "C" fn init_memory_decoder(port: i64, ptr: *const c_uchar, len: usize) -> i64 {
    let pb_bytes = unsafe { slice::from_raw_parts(ptr, len) };
    let input = KeyRequest::parse_from_bytes(&Vec::from(pb_bytes)).unwrap();
    let isolate = Isolate::new(port);

    {
        let map = DECODERS.read().unwrap();
        if map.contains_key(&input.key) {
            let decoder = &map[&input.key];

            let output = decoder.info.write_to_bytes().unwrap();

            isolate.post(output);

            return port;
        }
    }

    task::spawn(isolate.task(async move {
        unsafe {
            let mut avif_bytes = input.data;
            let decoder = _init_memory_decoder(avif_bytes.as_ptr(), avif_bytes.len());

            let mut avif_info = AvifInfo::new();
            avif_info.width = 0;
            avif_info.height = 0;
            avif_info.duration = (*decoder).duration;
            avif_info.image_count = (*decoder).imageCount as u32;

            let mut map = DECODERS.write().unwrap();
            map.insert(
                input.key,
                DecoderRef {
                    decoder: decoder,
                    ptr: avif_bytes.as_mut_ptr(),
                    len: avif_bytes.len(),
                    info: avif_info.clone(),
                },
            );
            mem::forget(avif_bytes);

            return avif_info.write_to_bytes().unwrap();
        }
    }));

    return port;
}

#[no_mangle]
pub extern "C" fn reset_decoder(port: i64, ptr: *const c_uchar, len: usize) -> i64 {
    let pb_bytes = unsafe { slice::from_raw_parts(ptr, len) };
    let input = KeyRequest::parse_from_bytes(&Vec::from(pb_bytes)).unwrap();
    let isolate = Isolate::new(port);

    task::spawn(isolate.task(async move {
        {
            let map = DECODERS.read().unwrap();
            if !map.contains_key(&input.key) {
                return false;
            }

            let decoder = &map[&input.key];
            _reset_decoder(decoder.decoder);
        }

        return true;
    }));

    return port;
}

#[no_mangle]
pub extern "C" fn dispose_decoder(port: i64, ptr: *const c_uchar, len: usize) -> i64 {
    let pb_bytes = unsafe { slice::from_raw_parts(ptr, len) };
    let input = KeyRequest::parse_from_bytes(&Vec::from(pb_bytes)).unwrap();
    let isolate = Isolate::new(port);

    task::spawn(isolate.task(async move {
        {
            let mut map = DECODERS.write().unwrap();
            if !map.contains_key(&input.key) {
                return false;
            }

            let decoder = &map[&input.key];
            _dispose_decoder(decoder.decoder);

            drop(unsafe { Vec::from_raw_parts(decoder.ptr, decoder.len, decoder.len) });
            map.remove(&input.key);
        }

        return true;
    }));

    return port;
}

#[no_mangle]
pub extern "C" fn get_next_frame(port: i64, ptr: *const c_uchar, len: usize) -> i64 {
    let pb_bytes = unsafe { slice::from_raw_parts(ptr, len) };
    let input = KeyRequest::parse_from_bytes(&Vec::from(pb_bytes)).unwrap();
    let isolate = Isolate::new(port);

    task::spawn(isolate.task(async move {
        {
            let map = DECODERS.read().unwrap();
            if !map.contains_key(&input.key) {
                panic!("Decoder not found. {}", input.key);
            }

            let decoder = &map[&input.key];
            let result = _get_next_frame(decoder.decoder);

            return result.write_to_bytes().unwrap();
        }
    }));

    return port;
}

#[no_mangle]
pub extern "C" fn encode_avif(port: i64, ptr: *const c_uchar, len: usize) -> i64 {
    let pb_bytes = unsafe { slice::from_raw_parts(ptr, len) };
    let input = EncodeRequest::parse_from_bytes(&Vec::from(pb_bytes)).unwrap();
    let isolate = Isolate::new(port);

    task::spawn(isolate.task(async move {
        unsafe {
            let encoder = libavif_sys::avifEncoderCreate();
            (*encoder).maxThreads = input.max_threads;
            (*encoder).speed = input.speed;
            (*encoder).timescale = u64::from(input.timescale);
            (*encoder).minQuantizer = input.min_quantizer;
            (*encoder).maxQuantizer = input.max_quantizer;
            (*encoder).minQuantizerAlpha = input.min_quantizer_alpha;
            (*encoder).maxQuantizerAlpha = input.max_quantizer_alpha;

            let image_sequence = input.image_list;

            for frame in image_sequence.iter() {
                let image = libavif_sys::avifImageCreate(
                    input.width,
                    input.height,
                    8,
                    libavif_sys::AVIF_PIXEL_FORMAT_YUV444,
                );
                libavif_sys::avifImageAllocatePlanes(image, libavif_sys::AVIF_PLANES_YUV);

                let mut rgb = libavif_sys::avifRGBImage::default();
                let raw_rgb = &mut rgb as *mut libavif_sys::avifRGBImage;
                libavif_sys::avifRGBImageSetDefaults(raw_rgb, image);
                rgb.format = libavif_sys::AVIF_RGB_FORMAT_RGBA;
                rgb.depth = 8;
                libavif_sys::avifRGBImageAllocatePixels(raw_rgb);

                std::ptr::copy(
                    frame.data.as_ptr(),
                    rgb.pixels,
                    (rgb.rowBytes * (*image).height) as usize,
                );

                if input.exif_data.len() > 0 {
                    libavif_sys::avifImageSetMetadataExif(
                        image,
                        input.exif_data.as_ptr(),
                        input.exif_data.len(),
                    );
                }

                let conversion_result = libavif_sys::avifImageRGBToYUV(image, &rgb);
                if conversion_result != libavif_sys::AVIF_RESULT_OK {
                    libavif_sys::avifImageDestroy(image);
                    libavif_sys::avifEncoderDestroy(encoder);
                    libavif_sys::avifRGBImageFreePixels(raw_rgb);
                    panic!("yuv_to_rgb error {}", conversion_result);
                }
                let add_result = libavif_sys::avifEncoderAddImage(
                    encoder,
                    image,
                    u64::from(frame.duration_in_timescale),
                    libavif_sys::AVIF_ADD_IMAGE_FLAG_NONE,
                );
                if add_result != libavif_sys::AVIF_RESULT_OK {
                    libavif_sys::avifImageDestroy(image);
                    libavif_sys::avifEncoderDestroy(encoder);
                    libavif_sys::avifRGBImageFreePixels(raw_rgb);
                    panic!("add_image error {}", add_result);
                }
                libavif_sys::avifImageDestroy(image);
                libavif_sys::avifRGBImageFreePixels(raw_rgb);
            }

            let mut s = ::std::mem::MaybeUninit::<u8>::uninit();
            let mut avif_output = libavif_sys::avifRWData {
                data: s.as_mut_ptr(),
                size: 0,
            };
            let raw_avif_output = &mut avif_output as *mut libavif_sys::avifRWData;
            let finish_result = libavif_sys::avifEncoderFinish(encoder, raw_avif_output);
            if finish_result != libavif_sys::AVIF_RESULT_OK {
                libavif_sys::avifRWDataFree(raw_avif_output);
                libavif_sys::avifEncoderDestroy(encoder);
                panic!("avif_output error {}", finish_result);
            }
            let output_data = slice::from_raw_parts(avif_output.data, avif_output.size).to_vec();
            libavif_sys::avifRWDataFree(raw_avif_output);
            libavif_sys::avifEncoderDestroy(encoder);

            return output_data;
        }
    }));

    return port;
}

fn _init_memory_decoder(ptr: *const u8, len: usize) -> *mut avifDecoder {
    unsafe {
        let decoder = libavif_sys::avifDecoderCreate();

        let set_memory_result = libavif_sys::avifDecoderSetIOMemory(decoder, ptr, len);
        if set_memory_result != libavif_sys::AVIF_RESULT_OK {
            libavif_sys::avifDecoderDestroy(decoder);
            panic!("Couldn't decode the image. Code: {}", set_memory_result);
        }

        let parse_result = libavif_sys::avifDecoderParse(decoder);
        if !(parse_result == libavif_sys::AVIF_RESULT_OK
            || parse_result == libavif_sys::AVIF_RESULT_BMFF_PARSE_FAILED)
        {
            libavif_sys::avifDecoderDestroy(decoder);
            panic!("Couldn't decode the image. Code: {}", parse_result);
        }

        return decoder;
    }
}

fn _dispose_decoder(decoder: *mut libavif_sys::avifDecoder) -> Frame {
    unsafe {
        libavif_sys::avifDecoderDestroy(decoder);
    }

    let mut frame = Frame::new();
    frame.data = Vec::new();
    frame.duration = 0.0;
    frame.width = 0;
    frame.height = 0;

    return frame;
}

fn _reset_decoder(decoder: *mut libavif_sys::avifDecoder) -> Frame {
    unsafe {
        libavif_sys::avifDecoderReset(decoder);
    }

    let mut frame = Frame::new();
    frame.data = Vec::new();
    frame.duration = 0.0;
    frame.width = 0;
    frame.height = 0;

    return frame;
}

fn _get_next_frame(decoder: *mut libavif_sys::avifDecoder) -> Frame {
    unsafe {
        let mut decode_result = libavif_sys::avifDecoderNextImage(decoder);
        if decode_result == libavif_sys::AVIF_RESULT_NO_IMAGES_REMAINING {
            libavif_sys::avifDecoderReset(decoder);
            decode_result = libavif_sys::avifDecoderNextImage(decoder);
        }

        if decode_result != libavif_sys::AVIF_RESULT_OK {
            panic!("decode error {}", decode_result);
        }

        let mut rgb = libavif_sys::avifRGBImage::default();
        let raw_rgb = &mut rgb as *mut libavif_sys::avifRGBImage;

        libavif_sys::avifRGBImageSetDefaults(raw_rgb, (*decoder).image);
        rgb.format = libavif_sys::AVIF_RGB_FORMAT_RGBA;
        rgb.depth = 8;
        rgb.alphaPremultiplied = libavif_sys::AVIF_TRUE as i32;
        libavif_sys::avifRGBImageAllocatePixels(raw_rgb);
        let conversion_result = libavif_sys::avifImageYUVToRGB((*decoder).image, raw_rgb);
        if conversion_result != libavif_sys::AVIF_RESULT_OK {
            panic!("yuv_to_rgb error {}", conversion_result);
        }

        let size = rgb.rowBytes * (*(*decoder).image).height;
        let data = slice::from_raw_parts(rgb.pixels, size as usize).to_vec();
        libavif_sys::avifRGBImageFreePixels(raw_rgb);

        let mut frame = Frame::new();
        frame.data = data;
        frame.duration = (*decoder).imageTiming.duration;
        frame.width = (*(*decoder).image).width;
        frame.height = (*(*decoder).image).height;

        return frame;
    }
}

struct DecoderRef {
    decoder: *mut avifDecoder,
    ptr: *mut u8,
    len: usize,
    info: AvifInfo,
}

unsafe impl Send for DecoderRef {}
unsafe impl Sync for DecoderRef {}
