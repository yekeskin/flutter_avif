import 'dart:typed_data';

import 'wire_format.dart';

/// A decoded RGBA frame exchanged with the native bridge.
class Frame {
  Frame({List<int>? data, double? duration, int? width, int? height})
      : _data = data ?? Uint8List(0),
        _duration = duration ?? 0,
        _width = width ?? 0,
        _height = height ?? 0,
        _hasData = data != null,
        _hasDuration = duration != null,
        _hasWidth = width != null,
        _hasHeight = height != null;

  factory Frame.fromBuffer(List<int> input) => Frame()..mergeFromBuffer(input);

  List<int> _data;
  double _duration;
  int _width;
  int _height;
  bool _hasData;
  bool _hasDuration;
  bool _hasWidth;
  bool _hasHeight;

  List<int> get data => _data;
  set data(List<int> value) {
    _data = value;
    _hasData = true;
  }

  double get duration => _duration;
  set duration(double value) {
    _duration = value;
    _hasDuration = true;
  }

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

  bool hasData() => _hasData;
  bool hasDuration() => _hasDuration;
  bool hasWidth() => _hasWidth;
  bool hasHeight() => _hasHeight;

  void clearData() {
    _data = Uint8List(0);
    _hasData = false;
  }

  void clearDuration() {
    _duration = 0;
    _hasDuration = false;
  }

  void clearWidth() {
    _width = 0;
    _hasWidth = false;
  }

  void clearHeight() {
    _height = 0;
    _hasHeight = false;
  }

  static Frame create() => Frame();
  Frame createEmptyInstance() => Frame();
  static List<Frame> createRepeated() => <Frame>[];
  static final Frame _defaultInstance = Frame();
  static Frame getDefault() => _defaultInstance;

  Frame clone() => Frame(
        data: Uint8List.fromList(_data),
        duration: _duration,
        width: _width,
        height: _height,
      );

  Frame copyWith(void Function(Frame) updates) {
    final copy = clone();
    updates(copy);
    return copy;
  }

  void mergeFromMessage(Frame other) {
    if (other.hasData()) data = Uint8List.fromList(other.data);
    if (other.hasDuration()) duration = other.duration;
    if (other.hasWidth()) width = other.width;
    if (other.hasHeight()) height = other.height;
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
          reader.requireWireType(wireType, 1);
          duration = reader.readDouble();
        case 3:
          reader.requireWireType(wireType, 0);
          width = reader.readUint32();
        case 4:
          reader.requireWireType(wireType, 0);
          height = reader.readUint32();
        default:
          reader.skipField(wireType);
      }
    }
  }

  Uint8List writeToBuffer() {
    var length = 0;
    if (_data.isNotEmpty) length += bytesFieldSize(1, _data.length);
    if (_duration != 0) length += 1 + 8;
    if (_width != 0) length += varintFieldSize(3, _width);
    if (_height != 0) length += varintFieldSize(4, _height);

    final writer = WireWriter(length);
    if (_data.isNotEmpty) {
      writer
        ..writeTag(1, 2)
        ..writeBytes(_data);
    }
    if (_duration != 0) {
      writer
        ..writeTag(2, 1)
        ..writeDouble(_duration);
    }
    if (_width != 0) {
      writer
        ..writeTag(3, 0)
        ..writeVarint(_width);
    }
    if (_height != 0) {
      writer
        ..writeTag(4, 0)
        ..writeVarint(_height);
    }
    return writer.takeBytes();
  }
}
