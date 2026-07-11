import 'dart:typed_data';

import 'wire_format.dart';

/// An RGBA frame supplied to the AVIF encoder.
class EncodeFrame {
  EncodeFrame({List<int>? data, int? durationInTimescale})
      : data = data ?? Uint8List(0),
        durationInTimescale = durationInTimescale ?? 0;

  factory EncodeFrame.fromBuffer(List<int> input) =>
      EncodeFrame()..mergeFromBuffer(input);

  List<int> data;
  int durationInTimescale;

  bool hasData() => data.isNotEmpty;
  bool hasDurationInTimescale() => durationInTimescale != 0;
  void clearData() => data = Uint8List(0);
  void clearDurationInTimescale() => durationInTimescale = 0;

  static EncodeFrame create() => EncodeFrame();
  EncodeFrame createEmptyInstance() => EncodeFrame();
  static List<EncodeFrame> createRepeated() => <EncodeFrame>[];
  static final EncodeFrame _defaultInstance = EncodeFrame();
  static EncodeFrame getDefault() => _defaultInstance;

  EncodeFrame clone() => EncodeFrame(
        data: Uint8List.fromList(data),
        durationInTimescale: durationInTimescale,
      );

  EncodeFrame copyWith(void Function(EncodeFrame) updates) {
    final copy = clone();
    updates(copy);
    return copy;
  }

  void mergeFromMessage(EncodeFrame other) {
    if (other.data.isNotEmpty) data = Uint8List.fromList(other.data);
    if (other.durationInTimescale != 0) {
      durationInTimescale = other.durationInTimescale;
    }
  }

  int get wireSize {
    var length = 0;
    if (data.isNotEmpty) length += bytesFieldSize(1, data.length);
    if (durationInTimescale != 0) {
      length += varintFieldSize(2, durationInTimescale);
    }
    return length;
  }

  void writeTo(WireWriter writer) {
    if (data.isNotEmpty) {
      writer
        ..writeTag(1, 2)
        ..writeBytes(data);
    }
    if (durationInTimescale != 0) {
      writer
        ..writeTag(2, 0)
        ..writeVarint(durationInTimescale);
    }
  }

  Uint8List writeToBuffer() {
    final writer = WireWriter(wireSize);
    writeTo(writer);
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
          data = reader.readBytes();
        case 2:
          reader.requireWireType(wireType, 0);
          durationInTimescale = reader.readUint32();
        default:
          reader.skipField(wireType);
      }
    }
  }
}
