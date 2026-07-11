use super::encode_frame::EncodeFrame;
use super::wire::{Reader, Result};

#[derive(Debug, Default, PartialEq)]
pub struct EncodeRequest {
    pub width: u32,
    pub height: u32,
    pub speed: i32,
    pub max_threads: i32,
    pub timescale: u32,
    pub max_quantizer: i32,
    pub min_quantizer: i32,
    pub max_quantizer_alpha: i32,
    pub min_quantizer_alpha: i32,
    pub image_list: Vec<EncodeFrame>,
    pub exif_data: Vec<u8>,
}

impl EncodeRequest {
    pub fn parse_from_bytes(bytes: &[u8]) -> Result<Self> {
        let mut result = Self::default();
        let mut reader = Reader::new(bytes);
        while !reader.is_at_end() {
            let (field, wire_type) = reader.read_tag()?;
            match field {
                1 => {
                    Reader::require_wire_type(wire_type, 0)?;
                    result.width = reader.read_u32()?;
                }
                2 => {
                    Reader::require_wire_type(wire_type, 0)?;
                    result.height = reader.read_u32()?;
                }
                3 => {
                    Reader::require_wire_type(wire_type, 0)?;
                    result.speed = reader.read_sint32()?;
                }
                4 => {
                    Reader::require_wire_type(wire_type, 0)?;
                    result.max_threads = reader.read_sint32()?;
                }
                5 => {
                    Reader::require_wire_type(wire_type, 0)?;
                    result.timescale = reader.read_u32()?;
                }
                6 => {
                    Reader::require_wire_type(wire_type, 0)?;
                    result.max_quantizer = reader.read_sint32()?;
                }
                7 => {
                    Reader::require_wire_type(wire_type, 0)?;
                    result.min_quantizer = reader.read_sint32()?;
                }
                8 => {
                    Reader::require_wire_type(wire_type, 0)?;
                    result.max_quantizer_alpha = reader.read_sint32()?;
                }
                9 => {
                    Reader::require_wire_type(wire_type, 0)?;
                    result.min_quantizer_alpha = reader.read_sint32()?;
                }
                10 => {
                    Reader::require_wire_type(wire_type, 2)?;
                    result
                        .image_list
                        .push(EncodeFrame::parse_from_bytes(reader.read_bytes()?)?);
                }
                11 => {
                    Reader::require_wire_type(wire_type, 2)?;
                    result.exif_data = reader.read_owned_bytes()?;
                }
                _ => reader.skip_field(wire_type)?,
            }
        }
        Ok(result)
    }
}

#[cfg(test)]
mod tests {
    use super::EncodeRequest;

    #[test]
    fn parses_signed_values_and_nested_frames() {
        let input = [
            0x08, 0xac, 0x02, // width = 300
            0x18, 0x09, // speed = -5 (zig-zag)
            0x52, 0x06, 0x0a, 0x02, 1, 2, 0x10, 0x03, 0x5a, 0x01, 9,
        ];
        let request = EncodeRequest::parse_from_bytes(&input).unwrap();
        assert_eq!(request.width, 300);
        assert_eq!(request.speed, -5);
        assert_eq!(request.image_list.len(), 1);
        assert_eq!(request.image_list[0].data, [1, 2]);
        assert_eq!(request.image_list[0].duration_in_timescale, 3);
        assert_eq!(request.exif_data, [9]);
    }
}
