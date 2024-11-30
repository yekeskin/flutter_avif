@JS()
library wasm_bindgen;

import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';
import 'dart:ui_web';

import 'package:web/web.dart' as web;
import 'package:flutter_avif_platform_interface/flutter_avif_platform_interface.dart';

Completer? _scriptLoaderCompleter;

bool get isScriptLoaded =>
    _scriptLoaderCompleter != null && _scriptLoaderCompleter!.isCompleted;

Future<void> loadScript() async {
  if (_scriptLoaderCompleter != null) {
    return _scriptLoaderCompleter!.future;
  }

  _scriptLoaderCompleter = Completer();

  final assetManager = AssetManager();
  final script = web.HTMLScriptElement();
  script.src = assetManager
      .getAssetUrl('packages/flutter_avif_web/web/avif_encoder.loader.js');
  web.document.head!.append(script);
  await script.onLoad.first;

  final initBindgen = _initBindgen(assetManager
      .getAssetUrl('packages/flutter_avif_web/web/avif_encoder.worker.js').toJS).toDart;
  await initBindgen;

  _scriptLoaderCompleter!.complete();
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
  required Uint8List exifData,
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

  final result = await _encode(pixels.toJS, durations.toJS, options.toJS, exifData.toJS).toDart;

  return result.toDart;
}

Future<DecodeData> decode(Uint8List data, int orientation) async {
  final JSObject decoded = await _decode(data.toJS, orientation.toJS).toDart;
  final rgbaData = decoded.getProperty('data'.toJS) as JSArray<JSNumber>;
  final durations = decoded.getProperty('durations'.toJS) as JSArray<JSNumber>;

  return DecodeData(
    data: Uint8List.fromList(rgbaData.toDart.map((e) => e.toDartInt).toList()),
    durations: Uint32List.fromList(durations.toDart.map((e) => e.toDartInt).toList()),
    width: (decoded.getProperty('width'.toJS) as JSNumber).toDartInt,
    height: (decoded.getProperty('height'.toJS) as JSNumber).toDartInt,
  );
}

@JS('window.avifEncoderLoad')
external JSPromise _initBindgen(JSString workerPath);

@JS('window.avif_encoder.encode')
external JSPromise<JSUint8Array> _encode(
  JSUint8Array pixels,
  JSUint8Array durations,
  JSUint32Array options,
  JSUint8Array exifData,
);

@JS('window.avif_encoder.decode')
external JSPromise<JSObject> _decode(
  JSUint8Array data,
  JSNumber orientation,
);
