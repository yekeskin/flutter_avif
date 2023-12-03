@JS()
library MODULE;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter_avif_platform_interface/flutter_avif_platform_interface.dart';

import 'dart:async';
import 'dart:html';
import 'dart:js_util';
import 'dart:typed_data';

import 'package:js/js.dart';

Future<void> loadScript() async {
  final script = ScriptElement();
  script.src = 'packages/flutter_avif_web/web/avif_decoder.js';
  document.head!.append(script);
  await script.onLoad.first;

  _eval(
      'window.AvifInfo = class AvifInfo { constructor(width, height, imageCount, duration) { this.width = width; this.height = height; this.imageCount = imageCount; this.duration = duration; } };');
  _eval(
      'window.AvifFrame = class AvifFrame { constructor(data, width, height, duration) { this.data = data; this.width = width; this.height = height; this.duration = duration; } };');
  _eval(
      'window.init_avif_decoder = function() { var promise = new Promise(function(resolve, reject) { window.avif_decoder_wasm().then(function(_module) { window.avif_decoder = _module; resolve(); }); }); return promise; }');

  final initBindgen = promiseToFuture(_initDecoder());
  await initBindgen;
}

Future<Frame> decodeSingleFrameImage(Uint8List data) async {
  final decoded = _decodeSingleFrameImage(data);

  return Frame(
    data: decoded.getProperty('data'.toJS) as Uint8List,
    duration: decoded.getProperty('duration'.toJS) as double,
    width: decoded.getProperty('width'.toJS) as int,
    height: decoded.getProperty('height'.toJS) as int,
  );
}

Future<AvifInfo> initMemoryDecoder(String key, Uint8List data) async {
  final decoded = _initMemoryDecoder(key, data);

  return AvifInfo(
    width: decoded.getProperty('width'.toJS) as int,
    height: decoded.getProperty('height'.toJS) as int,
    imageCount: decoded.getProperty('imageCount'.toJS) as int,
    duration: decoded.getProperty('duration'.toJS) as double,
  );
}

Future<Frame> getNextFrame(String key) async {
  final decoded = _getNextFrame(key);

  return Frame(
    data: decoded.getProperty('data'.toJS) as Uint8List,
    duration: decoded.getProperty('duration'.toJS) as double,
    width: decoded.getProperty('width'.toJS) as int,
    height: decoded.getProperty('height'.toJS) as int,
  );
}

Future<bool> resetDecoder(String key) async {
  _resetDecoder(key);
  return true;
}

Future<bool> disposeDecoder(String key) async {
  _disposeDecoder(key);
  return true;
}

@JS('window.init_avif_decoder')
external JSPromise _initDecoder();

@JS('window.eval')
external void _eval(String script);

@JS('window.avif_decoder.decodeSingleFrameImage')
external JSObject _decodeSingleFrameImage(Uint8List data);

@JS('window.avif_decoder.initMemoryDecoder')
external JSObject _initMemoryDecoder(String key, Uint8List data);

@JS('window.avif_decoder.getNextFrame')
external JSObject _getNextFrame(String key);

@JS('window.avif_decoder.resetDecoder')
external JSObject _resetDecoder(String key);

@JS('window.avif_decoder.disposeDecoder')
external JSObject _disposeDecoder(String key);
