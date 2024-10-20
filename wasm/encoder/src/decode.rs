use image::imageops;
use image::{AnimationDecoder, ImageFormat};
use rgb::{ComponentBytes, FromSlice};
use serde::{Deserialize, Serialize};
use std::{cmp, io::Cursor};

pub fn decode_image(byte_data: &[u8], orientation: i32) -> DecodeData {
    let format = image::guess_format(byte_data).unwrap();

    let frames = match format {
        ImageFormat::Png => {
            let decoder = image::codecs::png::PngDecoder::new(Cursor::new(byte_data)).unwrap();
            match decoder.is_apng() {
                true => Some(decoder.apng().into_frames()),
                false => None,
            }
        }
        ImageFormat::Gif => Some(
            image::codecs::gif::GifDecoder::new(Cursor::new(byte_data))
                .unwrap()
                .into_frames(),
        ),
        ImageFormat::WebP => Some(
            image::codecs::webp::WebPDecoder::new(Cursor::new(byte_data))
                .unwrap()
                .into_frames(),
        ),
        _ => None,
    };

    let mut width: u32 = 0;
    let mut height: u32 = 0;
    let mut data: Vec<u8> = vec![];
    let mut durations: Vec<u32> = vec![];

    match frames {
        Some(_frames) => {
            for _frame in _frames {
                let frame = _frame.unwrap();
                let (numer, denom) = frame.delay().numer_denom_ms();

                data.extend_from_slice(frame.buffer().as_rgba().as_bytes());
                durations.push(cmp::max(1, (numer as f32 / denom as f32).ceil() as u32));

                width = frame.buffer().width();
                height = frame.buffer().height()
            }
        }
        None => {
            let mut image = image::load_from_memory(byte_data).unwrap();
            let corrected_image = match orientation {
                8 => {
                    width = image.height();
                    height = image.width();
                    imageops::rotate270(&image)
                }
                7 => {
                    width = image.height();
                    height = image.width();
                    imageops::flip_horizontal_in_place(&mut image);
                    imageops::rotate90(&image)
                }
                6 => {
                    width = image.height();
                    height = image.width();
                    imageops::rotate90(&image)
                }
                5 => {
                    width = image.height();
                    height = image.width();
                    imageops::flip_horizontal_in_place(&mut image);
                    imageops::rotate270(&image)
                }
                4 => {
                    width = image.width();
                    height = image.height();
                    imageops::flip_vertical(&image)
                }
                3 => {
                    width = image.width();
                    height = image.height();
                    imageops::rotate180(&image)
                }
                2 => {
                    width = image.width();
                    height = image.height();
                    imageops::flip_horizontal(&image)
                }
                _ => {
                    width = image.width();
                    height = image.height();
                    image.to_rgba8()
                }
            };

            data.extend_from_slice(corrected_image.as_raw());
            durations.push(1);
        }
    }

    return DecodeData {
        data: data,
        durations: durations,
        width: width,
        height: height,
    };
}

#[derive(Serialize, Deserialize)]
pub struct DecodeData {
    pub data: Vec<u8>,
    pub durations: Vec<u32>,
    pub width: u32,
    pub height: u32,
}
