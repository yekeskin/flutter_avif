use super::*;
// Section: wire functions

#[no_mangle]
pub extern "C" fn wire_init_memory_decoder(
    port_: i64,
    key: *mut wire_uint_8_list,
    avif_bytes: *mut wire_uint_8_list,
) {
    wire_init_memory_decoder_impl(port_, key, avif_bytes)
}

#[no_mangle]
pub extern "C" fn wire_reset_decoder(port_: i64, key: *mut wire_uint_8_list) {
    wire_reset_decoder_impl(port_, key)
}

#[no_mangle]
pub extern "C" fn wire_dispose_decoder(port_: i64, key: *mut wire_uint_8_list) {
    wire_dispose_decoder_impl(port_, key)
}

#[no_mangle]
pub extern "C" fn wire_get_next_frame(port_: i64, key: *mut wire_uint_8_list) {
    wire_get_next_frame_impl(port_, key)
}

#[no_mangle]
pub extern "C" fn wire_encode_avif(
    port_: i64,
    width: i32,
    height: i32,
    speed: i32,
    max_threads: i32,
    timescale: u64,
    max_quantizer: i32,
    min_quantizer: i32,
    max_quantizer_alpha: i32,
    min_quantizer_alpha: i32,
    image_sequence: *mut wire_list_encode_frame,
) {
    wire_encode_avif_impl(
        port_,
        width,
        height,
        speed,
        max_threads,
        timescale,
        max_quantizer,
        min_quantizer,
        max_quantizer_alpha,
        min_quantizer_alpha,
        image_sequence,
    )
}

// Section: allocate functions

#[no_mangle]
pub extern "C" fn new_list_encode_frame_0(len: i32) -> *mut wire_list_encode_frame {
    let wrap = wire_list_encode_frame {
        ptr: support::new_leak_vec_ptr(<wire_EncodeFrame>::new_with_null_ptr(), len),
        len,
    };
    support::new_leak_box_ptr(wrap)
}

#[no_mangle]
pub extern "C" fn new_uint_8_list_0(len: i32) -> *mut wire_uint_8_list {
    let ans = wire_uint_8_list {
        ptr: support::new_leak_vec_ptr(Default::default(), len),
        len,
    };
    support::new_leak_box_ptr(ans)
}

// Section: related functions

// Section: impl Wire2Api

impl Wire2Api<String> for *mut wire_uint_8_list {
    fn wire2api(self) -> String {
        let vec: Vec<u8> = self.wire2api();
        String::from_utf8_lossy(&vec).into_owned()
    }
}
impl Wire2Api<EncodeFrame> for wire_EncodeFrame {
    fn wire2api(self) -> EncodeFrame {
        EncodeFrame {
            data: self.data.wire2api(),
            duration_in_timescale: self.duration_in_timescale.wire2api(),
        }
    }
}

impl Wire2Api<Vec<EncodeFrame>> for *mut wire_list_encode_frame {
    fn wire2api(self) -> Vec<EncodeFrame> {
        let vec = unsafe {
            let wrap = support::box_from_leak_ptr(self);
            support::vec_from_leak_ptr(wrap.ptr, wrap.len)
        };
        vec.into_iter().map(Wire2Api::wire2api).collect()
    }
}

impl Wire2Api<Vec<u8>> for *mut wire_uint_8_list {
    fn wire2api(self) -> Vec<u8> {
        unsafe {
            let wrap = support::box_from_leak_ptr(self);
            support::vec_from_leak_ptr(wrap.ptr, wrap.len)
        }
    }
}
// Section: wire structs

#[repr(C)]
#[derive(Clone)]
pub struct wire_EncodeFrame {
    data: *mut wire_uint_8_list,
    duration_in_timescale: u64,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_list_encode_frame {
    ptr: *mut wire_EncodeFrame,
    len: i32,
}

#[repr(C)]
#[derive(Clone)]
pub struct wire_uint_8_list {
    ptr: *mut u8,
    len: i32,
}

// Section: impl NewWithNullPtr

pub trait NewWithNullPtr {
    fn new_with_null_ptr() -> Self;
}

impl<T> NewWithNullPtr for *mut T {
    fn new_with_null_ptr() -> Self {
        std::ptr::null_mut()
    }
}

impl NewWithNullPtr for wire_EncodeFrame {
    fn new_with_null_ptr() -> Self {
        Self {
            data: core::ptr::null_mut(),
            duration_in_timescale: Default::default(),
        }
    }
}

impl Default for wire_EncodeFrame {
    fn default() -> Self {
        Self::new_with_null_ptr()
    }
}

// Section: sync execution mode utility

#[no_mangle]
pub extern "C" fn free_WireSyncReturn(ptr: support::WireSyncReturn) {
    unsafe {
        let _ = support::box_from_leak_ptr(ptr);
    };
}
