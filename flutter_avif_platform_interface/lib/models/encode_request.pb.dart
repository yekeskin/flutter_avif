import 'dart:typed_data';

import 'encode_frame.pb.dart';
import 'wire_format.dart';

/// Parameters and RGBA frames supplied to the native AVIF encoder.
class EncodeRequest {
  EncodeRequest({
    int? width,
    int? height,
    int? speed,
    int? maxThreads,
    int? timescale,
    int? maxQuantizer,
    int? minQuantizer,
    int? maxQuantizerAlpha,
    int? minQuantizerAlpha,
    Iterable<EncodeFrame>? imageList,
    List<int>? exifData,
  })  : width = width ?? 0,
        height = height ?? 0,
        speed = speed ?? 0,
        maxThreads = maxThreads ?? 0,
        timescale = timescale ?? 0,
        maxQuantizer = maxQuantizer ?? 0,
        minQuantizer = minQuantizer ?? 0,
        maxQuantizerAlpha = maxQuantizerAlpha ?? 0,
        minQuantizerAlpha = minQuantizerAlpha ?? 0,
        imageList = imageList?.toList() ?? <EncodeFrame>[],
        exifData = exifData ?? Uint8List(0);

  factory EncodeRequest.fromBuffer(List<int> input) =>
      EncodeRequest()..mergeFromBuffer(input);

  int width;
  int height;
  int speed;
  int maxThreads;
  int timescale;
  int maxQuantizer;
  int minQuantizer;
  int maxQuantizerAlpha;
  int minQuantizerAlpha;
  final List<EncodeFrame> imageList;
  List<int> exifData;

  static EncodeRequest create() => EncodeRequest();
  EncodeRequest createEmptyInstance() => EncodeRequest();
  static List<EncodeRequest> createRepeated() => <EncodeRequest>[];
  static final EncodeRequest _defaultInstance = EncodeRequest();
  static EncodeRequest getDefault() => _defaultInstance;

  bool hasWidth() => width != 0;
  bool hasHeight() => height != 0;
  bool hasSpeed() => speed != 0;
  bool hasMaxThreads() => maxThreads != 0;
  bool hasTimescale() => timescale != 0;
  bool hasMaxQuantizer() => maxQuantizer != 0;
  bool hasMinQuantizer() => minQuantizer != 0;
  bool hasMaxQuantizerAlpha() => maxQuantizerAlpha != 0;
  bool hasMinQuantizerAlpha() => minQuantizerAlpha != 0;
  bool hasExifData() => exifData.isNotEmpty;
  void clearWidth() => width = 0;
  void clearHeight() => height = 0;
  void clearSpeed() => speed = 0;
  void clearMaxThreads() => maxThreads = 0;
  void clearTimescale() => timescale = 0;
  void clearMaxQuantizer() => maxQuantizer = 0;
  void clearMinQuantizer() => minQuantizer = 0;
  void clearMaxQuantizerAlpha() => maxQuantizerAlpha = 0;
  void clearMinQuantizerAlpha() => minQuantizerAlpha = 0;
  void clearExifData() => exifData = Uint8List(0);

  EncodeRequest clone() => EncodeRequest(
        width: width,
        height: height,
        speed: speed,
        maxThreads: maxThreads,
        timescale: timescale,
        maxQuantizer: maxQuantizer,
        minQuantizer: minQuantizer,
        maxQuantizerAlpha: maxQuantizerAlpha,
        minQuantizerAlpha: minQuantizerAlpha,
        imageList: imageList.map((frame) => frame.clone()),
        exifData: Uint8List.fromList(exifData),
      );

  EncodeRequest copyWith(void Function(EncodeRequest) updates) {
    final copy = clone();
    updates(copy);
    return copy;
  }

  void mergeFromMessage(EncodeRequest other) {
    if (other.width != 0) width = other.width;
    if (other.height != 0) height = other.height;
    if (other.speed != 0) speed = other.speed;
    if (other.maxThreads != 0) maxThreads = other.maxThreads;
    if (other.timescale != 0) timescale = other.timescale;
    if (other.maxQuantizer != 0) maxQuantizer = other.maxQuantizer;
    if (other.minQuantizer != 0) minQuantizer = other.minQuantizer;
    if (other.maxQuantizerAlpha != 0) {
      maxQuantizerAlpha = other.maxQuantizerAlpha;
    }
    if (other.minQuantizerAlpha != 0) {
      minQuantizerAlpha = other.minQuantizerAlpha;
    }
    imageList.addAll(other.imageList.map((frame) => frame.clone()));
    if (other.exifData.isNotEmpty) {
      exifData = Uint8List.fromList(other.exifData);
    }
  }

