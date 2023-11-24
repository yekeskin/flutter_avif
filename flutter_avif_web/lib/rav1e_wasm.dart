@JS()
library wasm_bindgen;

import 'dart:js_interop_unsafe';
import 'package:flutter_avif_platform_interface/flutter_avif_platform_interface.dart';

import 'dart:async';
import 'dart:html';
import 'dart:js_interop';
import 'dart:js_util';
import 'dart:typed_data';

import 'package:js/js.dart';

Future<void> loadScript() async {
  final script = ScriptElement();
  script.src = 'packages/flutter_avif_web/web/rav1e_wasm.js';
  document.head!.append(script);
  await script.onLoad.first;
  _eval('window.rav1e_wasm = wasm_bindgen');

  final initBindgen = promiseToFuture(_initBindgen());
  await initBindgen;
}

Future<Uint8List> encodeAvif({
  required Uint8List pixels,
  required Uint8List durations,
  required int width,
  required int height,
  required int speed,
  required int maxThreads,
  required int timescale,
  required int maxQuantizer,
  required int minQuantizer,
  required int maxQuantizerAlpha,
  required int minQuantizerAlpha,
}) async {
  final options = Uint32List.fromList([
    width,
    height,
    speed,
    maxThreads,
    timescale,
    maxQuantizer,
    minQuantizer,
    maxQuantizerAlpha,
    minQuantizerAlpha,
  ]);
  return _encode(pixels, durations, options);
}

Future<DecodeData> decode(Uint8List data) async {
  final decoded = _decode(data);
  final rgbaData = decoded.getProperty('data'.toJS) as List<dynamic>;
  final durations = decoded.getProperty('durations'.toJS) as List<dynamic>;

  return DecodeData(
    data: Uint8List.fromList(rgbaData.cast<int>()),
    durations: Uint32List.fromList(durations.cast<int>()),
    width: decoded.getProperty('width'.toJS) as int,
    height: decoded.getProperty('height'.toJS) as int,
  );
}

@JS('window.eval')
external void _eval(String script);

@JS('window.rav1e_wasm')
external JSPromise _initBindgen();

@JS('window.rav1e_wasm.encode')
external Uint8List _encode(
  Uint8List pixels,
  Uint8List durations,
  Uint32List options,
);

@JS('window.rav1e_wasm.decode')
external JSObject _decode(
  Uint8List data,
);
