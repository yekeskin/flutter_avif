use std::collections::HashMap;
use std::slice;
use std::sync::mpsc;
use std::sync::mpsc::Receiver;
use std::sync::mpsc::Sender;
use std::sync::RwLock;
use std::thread;

lazy_static::lazy_static! {
    static ref DECODERS: RwLock<HashMap<String, Decoder>> = {
        RwLock::new(HashMap::new())
    };
}

pub fn decode_single_frame_image(avif_bytes: Vec<u8>) -> Frame {
    unsafe {
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

        let image = _get_next_frame(decoder);
        libavif_sys::avifDecoderDestroy(decoder);

        return image.frame;
    }
}

pub fn init_memory_decoder(key: String, avif_bytes: Vec<u8>) -> AvifInfo {
    {
        let map = DECODERS.read().unwrap();
        if map.contains_key(&key) {
            let decoder = &map[&key];
            return decoder.info;
        }
    }

    let (decoder_request_tx, decoder_request_rx): (
        Sender<DecoderCommand>,
        Receiver<DecoderCommand>,
    ) = mpsc::channel();
    let (decoder_response_tx, decoder_response_rx): (
        Sender<CodecResponse>,
        Receiver<CodecResponse>,
    ) = mpsc::channel();
    let (decoder_info_tx, decoder_info_rx): (Sender<AvifInfo>, Receiver<AvifInfo>) =
        mpsc::channel();

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

        match decoder_info_tx.send(AvifInfo {
            width: 0,
            height: 0,
            duration: (*decoder).duration,
            image_count: (*decoder).imageCount as u32,
        }) {
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
        Err(e) => panic!("Couldn't read avi info. Code: {}", e),
    };

    {
        let mut map = DECODERS.write().unwrap();
        map.insert(
            key,
            Decoder {
                request_tx: decoder_request_tx,
                response_rx: decoder_response_rx,
                info: avif_info,
            },
        );
    }
    return avif_info;
}

pub fn reset_decoder(key: String) -> bool {
    let map = DECODERS.read().unwrap();
    if !map.contains_key(&key) {
        return false;
    }

    let decoder = &map[&key];
    match decoder.request_tx.send(DecoderCommand::Reset) {
        Ok(result) => result,
        Err(e) => panic!("Decoder connection lost. {}", e),
    };
    decoder.response_rx.recv().unwrap();
    return true;
}

pub fn dispose_decoder(key: String) -> bool {
    let mut map = DECODERS.write().unwrap();
    if !map.contains_key(&key) {
        return false;
    }

    let decoder = &map[&key];
    match decoder.request_tx.send(DecoderCommand::Dispose) {
        Ok(result) => result,
        Err(e) => panic!("Decoder connection lost. {}", e),
    };
    decoder.response_rx.recv().unwrap();
    map.remove(&key);
    return true;
}

pub fn get_next_frame(key: String) -> Frame {
    let map = DECODERS.read().unwrap();
    if !map.contains_key(&key) {
        panic!("Decoder not found. {}", key);
    }

    let decoder = &map[&key];
    match decoder.request_tx.send(DecoderCommand::GetNextFrame) {
        Ok(result) => result,
        Err(e) => panic!("Decoder connection lost. {}", e),
    };
    let result = decoder.response_rx.recv().unwrap();
    return result.frame;
}

pub fn encode_avif(
    width: u32,
    height: u32,
    speed: i32,
    max_threads: i32,
    timescale: u64,
    max_quantizer: i32,
    min_quantizer: i32,
    max_quantizer_alpha: i32,
    min_quantizer_alpha: i32,
    image_sequence: Vec<EncodeFrame>,
    exif_data: Vec<u8>,
) -> Vec<u8> {
    unsafe {
        let encoder = libavif_sys::avifEncoderCreate();
        (*encoder).maxThreads = max_threads;
        (*encoder).speed = speed;
        (*encoder).timescale = timescale;
        (*encoder).minQuantizer = min_quantizer;
        (*encoder).maxQuantizer = max_quantizer;
        (*encoder).minQuantizerAlpha = min_quantizer_alpha;
        (*encoder).maxQuantizerAlpha = max_quantizer_alpha;

        for frame in image_sequence.iter() {
            let image = libavif_sys::avifImageCreate(
                width,
                height,
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

            if exif_data.len() > 0 {
                libavif_sys::avifImageSetMetadataExif(image, exif_data.as_ptr(), exif_data.len());
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
                frame.duration_in_timescale,
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
}

fn _dispose_decoder(decoder: *mut libavif_sys::avifDecoder) -> CodecResponse {
    unsafe {
        libavif_sys::avifDecoderDestroy(decoder);
        return CodecResponse {
            command: DecoderCommand::Dispose,
            frame: Frame {
                data: Vec::new(),
                duration: 0.0,
                width: 0,
                height: 0,
            },
        };
    }
}

fn _reset_decoder(decoder: *mut libavif_sys::avifDecoder) -> CodecResponse {
    unsafe {
        libavif_sys::avifDecoderReset(decoder);
        return CodecResponse {
            command: DecoderCommand::Reset,
            frame: Frame {
                data: Vec::new(),
                duration: 0.0,
                width: 0,
                height: 0,
            },
        };
    }
}

fn _get_next_frame(decoder: *mut libavif_sys::avifDecoder) -> CodecResponse {
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
        return CodecResponse {
            command: DecoderCommand::GetNextFrame,
            frame: Frame {
                data: data,
                duration: (*decoder).imageTiming.duration,
                width: (*(*decoder).image).width,
                height: (*(*decoder).image).height,
            },
        };
    }
}

#[derive(Copy, Clone)]
pub struct AvifInfo {
    pub width: u32,
    pub height: u32,
    pub image_count: u32,
    pub duration: f64,
}

pub struct Frame {
    pub data: Vec<u8>,
    pub duration: f64,
    pub width: u32,
    pub height: u32,
}

pub struct EncodeFrame {
    pub data: Vec<u8>,
    pub duration_in_timescale: u64,
}

struct Decoder {
    request_tx: Sender<DecoderCommand>,
    response_rx: Receiver<CodecResponse>,
    info: AvifInfo,
}

unsafe impl Send for Decoder {}
unsafe impl Sync for Decoder {}

enum DecoderCommand {
    GetNextFrame,
    Reset,
    Dispose,
}

struct CodecResponse {
    pub command: DecoderCommand,
    pub frame: Frame,
}
