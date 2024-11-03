// This file is generated by rust-protobuf 3.7.1. Do not edit
// .proto file is parsed by protoc --rs_out=...
// @generated

// https://github.com/rust-lang/rust-clippy/issues/702
#![allow(unknown_lints)]
#![allow(clippy::all)]

#![allow(unused_attributes)]
#![cfg_attr(rustfmt, rustfmt::skip)]

#![allow(dead_code)]
#![allow(missing_docs)]
#![allow(non_camel_case_types)]
#![allow(non_snake_case)]
#![allow(non_upper_case_globals)]
#![allow(trivial_casts)]
#![allow(unused_results)]
#![allow(unused_mut)]

//! Generated file from `encode_request.proto`

/// Generated files are compatible only with the same version
/// of protobuf runtime.
const _PROTOBUF_VERSION_CHECK: () = ::protobuf::VERSION_3_7_1;

// @@protoc_insertion_point(message:models.EncodeRequest)
#[derive(PartialEq,Clone,Default,Debug)]
pub struct EncodeRequest {
    // message fields
    // @@protoc_insertion_point(field:models.EncodeRequest.width)
    pub width: u32,
    // @@protoc_insertion_point(field:models.EncodeRequest.height)
    pub height: u32,
    // @@protoc_insertion_point(field:models.EncodeRequest.speed)
    pub speed: i32,
    // @@protoc_insertion_point(field:models.EncodeRequest.max_threads)
    pub max_threads: i32,
    // @@protoc_insertion_point(field:models.EncodeRequest.timescale)
    pub timescale: u32,
    // @@protoc_insertion_point(field:models.EncodeRequest.max_quantizer)
    pub max_quantizer: i32,
    // @@protoc_insertion_point(field:models.EncodeRequest.min_quantizer)
    pub min_quantizer: i32,
    // @@protoc_insertion_point(field:models.EncodeRequest.max_quantizer_alpha)
    pub max_quantizer_alpha: i32,
    // @@protoc_insertion_point(field:models.EncodeRequest.min_quantizer_alpha)
    pub min_quantizer_alpha: i32,
    // @@protoc_insertion_point(field:models.EncodeRequest.image_list)
    pub image_list: ::std::vec::Vec<super::encode_frame::EncodeFrame>,
    // @@protoc_insertion_point(field:models.EncodeRequest.exif_data)
    pub exif_data: ::std::vec::Vec<u8>,
    // special fields
    // @@protoc_insertion_point(special_field:models.EncodeRequest.special_fields)
    pub special_fields: ::protobuf::SpecialFields,
}

impl<'a> ::std::default::Default for &'a EncodeRequest {
    fn default() -> &'a EncodeRequest {
        <EncodeRequest as ::protobuf::Message>::default_instance()
    }
}

impl EncodeRequest {
    pub fn new() -> EncodeRequest {
        ::std::default::Default::default()
    }

