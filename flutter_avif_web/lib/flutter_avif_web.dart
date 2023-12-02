import 'package:flutter_avif_platform_interface/flutter_avif_platform_interface.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import 'avif_encoder.dart' as wasm_encoder;
import 'avif_decoder.dart' as wasm_decoder;

class FlutterAvifWeb extends FlutterAvifPlatform {
  static void registerWith([Object? registrar]) async {
    // FlutterAvifPlatform.useNativeDecoder = true;
    FlutterAvifPlatform.api = FlutterAvifWebImpl();
    FlutterAvifPlatform.decode = decodeImage;
  }
}

class FlutterAvifWebImpl extends FlutterAvif {
  static bool encoderScriptLoaded = false;
  static bool decoderScriptLoaded = false;

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
    hint,
  }) async {
    if (!FlutterAvifWebImpl.encoderScriptLoaded) {
      await wasm_encoder.loadScript();
      FlutterAvifWebImpl.encoderScriptLoaded = true;
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
    );
  }

  @override
  FlutterRustBridgeTaskConstMeta get kEncodeAvifConstMeta =>
      const FlutterRustBridgeTaskConstMeta(
        debugName: "encode_avif",
        argNames: [
          "width",
          "height",
          "speed",
          "maxThreads",
          "timescale",
          "maxQuantizer",
          "minQuantizer",
          "maxQuantizerAlpha",
          "minQuantizerAlpha",
          "imageSequence"
        ],
      );

  @override
  Future<Frame> decodeSingleFrameImage({
    required Uint8List avifBytes,
    hint,
  }) async {
    if (!FlutterAvifWebImpl.decoderScriptLoaded) {
      await wasm_decoder.loadScript();
      FlutterAvifWebImpl.decoderScriptLoaded = true;
    }

    return await wasm_decoder.decodeSingleFrameImage(avifBytes);
  }

  @override
  Future<bool> disposeDecoder({required String key, hint}) {
    throw UnimplementedError();
  }

  @override
  Future<Frame> getNextFrame({required String key, hint}) {
    throw UnimplementedError();
  }

  @override
  Future<AvifInfo> initMemoryDecoder(
      {required String key, required Uint8List avifBytes, hint}) {
    throw UnimplementedError();
  }

  @override
  FlutterRustBridgeTaskConstMeta get kDecodeSingleFrameImageConstMeta =>
      throw UnimplementedError();

  @override
  FlutterRustBridgeTaskConstMeta get kDisposeDecoderConstMeta =>
      throw UnimplementedError();

  @override
  FlutterRustBridgeTaskConstMeta get kGetNextFrameConstMeta =>
      throw UnimplementedError();

  @override
  FlutterRustBridgeTaskConstMeta get kInitMemoryDecoderConstMeta =>
      throw UnimplementedError();

  @override
  FlutterRustBridgeTaskConstMeta get kResetDecoderConstMeta =>
      throw UnimplementedError();

  @override
  Future<bool> resetDecoder({required String key, hint}) {
    throw UnimplementedError();
  }
}

Future<DecodeData> decodeImage(Uint8List data) async {
  if (!FlutterAvifWebImpl.scriptLoaded) {
    await wasm.loadScript();
    FlutterAvifWebImpl.scriptLoaded = true;
  }

  return await wasm_encoder.decode(data);
}
