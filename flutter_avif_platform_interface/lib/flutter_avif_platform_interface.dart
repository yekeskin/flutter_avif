import 'dart:typed_data';

import 'flutter_avif_bridge.io.dart'
    if (dart.library.js_interop) 'flutter_avif_bridge.web.dart';
export 'flutter_avif_bridge.io.dart'
    if (dart.library.js_interop) 'flutter_avif_bridge.web.dart';
export 'models/avif_info.pb.dart';
export 'models/encode_frame.pb.dart';
export 'models/frame.pb.dart';

abstract class FlutterAvifPlatform {
  static late final FlutterAvif api;
  static bool useNativeDecoder = false;
  static late final Future<DecodeData> Function(Uint8List, int) decode;
}