    fn generated_message_descriptor_data() -> ::protobuf::reflect::GeneratedMessageDescriptorData {
        let mut fields = ::std::vec::Vec::with_capacity(11);
        let mut oneofs = ::std::vec::Vec::with_capacity(0);
        fields.push(::protobuf::reflect::rt::v2::make_simpler_field_accessor::<_, _>(
            "width",
            |m: &EncodeRequest| { &m.width },
            |m: &mut EncodeRequest| { &mut m.width },
        ));
        fields.push(::protobuf::reflect::rt::v2::make_simpler_field_accessor::<_, _>(
            "height",
            |m: &EncodeRequest| { &m.height },
            |m: &mut EncodeRequest| { &mut m.height },
        ));
        fields.push(::protobuf::reflect::rt::v2::make_simpler_field_accessor::<_, _>(
            "speed",
            |m: &EncodeRequest| { &m.speed },
            |m: &mut EncodeRequest| { &mut m.speed },
        ));
        fields.push(::protobuf::reflect::rt::v2::make_simpler_field_accessor::<_, _>(
            "max_threads",
            |m: &EncodeRequest| { &m.max_threads },
            |m: &mut EncodeRequest| { &mut m.max_threads },
        ));
        fields.push(::protobuf::reflect::rt::v2::make_simpler_field_accessor::<_, _>(
            "timescale",
            |m: &EncodeRequest| { &m.timescale },
            |m: &mut EncodeRequest| { &mut m.timescale },
        ));
        fields.push(::protobuf::reflect::rt::v2::make_simpler_field_accessor::<_, _>(
            "max_quantizer",
            |m: &EncodeRequest| { &m.max_quantizer },
            |m: &mut EncodeRequest| { &mut m.max_quantizer },
        ));
        fields.push(::protobuf::reflect::rt::v2::make_simpler_field_accessor::<_, _>(
            "min_quantizer",
            |m: &EncodeRequest| { &m.min_quantizer },
            |m: &mut EncodeRequest| { &mut m.min_quantizer },
        ));
        fields.push(::protobuf::reflect::rt::v2::make_simpler_field_accessor::<_, _>(
            "max_quantizer_alpha",
            |m: &EncodeRequest| { &m.max_quantizer_alpha },
            |m: &mut EncodeRequest| { &mut m.max_quantizer_alpha },
        ));
        fields.push(::protobuf::reflect::rt::v2::make_simpler_field_accessor::<_, _>(
            "min_quantizer_alpha",
            |m: &EncodeRequest| { &m.min_quantizer_alpha },
            |m: &mut EncodeRequest| { &mut m.min_quantizer_alpha },
        ));
        fields.push(::protobuf::reflect::rt::v2::make_vec_simpler_accessor::<_, _>(
            "image_list",
            |m: &EncodeRequest| { &m.image_list },
            |m: &mut EncodeRequest| { &mut m.image_list },
        ));
        fields.push(::protobuf::reflect::rt::v2::make_simpler_field_accessor::<_, _>(
            "exif_data",
            |m: &EncodeRequest| { &m.exif_data },
            |m: &mut EncodeRequest| { &mut m.exif_data },
        ));
        ::protobuf::reflect::GeneratedMessageDescriptorData::new_2::<EncodeRequest>(
            "EncodeRequest",
            fields,
            oneofs,
        )
    }
}

impl ::protobuf::Message for EncodeRequest {
    const NAME: &'static str = "EncodeRequest";

    fn is_initialized(&self) -> bool {
        true
    }

    fn merge_from(&mut self, is: &mut ::protobuf::CodedInputStream<'_>) -> ::protobuf::Result<()> {
        while let Some(tag) = is.read_raw_tag_or_eof()? {
            match tag {
                8 => {
                    self.width = is.read_uint32()?;
                },
                16 => {
                    self.height = is.read_uint32()?;
                },
                24 => {
                    self.speed = is.read_sint32()?;
                },
                32 => {
                    self.max_threads = is.read_sint32()?;
                },
                40 => {
                    self.timescale = is.read_uint32()?;
                },
                48 => {
                    self.max_quantizer = is.read_sint32()?;
                },
                56 => {
                    self.min_quantizer = is.read_sint32()?;
                },
                64 => {
                    self.max_quantizer_alpha = is.read_sint32()?;
                },
                72 => {
                    self.min_quantizer_alpha = is.read_sint32()?;
                },
                82 => {
                    self.image_list.push(is.read_message()?);
                },
                90 => {
                    self.exif_data = is.read_bytes()?;
                },
                tag => {
                    ::protobuf::rt::read_unknown_or_skip_group(tag, is, self.special_fields.mut_unknown_fields())?;
                },
            };
        }
        ::std::result::Result::Ok(())
    }

