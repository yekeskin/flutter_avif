@JS()
library MODULE;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:ui_web';

import 'package:flutter_avif_platform_interface/flutter_avif_platform_interface.dart';

import 'dart:async';
import 'dart:html';
import 'dart:js_util';
import 'dart:typed_data';

import 'package:js/js.dart';

Completer? _scriptLoaderCompleter;

bool get isScriptLoaded =>
    _scriptLoaderCompleter != null && _scriptLoaderCompleter!.isCompleted;

Future<void> loadScript() async {
  if (_scriptLoaderCompleter != null) {
    return _scriptLoaderCompleter!.future;
  }

  _scriptLoaderCompleter = Completer();

  final assetManager = AssetManager();
  final script = ScriptElement();
  script.src = assetManager
      .getAssetUrl('packages/flutter_avif_web/web/avif_decoder.loader.js');
  document.head!.append(script);
  await script.onLoad.first;

  final initBindgen = promiseToFuture(_initBindgen(assetManager
      .getAssetUrl('packages/flutter_avif_web/web/avif_decoder.worker.js')));
  await initBindgen;

  _scriptLoaderCompleter!.complete();
}

Future<Frame> decodeSingleFrameImage(Uint8List data) async {
  final JSObject decoded = await promiseToFuture(_decodeSingleFrameImage(data));

  return Frame(
    data: decoded.getProperty('data'.toJS) as Uint8List,
    duration: decoded.getProperty('duration'.toJS) as double,
    width: decoded.getProperty('width'.toJS) as int,
    height: decoded.getProperty('height'.toJS) as int,
  );
}

Future<AvifInfo> initMemoryDecoder(String key, Uint8List data) async {
  final JSObject decoded = await promiseToFuture(_initMemoryDecoder(key, data));

  return AvifInfo(
    width: decoded.getProperty('width'.toJS) as int,
    height: decoded.getProperty('height'.toJS) as int,
    imageCount: decoded.getProperty('imageCount'.toJS) as int,
    duration: decoded.getProperty('duration'.toJS) as double,
  );
}

Future<Frame> getNextFrame(String key) async {
  final JSObject decoded = await promiseToFuture(_getNextFrame(key));

  return Frame(
    data: decoded.getProperty('data'.toJS) as Uint8List,
    duration: decoded.getProperty('duration'.toJS) as double,
    width: decoded.getProperty('width'.toJS) as int,
    height: decoded.getProperty('height'.toJS) as int,
  );
}

Future<bool> resetDecoder(String key) async {
  await promiseToFuture(_resetDecoder(key));
  return true;
}

Future<bool> disposeDecoder(String key) async {
  await promiseToFuture(_disposeDecoder(key));
  return true;
}

@JS('window.avifDecoderLoad')
external JSPromise _initBindgen(String workerPath);

@JS('window.avif_decoder.decodeSingleFrameImage')
external JSPromise _decodeSingleFrameImage(Uint8List data);

@JS('window.avif_decoder.initMemoryDecoder')
external JSPromise _initMemoryDecoder(String key, Uint8List data);

@JS('window.avif_decoder.getNextFrame')
external JSPromise _getNextFrame(String key);

@JS('window.avif_decoder.resetDecoder')
external JSPromise _resetDecoder(String key);

@JS('window.avif_decoder.disposeDecoder')
external JSPromise _disposeDecoder(String key);
