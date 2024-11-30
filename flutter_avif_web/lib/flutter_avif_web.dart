import 'dart:typed_data';

import 'package:flutter_avif_platform_interface/flutter_avif_platform_interface.dart';

import 'avif_encoder.dart' as wasm_encoder;
import 'avif_decoder.dart' as wasm_decoder;

class FlutterAvifWeb extends FlutterAvifPlatform {
  static void registerWith([Object? registrar]) async {
    FlutterAvifPlatform.api = FlutterAvifWebImpl();
    FlutterAvifPlatform.decode = decodeImage;
  }
}

class FlutterAvifWebImpl extends FlutterAvif {
  @override
  Future<Uint8List> encodeAvif({
    required int width,
    required int height,
    required int speed,
    required int maxThreads,
    required int timescale,
    required int maxQuantizer,
    required int minQuantizer,
    required int maxQuantizerAlpha,
    required int minQuantizerAlpha,
    required List<EncodeFrame> imageSequence,
    required Uint8List exifData,
    hint,
  }) async {
    if (!wasm_encoder.isScriptLoaded) {
      await wasm_encoder.loadScript();
    }

    final pixels = BytesBuilder();
    final List<int> durations = [];
    imageSequence.forEach((frame) {
      pixels.add(frame.data);
      durations.add(frame.durationInTimescale);
    });

    return wasm_encoder.encodeAvif(
      pixels: pixels.toBytes(),
      durations: Uint8List.fromList(durations),
      width: width,
      height: height,
      speed: speed,
      maxThreads: maxThreads,
      timescale: timescale,
      maxQuantizer: maxQuantizer,
      minQuantizer: minQuantizer,
      maxQuantizerAlpha: maxQuantizerAlpha,
      minQuantizerAlpha: minQuantizerAlpha,
      exifData: exifData,
    );
  }

  @override
  Future<Frame> decodeSingleFrameImage({
    required Uint8List avifBytes,
    hint,
  }) async {
    if (!wasm_decoder.isScriptLoaded) {
      await wasm_decoder.loadScript();
    }

    return await wasm_decoder.decodeSingleFrameImage(avifBytes);
  }

  @override
  Future<bool> disposeDecoder({required String key, hint}) async {
    if (!wasm_decoder.isScriptLoaded) {
      await wasm_decoder.loadScript();
    }

    return await wasm_decoder.disposeDecoder(key);
  }

  @override
  Future<Frame> getNextFrame({required String key, hint}) async {
    if (!wasm_decoder.isScriptLoaded) {
      await wasm_decoder.loadScript();
    }

    return await wasm_decoder.getNextFrame(key);
  }

  @override
  Future<AvifInfo> initMemoryDecoder({
    required String key,
    required Uint8List avifBytes,
    hint,
  }) async {
    if (!wasm_decoder.isScriptLoaded) {
      await wasm_decoder.loadScript();
    }

    return await wasm_decoder.initMemoryDecoder(key, avifBytes);
  }

  @override
  Future<bool> resetDecoder({required String key, hint}) async {
    if (!wasm_decoder.isScriptLoaded) {
      await wasm_decoder.loadScript();
    }

    return await wasm_decoder.resetDecoder(key);
  }
}

Future<DecodeData> decodeImage(Uint8List data, int orientation) async {
  if (!wasm_encoder.isScriptLoaded) {
    await wasm_encoder.loadScript();
  }

  return await wasm_encoder.decode(data, orientation);
}
