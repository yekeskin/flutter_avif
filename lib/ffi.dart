import 'dart:ffi';

import 'bridge_generated.dart';

// Re-export the bridge so it is only necessary to import this file.
export 'bridge_generated.dart';
import 'dart:io' as io;

const _base = 'flutter_avif';

final _dylib = io.Platform.isWindows
    ? '$_base.dll'
    : io.Platform.isMacOS
        ? 'lib$_base.dylib'
        : 'lib$_base.so';

// The late modifier delays initializing the value until it is actually needed,
// leaving precious little time for the program to quickly start up.
late final FlutterAvif api = FlutterAvifImpl(io.Platform.isIOS
    ? DynamicLibrary.executable()
    : DynamicLibrary.open(_dylib));
