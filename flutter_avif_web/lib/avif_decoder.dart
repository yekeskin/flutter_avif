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
      'window.DecodeData = class DecodeData { constructor(data, width, height) { this.data = data; this.width = width; this.height = height; } };');
  _eval(
      'window.init_avif_decoder = function() { var promise = new Promise(function(resolve, reject) { window.Module().then(function(_module) { window.avif_decoder = _module; resolve(); }); }); return promise; }');

  final initBindgen = promiseToFuture(_initDecoder());
  await initBindgen;
}

Future<Frame> decodeSingleFrameImage(Uint8List data) async {
  final decoded = _decodeSingleFrameImage(data);

  return Frame(
    data: decoded.getProperty('data'.toJS) as Uint8List,
    duration: 1.0,
    width: decoded.getProperty('width'.toJS) as int,
    height: decoded.getProperty('height'.toJS) as int,
  );
}

@JS('window.init_avif_decoder')
external JSPromise _initDecoder();

@JS('window.eval')
external void _eval(String script);

@JS('window.avif_decoder.decodeSingleFrameImage')
external JSObject _decodeSingleFrameImage(Uint8List data);
