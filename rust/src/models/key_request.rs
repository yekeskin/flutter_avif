use super::wire::{Reader, Result};

#[derive(Debug, Default, PartialEq)]
pub struct KeyRequest {
    pub key: String,
    pub data: Vec<u8>,
}

impl KeyRequest {
    pub fn parse_from_bytes(bytes: &[u8]) -> Result<Self> {
        let mut result = Self::default();
        let mut reader = Reader::new(bytes);
        while !reader.is_at_end() {
            let (field, wire_type) = reader.read_tag()?;
            match field {
                1 => {
                    Reader::require_wire_type(wire_type, 2)?;
                    result.key = reader.read_string()?;
                }
                2 => {
                    Reader::require_wire_type(wire_type, 2)?;
                    result.data = reader.read_owned_bytes()?;
                }
                _ => reader.skip_field(wire_type)?,
            }
        }
        Ok(result)
    }
}

#[cfg(test)]
mod tests {
    use super::KeyRequest;

    #[test]
    fn parses_bridge_fixture_and_skips_unknown_fields() {
        let input = [0x0a, 0x01, b'a', 0x12, 0x02, 1, 2, 0x78, 0x07];
        let request = KeyRequest::parse_from_bytes(&input).unwrap();
        assert_eq!(request.key, "a");
        assert_eq!(request.data, [1, 2]);
    }
}
