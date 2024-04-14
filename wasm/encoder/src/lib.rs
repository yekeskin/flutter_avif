mod decode;
mod encode;
mod utils;

use rgb::{FromSlice, RGBA};
use wasm_bindgen::prelude::*;

// When the `wee_alloc` feature is enabled, use `wee_alloc` as the global
// allocator.
#[cfg(feature = "wee_alloc")]
#[global_allocator]
static ALLOC: wee_alloc::WeeAlloc = wee_alloc::WeeAlloc::INIT;

#[wasm_bindgen]
extern "C" {
    #[wasm_bindgen(js_namespace = console)]
    fn log(s: &str);
}

#[wasm_bindgen]
pub fn encode(
    _pixels: js_sys::Uint8Array,
    _durations: js_sys::Uint8Array,
    _options: js_sys::Uint32Array,
    _exif_data: js_sys::Uint8Array,
) -> Vec<u8> {
    utils::set_panic_hook();

    let pixels: Vec<RGBA<u8>> = _pixels.to_vec().as_rgba().to_vec();
    let durations: Vec<u8> = _durations.to_vec();
    let options: Vec<u32> = _options.to_vec();
    let exif_data: Vec<u8> = _exif_data.to_vec();

    // scale quantizer values as rav1e's range
    let max_quantizer = (options[5] * 255) / 63;
    let min_quantizer = (options[6] * 255) / 63;
    let max_quantizer_alpha = (options[7] * 255) / 63;
    let min_quantizer_alpha = (options[8] * 255) / 63;

    return encode::encode_to_avif(
        options[0] as usize,
        options[1] as usize,
        options[2] as u8,
        options[3] as usize,
        options[4] as u64,
        max_quantizer as usize,
        min_quantizer as u8,
        max_quantizer_alpha as usize,
        min_quantizer_alpha as u8,
        &pixels,
        &durations,
        &exif_data,
    )
    .expect("Failed to encode AVIF! image");
}

#[wasm_bindgen]
pub fn decode(_data: js_sys::Uint8Array, orientation: i32) -> JsValue {
    utils::set_panic_hook();

    let data: Vec<u8> = _data.to_vec();

    return JsValue::from_serde(&decode::decode_image(&data, orientation)).unwrap();
}
