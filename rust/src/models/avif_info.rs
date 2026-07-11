use super::wire::{varint_field_size, Writer};

#[derive(Clone, Debug, Default, PartialEq)]
pub struct AvifInfo {
    pub width: u32,
    pub height: u32,
    pub image_count: u32,
    pub duration: f64,
}

impl AvifInfo {
    pub fn new() -> Self {
        Self::default()
    }

    pub fn write_to_bytes(&self) -> Vec<u8> {
        let mut length = 0;
        if self.width != 0 {
            length += varint_field_size(1, self.width);
        }
        if self.height != 0 {
            length += varint_field_size(2, self.height);
        }
        if self.image_count != 0 {
            length += varint_field_size(3, self.image_count);
        }
        if self.duration != 0.0 {
            length += 1 + 8;
        }

        let mut writer = Writer::with_capacity(length);
        if self.width != 0 {
            writer.write_tag(1, 0);
            writer.write_varint(u64::from(self.width));
        }
        if self.height != 0 {
            writer.write_tag(2, 0);
            writer.write_varint(u64::from(self.height));
        }
        if self.image_count != 0 {
            writer.write_tag(3, 0);
            writer.write_varint(u64::from(self.image_count));
        }
        if self.duration != 0.0 {
            writer.write_tag(4, 1);
            writer.write_double(self.duration);
        }
        writer.finish()
    }
}

#[cfg(test)]
mod tests {
    use super::AvifInfo;

    #[test]
    fn writes_the_stable_bridge_representation() {
        let info = AvifInfo {
            width: 300,
            height: 200,
            image_count: 2,
            duration: 0.5,
        };
        assert_eq!(
            info.write_to_bytes(),
            [0x08, 0xac, 0x02, 0x10, 0xc8, 0x01, 0x18, 0x02, 0x21, 0, 0, 0, 0, 0, 0, 0xe0, 0x3f,]
        );
    }
}