    // Compute sizes of nested messages
    #[allow(unused_variables)]
    fn compute_size(&self) -> u64 {
        let mut my_size = 0;
        if self.width != 0 {
            my_size += ::protobuf::rt::uint32_size(1, self.width);
        }
        if self.height != 0 {
            my_size += ::protobuf::rt::uint32_size(2, self.height);
        }
        if self.speed != 0 {
            my_size += ::protobuf::rt::sint32_size(3, self.speed);
        }
        if self.max_threads != 0 {
            my_size += ::protobuf::rt::sint32_size(4, self.max_threads);
        }
        if self.timescale != 0 {
            my_size += ::protobuf::rt::uint32_size(5, self.timescale);
        }
        if self.max_quantizer != 0 {
            my_size += ::protobuf::rt::sint32_size(6, self.max_quantizer);
        }
        if self.min_quantizer != 0 {
            my_size += ::protobuf::rt::sint32_size(7, self.min_quantizer);
        }
        if self.max_quantizer_alpha != 0 {
            my_size += ::protobuf::rt::sint32_size(8, self.max_quantizer_alpha);
        }
        if self.min_quantizer_alpha != 0 {
            my_size += ::protobuf::rt::sint32_size(9, self.min_quantizer_alpha);
        }
        for value in &self.image_list {
            let len = value.compute_size();
            my_size += 1 + ::protobuf::rt::compute_raw_varint64_size(len) + len;
        };
        if !self.exif_data.is_empty() {
            my_size += ::protobuf::rt::bytes_size(11, &self.exif_data);
        }
        my_size += ::protobuf::rt::unknown_fields_size(self.special_fields.unknown_fields());
        self.special_fields.cached_size().set(my_size as u32);
        my_size
    }

    fn write_to_with_cached_sizes(&self, os: &mut ::protobuf::CodedOutputStream<'_>) -> ::protobuf::Result<()> {
        if self.width != 0 {
            os.write_uint32(1, self.width)?;
        }
        if self.height != 0 {
            os.write_uint32(2, self.height)?;
        }
        if self.speed != 0 {
            os.write_sint32(3, self.speed)?;
        }
        if self.max_threads != 0 {
            os.write_sint32(4, self.max_threads)?;
        }
        if self.timescale != 0 {
            os.write_uint32(5, self.timescale)?;
        }
        if self.max_quantizer != 0 {
            os.write_sint32(6, self.max_quantizer)?;
        }
        if self.min_quantizer != 0 {
            os.write_sint32(7, self.min_quantizer)?;
        }
        if self.max_quantizer_alpha != 0 {
            os.write_sint32(8, self.max_quantizer_alpha)?;
        }
        if self.min_quantizer_alpha != 0 {
            os.write_sint32(9, self.min_quantizer_alpha)?;
        }
        for v in &self.image_list {
            ::protobuf::rt::write_message_field_with_cached_size(10, v, os)?;
        };
        if !self.exif_data.is_empty() {
            os.write_bytes(11, &self.exif_data)?;
        }
        os.write_unknown_fields(self.special_fields.unknown_fields())?;
        ::std::result::Result::Ok(())
    }

    fn special_fields(&self) -> &::protobuf::SpecialFields {
        &self.special_fields
    }

    fn mut_special_fields(&mut self) -> &mut ::protobuf::SpecialFields {
        &mut self.special_fields
    }

    fn new() -> EncodeRequest {
        EncodeRequest::new()
    }

    fn clear(&mut self) {
        self.width = 0;
        self.height = 0;
        self.speed = 0;
        self.max_threads = 0;
        self.timescale = 0;
        self.max_quantizer = 0;
        self.min_quantizer = 0;
        self.max_quantizer_alpha = 0;
        self.min_quantizer_alpha = 0;
        self.image_list.clear();
        self.exif_data.clear();
        self.special_fields.clear();
    }

    fn default_instance() -> &'static EncodeRequest {
        static instance: EncodeRequest = EncodeRequest {
            width: 0,
            height: 0,
            speed: 0,
            max_threads: 0,
            timescale: 0,
            max_quantizer: 0,
            min_quantizer: 0,
            max_quantizer_alpha: 0,
            min_quantizer_alpha: 0,
            image_list: ::std::vec::Vec::new(),
            exif_data: ::std::vec::Vec::new(),
            special_fields: ::protobuf::SpecialFields::new(),
        };
        &instance
    }
}

impl ::protobuf::MessageFull for EncodeRequest {
    fn descriptor() -> ::protobuf::reflect::MessageDescriptor {
        static descriptor: ::protobuf::rt::Lazy<::protobuf::reflect::MessageDescriptor> = ::protobuf::rt::Lazy::new();
        descriptor.get(|| file_descriptor().message_by_package_relative_name("EncodeRequest").unwrap()).clone()
    }
}

impl ::std::fmt::Display for EncodeRequest {
    fn fmt(&self, f: &mut ::std::fmt::Formatter<'_>) -> ::std::fmt::Result {
        ::protobuf::text_format::fmt(self, f)
    }
}

