import 'dart:typed_data';

import 'bridge_generated.io.dart'
    if (dart.library.html) 'bridge_generated.web.dart';
export 'bridge_generated.io.dart'
    if (dart.library.html) 'bridge_generated.web.dart';

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
