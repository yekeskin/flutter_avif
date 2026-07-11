import 'dart:convert';
import 'dart:typed_data';

/// Minimal, allocation-conscious codec for the stable native bridge wire format.
///
/// The field encoding intentionally stays compatible with older bundled native
/// libraries, while avoiding a general-purpose serialization runtime.
final class WireWriter {
  factory WireWriter(int length) {
    final bytes = Uint8List(length);
    return WireWriter._(bytes, ByteData.sublistView(bytes));
  }

  WireWriter._(this._bytes, this._data);

  final Uint8List _bytes;
  final ByteData _data;
  int _offset = 0;

  Uint8List takeBytes() {
    if (_offset != _bytes.length) {
      throw StateError('Wire buffer size mismatch: $_offset/${_bytes.length}');
    }
    return _bytes;
  }

  void writeTag(int fieldNumber, int wireType) {
    writeVarint((fieldNumber << 3) | wireType);
  }

  void writeVarint(int value) {
    while (value >= 0x80) {
      _bytes[_offset++] = (value & 0x7f) | 0x80;
      value >>= 7;
    }
    _bytes[_offset++] = value;
  }

  void writeDouble(double value) {
    _data.setFloat64(_offset, value, Endian.little);
    _offset += 8;
  }

  void writeBytes(List<int> value) {
    writeVarint(value.length);
    _bytes.setRange(_offset, _offset + value.length, value);
    _offset += value.length;
  }

  void writeString(String value) => writeBytes(utf8.encode(value));
}

final class WireReader {
  factory WireReader(List<int> input) => input is Uint8List
      ? WireReader.view(input)
      : WireReader.view(Uint8List.fromList(input));

  factory WireReader.view(Uint8List input) =>
      WireReader._(input, ByteData.sublistView(input));

  WireReader._(this.bytes, this._data);

  final Uint8List bytes;
  final ByteData _data;
  int offset = 0;

  bool get isAtEnd => offset == bytes.length;

  int readTag() {
    final tag = readVarint();
    if (tag == 0 || tag > 0xffffffff || tag >> 3 == 0) {
      throw const FormatException('Invalid wire tag');
    }
    return tag;
  }

  int readVarint() {
    var result = 0;
    for (var shift = 0; shift < 70; shift += 7) {
      if (offset >= bytes.length) {
        throw const FormatException('Truncated varint');
      }
      final byte = bytes[offset++];
      if (shift == 63 && byte > 1) {
        throw const FormatException('Varint overflow');
      }
      result |= (byte & 0x7f) << shift;
      if ((byte & 0x80) == 0) {
        return result;
      }
    }
    throw const FormatException('Varint overflow');
  }

  int readUint32() {
    final value = readVarint();
    if (value > 0xffffffff) {
      throw const FormatException('32-bit integer overflow');
    }
    return value;
  }

  double readDouble() {
    _requireAvailable(8);
    final value = _data.getFloat64(offset, Endian.little);
    offset += 8;
    return value;
  }

  Uint8List readBytes() {
    final length = readVarint();
    _requireAvailable(length);
    final value = Uint8List.sublistView(bytes, offset, offset + length);
    offset += length;
    return value;
  }

  String readString() => utf8.decode(readBytes());

  WireReader readMessage() => WireReader.view(readBytes());

  void requireWireType(int actual, int expected) {
    if (actual != expected) {
      throw FormatException('Unexpected wire type $actual; expected $expected');
    }
  }

  void skipField(int wireType) {
    switch (wireType) {
      case 0:
        readVarint();
        return;
      case 1:
        _requireAvailable(8);
        offset += 8;
        return;
      case 2:
        final length = readVarint();
        _requireAvailable(length);
        offset += length;
        return;
      case 5:
        _requireAvailable(4);
        offset += 4;
        return;
      default:
        throw FormatException('Unsupported wire type $wireType');
    }
  }

  void _requireAvailable(int length) {
    if (length < 0 || length > bytes.length - offset) {
      throw const FormatException('Truncated wire field');
    }
  }
}

int varintSize(int value) {
  var size = 1;
  while (value >= 0x80) {
    value >>= 7;
    size++;
  }
  return size;
}

int bytesFieldSize(int fieldNumber, int length) =>
    varintSize(fieldNumber << 3 | 2) + varintSize(length) + length;

int varintFieldSize(int fieldNumber, int value) =>
    varintSize(fieldNumber << 3) + varintSize(_checkUint32(value));

int zigZagEncode32(int value) {
  if (value < -0x80000000 || value > 0x7fffffff) {
    throw RangeError.range(value, -0x80000000, 0x7fffffff);
  }
  return ((value << 1) ^ (value >> 31)) & 0xffffffff;
}

int zigZagDecode32(int value) => (_checkUint32(value) >> 1) ^ -(value & 1);

int _checkUint32(int value) {
  if (value < 0 || value > 0xffffffff) {
    throw RangeError.range(value, 0, 0xffffffff);
  }
  return value;
}
