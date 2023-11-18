import 'bridge_generated.io.dart'
    if (dart.library.html) 'bridge_generated.web.dart';
export 'bridge_generated.io.dart'
    if (dart.library.html) 'bridge_generated.web.dart';

abstract class FlutterAvifPlatform {
  static late final FlutterAvif api;
  static bool useNativeDecoder = false;
}
