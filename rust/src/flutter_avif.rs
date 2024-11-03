use std::collections::HashMap;
use std::mem;
use std::os::raw::c_uchar;
use std::slice;
use std::sync::mpsc;
use std::sync::mpsc::Receiver;
use std::sync::mpsc::Sender;
use std::sync::RwLock;
use std::thread;

use protobuf::Message;

use crate::models::avif_info::AvifInfo;
use crate::models::encode_request::EncodeRequest;
use crate::models::frame::Frame;
use crate::models::key_request::KeyRequest;

lazy_static::lazy_static! {
    static ref DECODERS: RwLock<HashMap<String, Decoder>> = {
        RwLock::new(HashMap::new())
    };
}

#[no_mangle]
pub extern "C" fn decode_single_frame_image(ptr: *const c_uchar, len: usize) -> DartData {
    let pb_bytes = unsafe { slice::from_raw_parts(ptr, len) };
    let input = KeyRequest::parse_from_bytes(&Vec::from(pb_bytes)).unwrap();

    unsafe {
        let decoder = libavif_sys::avifDecoderCreate();

        let set_memory_result =
            libavif_sys::avifDecoderSetIOMemory(decoder, input.data.as_ptr(), input.data.len());
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

        let image = _get_next_frame(decoder);
        libavif_sys::avifDecoderDestroy(decoder);

        let mut output = image.write_to_bytes().unwrap();
        let data = DartData {
            ptr: output.as_mut_ptr(),
            len: output.len() as i32,
        };
        mem::forget(output);

        return data;
    }
}

#[no_mangle]
pub extern "C" fn init_memory_decoder(ptr: *const c_uchar, len: usize) -> DartData {
    let pb_bytes = unsafe { slice::from_raw_parts(ptr, len) };
    let input = KeyRequest::parse_from_bytes(&Vec::from(pb_bytes)).unwrap();

    {
        let map = DECODERS.read().unwrap();
        if map.contains_key(&input.key) {
            let decoder = &map[&input.key];

            let mut output = decoder.info.write_to_bytes().unwrap();
            let data = DartData {
                ptr: output.as_mut_ptr(),
                len: output.len() as i32,
            };
            mem::forget(output);

            return data;
        }
    }

    let (decoder_request_tx, decoder_request_rx): (
        Sender<DecoderCommand>,
        Receiver<DecoderCommand>,
    ) = mpsc::channel();
    let (decoder_response_tx, decoder_response_rx): (Sender<Frame>, Receiver<Frame>) =
        mpsc::channel();
    let (decoder_info_tx, decoder_info_rx): (Sender<AvifInfo>, Receiver<AvifInfo>) =
        mpsc::channel();

    let avif_bytes = input.data;

    thread::spawn(move || unsafe {
        let decoder = libavif_sys::avifDecoderCreate();

        let set_memory_result =
            libavif_sys::avifDecoderSetIOMemory(decoder, avif_bytes.as_ptr(), avif_bytes.len());
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

        let mut avif_info = AvifInfo::new();
        avif_info.width = 0;
        avif_info.height = 0;
        avif_info.duration = (*decoder).duration;
        avif_info.imagecount = (*decoder).imageCount as u32;

        match decoder_info_tx.send(avif_info) {
            Ok(result) => result,
            Err(e) => panic!("Decoder connection lost. {}", e),
        };

        loop {
            let request = decoder_request_rx.recv().unwrap();
            let response = match request {
                DecoderCommand::GetNextFrame => _get_next_frame(decoder),
                DecoderCommand::Reset => _reset_decoder(decoder),
                DecoderCommand::Dispose => _dispose_decoder(decoder),
            };
            match decoder_response_tx.send(response) {
                Ok(result) => result,
                Err(e) => panic!("Decoder connection lost. {}", e),
            };

            match request {
                DecoderCommand::Dispose => break,
                _ => {}
            };
        }
    });

    let avif_info = match decoder_info_rx.recv() {
        Ok(result) => result,
        Err(e) => panic!("Couldn't read avif info. Code: {}", e),
    };

    {
        let mut map = DECODERS.write().unwrap();
        map.insert(
            input.key,
            Decoder {
                request_tx: decoder_request_tx,
                response_rx: decoder_response_rx,
                info: avif_info.clone(),
            },
        );
    }

    let mut output = avif_info.write_to_bytes().unwrap();
    let data = DartData {
        ptr: output.as_mut_ptr(),
        len: output.len() as i32,
    };
    mem::forget(output);

    return data;
}

#[no_mangle]
pub extern "C" fn reset_decoder(ptr: *const c_uchar, len: usize) -> bool {
    let pb_bytes = unsafe { slice::from_raw_parts(ptr, len) };
    let input = KeyRequest::parse_from_bytes(&Vec::from(pb_bytes)).unwrap();

    let map = DECODERS.read().unwrap();
    if !map.contains_key(&input.key) {
        return false;
    }

    let decoder = &map[&input.key];
    match decoder.request_tx.send(DecoderCommand::Reset) {
        Ok(result) => result,
        Err(e) => panic!("Decoder connection lost. {}", e),
    };
    decoder.response_rx.recv().unwrap();
    return true;
}