impl ::protobuf::reflect::ProtobufValue for EncodeRequest {
    type RuntimeType = ::protobuf::reflect::rt::RuntimeTypeMessage<Self>;
}

static file_descriptor_proto_data: &'static [u8] = b"\
    \n\x14encode_request.proto\x12\x06models\x1a\x12encode_frame.proto\"\x8d\
    \x03\n\rEncodeRequest\x12\x14\n\x05width\x18\x01\x20\x01(\rR\x05width\
    \x12\x16\n\x06height\x18\x02\x20\x01(\rR\x06height\x12\x14\n\x05speed\
    \x18\x03\x20\x01(\x11R\x05speed\x12\x1f\n\x0bmax_threads\x18\x04\x20\x01\
    (\x11R\nmaxThreads\x12\x1c\n\ttimescale\x18\x05\x20\x01(\rR\ttimescale\
    \x12#\n\rmax_quantizer\x18\x06\x20\x01(\x11R\x0cmaxQuantizer\x12#\n\rmin\
    _quantizer\x18\x07\x20\x01(\x11R\x0cminQuantizer\x12.\n\x13max_quantizer\
    _alpha\x18\x08\x20\x01(\x11R\x11maxQuantizerAlpha\x12.\n\x13min_quantize\
    r_alpha\x18\t\x20\x01(\x11R\x11minQuantizerAlpha\x122\n\nimage_list\x18\
    \n\x20\x03(\x0b2\x13.models.EncodeFrameR\timageList\x12\x1b\n\texif_data\
    \x18\x0b\x20\x01(\x0cR\x08exifDataJ\xaa\x05\n\x06\x12\x04\0\0\x12\x01\n\
    \x08\n\x01\x0c\x12\x03\0\0\x12\n\x08\n\x01\x02\x12\x03\x02\0\x0f\n\t\n\
    \x02\x03\0\x12\x03\x04\0\x1c\n\n\n\x02\x04\0\x12\x04\x06\0\x12\x01\n\n\n\
    \x03\x04\0\x01\x12\x03\x06\x08\x15\n\x0b\n\x04\x04\0\x02\0\x12\x03\x07\
    \x04\x15\n\x0c\n\x05\x04\0\x02\0\x05\x12\x03\x07\x04\n\n\x0c\n\x05\x04\0\
    \x02\0\x01\x12\x03\x07\x0b\x10\n\x0c\n\x05\x04\0\x02\0\x03\x12\x03\x07\
    \x13\x14\n\x0b\n\x04\x04\0\x02\x01\x12\x03\x08\x04\x16\n\x0c\n\x05\x04\0\
    \x02\x01\x05\x12\x03\x08\x04\n\n\x0c\n\x05\x04\0\x02\x01\x01\x12\x03\x08\
    \x0b\x11\n\x0c\n\x05\x04\0\x02\x01\x03\x12\x03\x08\x14\x15\n\x0b\n\x04\
    \x04\0\x02\x02\x12\x03\t\x04\x15\n\x0c\n\x05\x04\0\x02\x02\x05\x12\x03\t\
    \x04\n\n\x0c\n\x05\x04\0\x02\x02\x01\x12\x03\t\x0b\x10\n\x0c\n\x05\x04\0\
    \x02\x02\x03\x12\x03\t\x13\x14\n\x0b\n\x04\x04\0\x02\x03\x12\x03\n\x04\
    \x1b\n\x0c\n\x05\x04\0\x02\x03\x05\x12\x03\n\x04\n\n\x0c\n\x05\x04\0\x02\
    \x03\x01\x12\x03\n\x0b\x16\n\x0c\n\x05\x04\0\x02\x03\x03\x12\x03\n\x19\
    \x1a\n\x0b\n\x04\x04\0\x02\x04\x12\x03\x0b\x04\x19\n\x0c\n\x05\x04\0\x02\
    \x04\x05\x12\x03\x0b\x04\n\n\x0c\n\x05\x04\0\x02\x04\x01\x12\x03\x0b\x0b\
    \x14\n\x0c\n\x05\x04\0\x02\x04\x03\x12\x03\x0b\x17\x18\n\x0b\n\x04\x04\0\
    \x02\x05\x12\x03\x0c\x04\x1d\n\x0c\n\x05\x04\0\x02\x05\x05\x12\x03\x0c\
    \x04\n\n\x0c\n\x05\x04\0\x02\x05\x01\x12\x03\x0c\x0b\x18\n\x0c\n\x05\x04\
    \0\x02\x05\x03\x12\x03\x0c\x1b\x1c\n\x0b\n\x04\x04\0\x02\x06\x12\x03\r\
    \x04\x1d\n\x0c\n\x05\x04\0\x02\x06\x05\x12\x03\r\x04\n\n\x0c\n\x05\x04\0\
    \x02\x06\x01\x12\x03\r\x0b\x18\n\x0c\n\x05\x04\0\x02\x06\x03\x12\x03\r\
    \x1b\x1c\n\x0b\n\x04\x04\0\x02\x07\x12\x03\x0e\x04#\n\x0c\n\x05\x04\0\
    \x02\x07\x05\x12\x03\x0e\x04\n\n\x0c\n\x05\x04\0\x02\x07\x01\x12\x03\x0e\
    \x0b\x1e\n\x0c\n\x05\x04\0\x02\x07\x03\x12\x03\x0e!\"\n\x0b\n\x04\x04\0\
    \x02\x08\x12\x03\x0f\x04#\n\x0c\n\x05\x04\0\x02\x08\x05\x12\x03\x0f\x04\
    \n\n\x0c\n\x05\x04\0\x02\x08\x01\x12\x03\x0f\x0b\x1e\n\x0c\n\x05\x04\0\
    \x02\x08\x03\x12\x03\x0f!\"\n\x0b\n\x04\x04\0\x02\t\x12\x03\x10\x04)\n\
    \x0c\n\x05\x04\0\x02\t\x04\x12\x03\x10\x04\x0c\n\x0c\n\x05\x04\0\x02\t\
    \x06\x12\x03\x10\r\x18\n\x0c\n\x05\x04\0\x02\t\x01\x12\x03\x10\x19#\n\
    \x0c\n\x05\x04\0\x02\t\x03\x12\x03\x10&(\n\x0b\n\x04\x04\0\x02\n\x12\x03\
    \x11\x04\x19\n\x0c\n\x05\x04\0\x02\n\x05\x12\x03\x11\x04\t\n\x0c\n\x05\
    \x04\0\x02\n\x01\x12\x03\x11\n\x13\n\x0c\n\x05\x04\0\x02\n\x03\x12\x03\
    \x11\x16\x18b\x06proto3\
";

