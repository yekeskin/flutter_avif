use super::wire::{Reader, Result};

#[derive(Clone, Debug, Default, PartialEq)]
pub struct EncodeFrame {
    pub data: Vec<u8>,
    pub duration_in_timescale: u32,
}

impl EncodeFrame {
    pub fn parse_from_bytes(bytes: &[u8]) -> Result<Self> {
        let mut result = Self::default();
        let mut reader = Reader::new(bytes);
        while !reader.is_at_end() {
            let (field, wire_type) = reader.read_tag()?;
            match field {
                1 => {
                    Reader::require_wire_type(wire_type, 2)?;
                    result.data = reader.read_owned_bytes()?;
                }
                2 => {
                    Reader::require_wire_type(wire_type, 0)?;
                    result.duration_in_timescale = reader.read_u32()?;
                }
                _ => reader.skip_field(wire_type)?,
            }
        }
        Ok(result)
    }
}
