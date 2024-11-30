@JS()
library MODULE;

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
      .getAssetUrl('packages/flutter_avif_web/web/avif_decoder.loader.js');
  web.document.head!.append(script);
  await script.onLoad.first;

  final initBindgen = _initBindgen(assetManager
      .getAssetUrl('packages/flutter_avif_web/web/avif_decoder.worker.js').toJS).toDart;
  await initBindgen;

  _scriptLoaderCompleter!.complete();
}

Future<Frame> decodeSingleFrameImage(Uint8List data) async {
  final JSObject decoded = await _decodeSingleFrameImage(data.toJS).toDart;

  return Frame(
    data: (decoded.getProperty('data'.toJS) as JSUint8Array).toDart,
    duration: (decoded.getProperty('duration'.toJS) as JSNumber).toDartDouble,
    width: (decoded.getProperty('width'.toJS) as JSNumber).toDartInt,
    height: (decoded.getProperty('height'.toJS) as JSNumber).toDartInt,
  );
}

Future<AvifInfo> initMemoryDecoder(String key, Uint8List data) async {
  final JSObject decoded = await _initMemoryDecoder(key.toJS, data.toJS).toDart;

  return AvifInfo(
    width: (decoded.getProperty('width'.toJS) as JSNumber).toDartInt,
    height: (decoded.getProperty('height'.toJS) as JSNumber).toDartInt,
    imageCount: (decoded.getProperty('imageCount'.toJS) as JSNumber).toDartInt,
    duration: (decoded.getProperty('duration'.toJS) as JSNumber).toDartDouble,
  );
}

Future<Frame> getNextFrame(String key) async {
  final JSObject decoded = await _getNextFrame(key.toJS).toDart;

  return Frame(
    data: (decoded.getProperty('data'.toJS) as JSUint8Array).toDart,
    duration: (decoded.getProperty('duration'.toJS) as JSNumber).toDartDouble,
    width: (decoded.getProperty('width'.toJS) as JSNumber).toDartInt,
    height: (decoded.getProperty('height'.toJS) as JSNumber).toDartInt,
  );
}

Future<bool> resetDecoder(String key) async {
  await _resetDecoder(key.toJS).toDart;
  return true;
}

Future<bool> disposeDecoder(String key) async {
  await _disposeDecoder(key.toJS).toDart;
  return true;
}

@JS('window.avifDecoderLoad')
external JSPromise _initBindgen(JSString workerPath);

@JS('window.avif_decoder.decodeSingleFrameImage')
external JSPromise<JSObject> _decodeSingleFrameImage(JSUint8Array data);

@JS('window.avif_decoder.initMemoryDecoder')
external JSPromise<JSObject> _initMemoryDecoder(JSString key, JSUint8Array data);

@JS('window.avif_decoder.getNextFrame')
external JSPromise<JSObject> _getNextFrame(JSString key);

@JS('window.avif_decoder.resetDecoder')
external JSPromise _resetDecoder(JSString key);

@JS('window.avif_decoder.disposeDecoder')
external JSPromise _disposeDecoder(JSString key);
