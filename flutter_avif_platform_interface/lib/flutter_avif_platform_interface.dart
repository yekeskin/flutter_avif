import 'dart:typed_data';

import 'frb_generated.dart';
export 'frb_generated.dart';

abstract class FlutterAvifPlatform {
  static late final FlutterAvif api;
  static bool useNativeDecoder = false;
  static late final Future<DecodeData> Function(Uint8List, int) decode;
}

class DecodeData {
  final Uint8List data;
  final Uint32List durations;
  final int width;
  final int height;

  DecodeData({
    required this.data,
    required this.durations,
    required this.width,
    required this.height,
  });
}
