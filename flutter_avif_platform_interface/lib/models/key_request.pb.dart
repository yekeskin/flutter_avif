import 'dart:convert';
import 'dart:typed_data';

import 'wire_format.dart';

/// Decoder lookup key plus optional AVIF input bytes.
class KeyRequest {
  KeyRequest({String? key, List<int>? data})
      : key = key ?? '',
        data = data ?? Uint8List(0);

  factory KeyRequest.fromBuffer(List<int> input) =>
      KeyRequest()..mergeFromBuffer(input);

  String key;
  List<int> data;

  bool hasKey() => key.isNotEmpty;
  bool hasData() => data.isNotEmpty;
  void clearKey() => key = '';
  void clearData() => data = Uint8List(0);

  static KeyRequest create() => KeyRequest();
  KeyRequest createEmptyInstance() => KeyRequest();
  static List<KeyRequest> createRepeated() => <KeyRequest>[];
  static final KeyRequest _defaultInstance = KeyRequest();
  static KeyRequest getDefault() => _defaultInstance;

  KeyRequest clone() => KeyRequest(key: key, data: Uint8List.fromList(data));

  KeyRequest copyWith(void Function(KeyRequest) updates) {
    final copy = clone();
    updates(copy);
    return copy;
  }

  void mergeFromMessage(KeyRequest other) {
    if (other.key.isNotEmpty) key = other.key;
    if (other.data.isNotEmpty) data = Uint8List.fromList(other.data);
  }

  Uint8List writeToBuffer() {
    final encodedKey = key.isEmpty ? Uint8List(0) : utf8.encode(key);
    var length = 0;
    if (encodedKey.isNotEmpty) length += bytesFieldSize(1, encodedKey.length);
    if (data.isNotEmpty) length += bytesFieldSize(2, data.length);

    final writer = WireWriter(length);
    if (encodedKey.isNotEmpty) {
      writer
        ..writeTag(1, 2)
        ..writeBytes(encodedKey);
    }
    if (data.isNotEmpty) {
      writer
        ..writeTag(2, 2)
        ..writeBytes(data);
    }
    return writer.takeBytes();
  }

  void mergeFromBuffer(List<int> input) {
    final reader = WireReader(input);
    while (!reader.isAtEnd) {
      final tag = reader.readTag();
      final field = tag >> 3;
      final wireType = tag & 7;
      switch (field) {
        case 1:
          reader.requireWireType(wireType, 2);
          key = reader.readString();
        case 2:
          reader.requireWireType(wireType, 2);
          data = reader.readBytes();
        default:
          reader.skipField(wireType);
      }
    }
  }
}
