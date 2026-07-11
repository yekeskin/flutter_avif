use std::convert::TryFrom;
use std::fmt;

#[derive(Debug)]
pub enum WireError {
    Truncated,
    InvalidTag,
    InvalidWireType(u8),
    UnexpectedWireType { actual: u8, expected: u8 },
    VarintOverflow,
    IntegerOverflow,
    InvalidUtf8,
}

pub type Result<T> = std::result::Result<T, WireError>;

impl fmt::Display for WireError {
    fn fmt(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::Truncated => formatter.write_str("truncated wire field"),
            Self::InvalidTag => formatter.write_str("invalid wire tag"),
            Self::InvalidWireType(wire_type) => {
                write!(formatter, "invalid wire type {wire_type}")
            }
            Self::UnexpectedWireType { actual, expected } => write!(
                formatter,
                "unexpected wire type {actual}; expected {expected}"
            ),
            Self::VarintOverflow => formatter.write_str("varint overflow"),
            Self::IntegerOverflow => formatter.write_str("integer overflow"),
            Self::InvalidUtf8 => formatter.write_str("invalid UTF-8"),
        }
    }
}

impl std::error::Error for WireError {}

pub struct Reader<'a> {
    bytes: &'a [u8],
    offset: usize,
}

impl<'a> Reader<'a> {
    pub fn new(bytes: &'a [u8]) -> Self {
        Self { bytes, offset: 0 }
    }

    pub fn is_at_end(&self) -> bool {
        self.offset == self.bytes.len()
    }

    pub fn read_tag(&mut self) -> Result<(u32, u8)> {
        let tag = self.read_varint()?;
        if tag == 0 || tag > u32::MAX as u64 || tag >> 3 == 0 {
            return Err(WireError::InvalidTag);
        }
        Ok(((tag as u32) >> 3, (tag & 7) as u8))
    }

    pub fn require_wire_type(actual: u8, expected: u8) -> Result<()> {
        if actual == expected {
            Ok(())
        } else {
            Err(WireError::UnexpectedWireType { actual, expected })
        }
    }

    pub fn read_varint(&mut self) -> Result<u64> {
        let mut result = 0u64;
        for shift in (0..70).step_by(7) {
            let byte = *self.bytes.get(self.offset).ok_or(WireError::Truncated)?;
            self.offset += 1;
            if shift == 63 && byte > 1 {
                return Err(WireError::VarintOverflow);
            }
            result |= u64::from(byte & 0x7f) << shift;
            if byte & 0x80 == 0 {
                return Ok(result);
            }
        }
        Err(WireError::VarintOverflow)
    }

    pub fn read_u32(&mut self) -> Result<u32> {
        u32::try_from(self.read_varint()?).map_err(|_| WireError::IntegerOverflow)
    }

    pub fn read_sint32(&mut self) -> Result<i32> {
        let value = self.read_u32()?;
        Ok(((value >> 1) as i32) ^ -((value & 1) as i32))
    }

    pub fn read_bytes(&mut self) -> Result<&'a [u8]> {
        let length =
            usize::try_from(self.read_varint()?).map_err(|_| WireError::IntegerOverflow)?;
        self.take(length)
    }

    pub fn read_owned_bytes(&mut self) -> Result<Vec<u8>> {
        Ok(self.read_bytes()?.to_vec())
    }

    pub fn read_string(&mut self) -> Result<String> {
        String::from_utf8(self.read_owned_bytes()?).map_err(|_| WireError::InvalidUtf8)
    }

    pub fn skip_field(&mut self, wire_type: u8) -> Result<()> {
        match wire_type {
            0 => {
                self.read_varint()?;
                Ok(())
            }
            1 => self.take(8).map(|_| ()),
            2 => self.read_bytes().map(|_| ()),
            5 => self.take(4).map(|_| ()),
            other => Err(WireError::InvalidWireType(other)),
        }
    }

    fn take(&mut self, length: usize) -> Result<&'a [u8]> {
        let end = self
            .offset
            .checked_add(length)
            .filter(|end| *end <= self.bytes.len())
            .ok_or(WireError::Truncated)?;
        let result = &self.bytes[self.offset..end];
        self.offset = end;
        Ok(result)
    }
}

pub struct Writer {
    bytes: Vec<u8>,
}

impl Writer {
    pub fn with_capacity(capacity: usize) -> Self {
        Self {
            bytes: Vec::with_capacity(capacity),
        }
    }

    pub fn write_tag(&mut self, field: u32, wire_type: u8) {
        self.write_varint(u64::from((field << 3) | u32::from(wire_type)));
    }

    pub fn write_varint(&mut self, mut value: u64) {
        while value >= 0x80 {
            self.bytes.push((value as u8 & 0x7f) | 0x80);
            value >>= 7;
        }
        self.bytes.push(value as u8);
    }

    pub fn write_bytes(&mut self, value: &[u8]) {
        self.write_varint(value.len() as u64);
        self.bytes.extend_from_slice(value);
    }

    pub fn write_double(&mut self, value: f64) {
        self.bytes.extend_from_slice(&value.to_le_bytes());
    }

    pub fn finish(self) -> Vec<u8> {
        self.bytes
    }
}

pub fn varint_size(mut value: u64) -> usize {
    let mut size = 1;
    while value >= 0x80 {
        value >>= 7;
        size += 1;
    }
    size
}

pub fn bytes_field_size(field: u32, length: usize) -> usize {
    varint_size(u64::from((field << 3) | 2)) + varint_size(length as u64) + length
}

pub fn varint_field_size(field: u32, value: u32) -> usize {
    varint_size(u64::from(field << 3)) + varint_size(u64::from(value))
}
