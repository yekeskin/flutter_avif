use super::wire::{bytes_field_size, varint_field_size, Writer};

#[derive(Clone, Debug, Default, PartialEq)]
pub struct Frame {
    pub data: Vec<u8>,
    pub duration: f64,
    pub width: u32,
    pub height: u32,
}

impl Frame {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn write_to_bytes(&self) -> Vec<u8> {
        let mut length = 0;
        if !self.data.is_empty() {
            length += bytes_field_size(1, self.data.len());
        }
        if self.duration != 0.0 {
            length += 1 + 8;
        }
        if self.width != 0 {
            length += varint_field_size(3, self.width);
        }
        if self.height != 0 {
            length += varint_field_size(4, self.height);
        }

        let mut writer = Writer::with_capacity(length);
        if !self.data.is_empty() {
            writer.write_tag(1, 2);
            writer.write_bytes(&self.data);
        }
        if self.duration != 0.0 {
            writer.write_tag(2, 1);
            writer.write_double(self.duration);
        }
        if self.width != 0 {
            writer.write_tag(3, 0);
            writer.write_varint(u64::from(self.width));
        }
        if self.height != 0 {
            writer.write_tag(4, 0);
            writer.write_varint(u64::from(self.height));
        }
        writer.finish()
    }
}

#[cfg(test)]
mod tests {
    use super::Frame;

    #[test]
    fn writes_the_stable_bridge_representation() {
        let frame = Frame {
            data: vec![1, 2],
            duration: 1.5,
            width: 300,
            height: 200,
        };
        assert_eq!(
            frame.write_to_bytes(),
            [
                0x0a, 0x02, 1, 2, 0x11, 0, 0, 0, 0, 0, 0, 0xf8, 0x3f, 0x18, 0xac, 0x02, 0x20, 0xc8,
                0x01,
            ]
        );
    }
}
