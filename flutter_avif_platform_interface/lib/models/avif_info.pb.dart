import 'dart:typed_data';

import 'wire_format.dart';

/// Metadata for an initialized AVIF decoder.
class AvifInfo {
  AvifInfo({int? width, int? height, int? imageCount, double? duration})
      : _width = width ?? 0,
        _height = height ?? 0,
        _imageCount = imageCount ?? 0,
        _duration = duration ?? 0,
        _hasWidth = width != null,
        _hasHeight = height != null,
        _hasImageCount = imageCount != null,
        _hasDuration = duration != null;

  factory AvifInfo.fromBuffer(List<int> input) =>
      AvifInfo()..mergeFromBuffer(input);

  int _width;
  int _height;
  int _imageCount;
  double _duration;
  bool _hasWidth;
  bool _hasHeight;
  bool _hasImageCount;
  bool _hasDuration;

  int get width => _width;
  set width(int value) {
    _width = value;
    _hasWidth = true;
  }

  int get height => _height;
  set height(int value) {
    _height = value;
    _hasHeight = true;
  }

  int get imageCount => _imageCount;
  set imageCount(int value) {
    _imageCount = value;
    _hasImageCount = true;
  }

  double get duration => _duration;
  set duration(double value) {
    _duration = value;
    _hasDuration = true;
  }

  bool hasWidth() => _hasWidth;
  bool hasHeight() => _hasHeight;
  bool hasImageCount() => _hasImageCount;
  bool hasDuration() => _hasDuration;

  void clearWidth() {
    _width = 0;
    _hasWidth = false;
  }

  void clearHeight() {
    _height = 0;
    _hasHeight = false;
  }

  void clearImageCount() {
    _imageCount = 0;
    _hasImageCount = false;
  }

  void clearDuration() {
    _duration = 0;
    _hasDuration = false;
  }

  static AvifInfo create() => AvifInfo();
  AvifInfo createEmptyInstance() => AvifInfo();
  static List<AvifInfo> createRepeated() => <AvifInfo>[];
  static final AvifInfo _defaultInstance = AvifInfo();
  static AvifInfo getDefault() => _defaultInstance;

  AvifInfo clone() => AvifInfo(
        width: _width,
        height: _height,
        imageCount: _imageCount,
        duration: _duration,
      );

  AvifInfo copyWith(void Function(AvifInfo) updates) {
    final copy = clone();
    updates(copy);
    return copy;
  }

  void mergeFromMessage(AvifInfo other) {
    if (other.hasWidth()) width = other.width;
    if (other.hasHeight()) height = other.height;
    if (other.hasImageCount()) imageCount = other.imageCount;
    if (other.hasDuration()) duration = other.duration;
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
          imageCount = reader.readUint32();
        case 4:
          reader.requireWireType(wireType, 1);
          duration = reader.readDouble();
        default:
          reader.skipField(wireType);
      }
    }
  }

  Uint8List writeToBuffer() {
    var length = 0;
    if (_width != 0) length += varintFieldSize(1, _width);
    if (_height != 0) length += varintFieldSize(2, _height);
    if (_imageCount != 0) length += varintFieldSize(3, _imageCount);
    if (_duration != 0) length += 1 + 8;

    final writer = WireWriter(length);
    if (_width != 0) {
      writer
        ..writeTag(1, 0)
        ..writeVarint(_width);
    }
    if (_height != 0) {
      writer
        ..writeTag(2, 0)
        ..writeVarint(_height);
    }
    if (_imageCount != 0) {
      writer
        ..writeTag(3, 0)
        ..writeVarint(_imageCount);
    }
    if (_duration != 0) {
      writer
        ..writeTag(4, 1)
        ..writeDouble(_duration);
    }
    return writer.takeBytes();
  }
}