#[no_mangle]
pub extern "C" fn dispose_decoder(ptr: *const c_uchar, len: usize) -> bool {
    let pb_bytes = unsafe { slice::from_raw_parts(ptr, len) };
    let input = KeyRequest::parse_from_bytes(&Vec::from(pb_bytes)).unwrap();

    let mut map = DECODERS.write().unwrap();
    if !map.contains_key(&input.key) {
        return false;
    }

    let decoder = &map[&input.key];
    match decoder.request_tx.send(DecoderCommand::Dispose) {
        Ok(result) => result,
        Err(e) => panic!("Decoder connection lost. {}", e),
    };
    decoder.response_rx.recv().unwrap();
    map.remove(&input.key);
    return true;
}

#[no_mangle]
pub extern "C" fn get_next_frame(ptr: *const c_uchar, len: usize) -> DartData {
    let pb_bytes = unsafe { slice::from_raw_parts(ptr, len) };
    let input = KeyRequest::parse_from_bytes(&Vec::from(pb_bytes)).unwrap();

    let map = DECODERS.read().unwrap();
    if !map.contains_key(&input.key) {
        panic!("Decoder not found. {}", input.key);
    }

    let decoder = &map[&input.key];
    match decoder.request_tx.send(DecoderCommand::GetNextFrame) {
        Ok(result) => result,
        Err(e) => panic!("Decoder connection lost. {}", e),
    };
    let result = decoder.response_rx.recv().unwrap();
    let mut output = result.write_to_bytes().unwrap();
    let data = DartData {
        ptr: output.as_mut_ptr(),
        len: output.len() as i32,
    };
    mem::forget(output);

    return data;
}

#[no_mangle]
pub extern "C" fn encode_avif(ptr: *const c_uchar, len: usize) -> DartData {
    let pb_bytes = unsafe { slice::from_raw_parts(ptr, len) };
    let input = EncodeRequest::parse_from_bytes(&Vec::from(pb_bytes)).unwrap();

    unsafe {
        let encoder = libavif_sys::avifEncoderCreate();
        (*encoder).maxThreads = input.maxthreads;
        (*encoder).speed = input.speed;
        (*encoder).timescale = u64::from(input.timescale);
        (*encoder).minQuantizer = input.minquantizer;
        (*encoder).maxQuantizer = input.maxquantizer;
        (*encoder).minQuantizerAlpha = input.minquantizeralpha;
        (*encoder).maxQuantizerAlpha = input.maxquantizeralpha;

        let image_sequence = input.imagelist;

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

            if input.exifdata.len() > 0 {
                libavif_sys::avifImageSetMetadataExif(
                    image,
                    input.exifdata.as_ptr(),
                    input.exifdata.len(),
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
                u64::from(frame.durationintimescale),
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
        let mut output_data = slice::from_raw_parts(avif_output.data, avif_output.size).to_vec();
        libavif_sys::avifRWDataFree(raw_avif_output);
        libavif_sys::avifEncoderDestroy(encoder);

        let data = DartData {
            ptr: output_data.as_mut_ptr(),
            len: output_data.len() as i32,
        };
        mem::forget(output_data);

        return data;
    }
}

#[no_mangle]
pub unsafe extern "C" fn free_dart_data(data: DartData) {
    drop(Vec::from_raw_parts(
        data.ptr,
        data.len as usize,
        data.len as usize,
    ));
    drop(data);
}

fn _dispose_decoder(decoder: *mut libavif_sys::avifDecoder) -> Frame {
    unsafe {
        libavif_sys::avifDecoderDestroy(decoder);

        let mut frame = Frame::new();
        frame.data = Vec::new();
        frame.duration = 0.0;
        frame.width = 0;
        frame.height = 0;

        return frame;
    }
}

fn _reset_decoder(decoder: *mut libavif_sys::avifDecoder) -> Frame {
    unsafe {
        libavif_sys::avifDecoderReset(decoder);

        let mut frame = Frame::new();
        frame.data = Vec::new();
        frame.duration = 0.0;
        frame.width = 0;
        frame.height = 0;

        return frame;
    }
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

struct Decoder {
    request_tx: Sender<DecoderCommand>,
    response_rx: Receiver<Frame>,
    info: AvifInfo,
}

unsafe impl Send for Decoder {}
unsafe impl Sync for Decoder {}

enum DecoderCommand {
    GetNextFrame,
    Reset,
    Dispose,
}

#[repr(C)]
pub struct DartData {
    ptr: *mut u8,
    len: i32,
}