/// `FileDescriptorProto` object which was a source for this generated file
fn file_descriptor_proto() -> &'static ::protobuf::descriptor::FileDescriptorProto {
    static file_descriptor_proto_lazy: ::protobuf::rt::Lazy<::protobuf::descriptor::FileDescriptorProto> = ::protobuf::rt::Lazy::new();
    file_descriptor_proto_lazy.get(|| {
        ::protobuf::Message::parse_from_bytes(file_descriptor_proto_data).unwrap()
    })
}

/// `FileDescriptor` object which allows dynamic access to files
pub fn file_descriptor() -> &'static ::protobuf::reflect::FileDescriptor {
    static generated_file_descriptor_lazy: ::protobuf::rt::Lazy<::protobuf::reflect::GeneratedFileDescriptor> = ::protobuf::rt::Lazy::new();
    static file_descriptor: ::protobuf::rt::Lazy<::protobuf::reflect::FileDescriptor> = ::protobuf::rt::Lazy::new();
    file_descriptor.get(|| {
        let generated_file_descriptor = generated_file_descriptor_lazy.get(|| {
            let mut deps = ::std::vec::Vec::with_capacity(1);
            deps.push(super::encode_frame::file_descriptor().clone());
            let mut messages = ::std::vec::Vec::with_capacity(1);
            messages.push(EncodeRequest::generated_message_descriptor_data());
            let mut enums = ::std::vec::Vec::with_capacity(0);
            ::protobuf::reflect::GeneratedFileDescriptor::new_generated(
                file_descriptor_proto(),
                deps,
                messages,
                enums,
            )
        });
        ::protobuf::reflect::FileDescriptor::new_generated_2(generated_file_descriptor)
    })
}