  Uint8List writeToBuffer() {
    var length = 0;
    if (width != 0) length += varintFieldSize(1, width);
    if (height != 0) length += varintFieldSize(2, height);
    if (speed != 0) length += varintFieldSize(3, zigZagEncode32(speed));
    if (maxThreads != 0) {
      length += varintFieldSize(4, zigZagEncode32(maxThreads));
    }
    if (timescale != 0) length += varintFieldSize(5, timescale);
    if (maxQuantizer != 0) {
      length += varintFieldSize(6, zigZagEncode32(maxQuantizer));
    }
    if (minQuantizer != 0) {
      length += varintFieldSize(7, zigZagEncode32(minQuantizer));
    }
    if (maxQuantizerAlpha != 0) {
      length += varintFieldSize(8, zigZagEncode32(maxQuantizerAlpha));
    }
    if (minQuantizerAlpha != 0) {
      length += varintFieldSize(9, zigZagEncode32(minQuantizerAlpha));
    }
    for (final frame in imageList) {
      length += bytesFieldSize(10, frame.wireSize);
    }
    if (exifData.isNotEmpty) length += bytesFieldSize(11, exifData.length);

    final writer = WireWriter(length);
    _writeUnsigned(writer, 1, width);
    _writeUnsigned(writer, 2, height);
    _writeSigned(writer, 3, speed);
    _writeSigned(writer, 4, maxThreads);
    _writeUnsigned(writer, 5, timescale);
    _writeSigned(writer, 6, maxQuantizer);
    _writeSigned(writer, 7, minQuantizer);
    _writeSigned(writer, 8, maxQuantizerAlpha);
    _writeSigned(writer, 9, minQuantizerAlpha);
    for (final frame in imageList) {
      writer
        ..writeTag(10, 2)
        ..writeVarint(frame.wireSize);
      frame.writeTo(writer);
    }
    if (exifData.isNotEmpty) {
      writer
        ..writeTag(11, 2)
        ..writeBytes(exifData);
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
          reader.requireWireType(wireType, 0);
          width = reader.readUint32();
        case 2:
          reader.requireWireType(wireType, 0);
          height = reader.readUint32();
        case 3:
          reader.requireWireType(wireType, 0);
          speed = zigZagDecode32(reader.readVarint());
        case 4:
          reader.requireWireType(wireType, 0);
          maxThreads = zigZagDecode32(reader.readVarint());
        case 5:
          reader.requireWireType(wireType, 0);
          timescale = reader.readUint32();
        case 6:
          reader.requireWireType(wireType, 0);
          maxQuantizer = zigZagDecode32(reader.readVarint());
        case 7:
          reader.requireWireType(wireType, 0);
          minQuantizer = zigZagDecode32(reader.readVarint());
        case 8:
          reader.requireWireType(wireType, 0);
          maxQuantizerAlpha = zigZagDecode32(reader.readVarint());
        case 9:
          reader.requireWireType(wireType, 0);
          minQuantizerAlpha = zigZagDecode32(reader.readVarint());
        case 10:
          reader.requireWireType(wireType, 2);
          final nested = reader.readMessage();
          imageList.add(EncodeFrame.fromBuffer(nested.bytes));
        case 11:
          reader.requireWireType(wireType, 2);
          exifData = reader.readBytes();
        default:
          reader.skipField(wireType);
      }
    }
  }

  static void _writeUnsigned(WireWriter writer, int field, int value) {
    if (value != 0) {
      writer
        ..writeTag(field, 0)
        ..writeVarint(value);
    }
  }

  static void _writeSigned(WireWriter writer, int field, int value) {
    if (value != 0) {
      writer
        ..writeTag(field, 0)
        ..writeVarint(zigZagEncode32(value));
    }
  }
}
