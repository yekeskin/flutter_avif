import 'dart:async';
import 'dart:ffi' as ffi;
import 'dart:ffi';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';

import 'package:flutter_avif_platform_interface/flutter_avif_ffi.dart'
    as fa_ffi;
import 'package:flutter_avif_platform_interface/models/avif_info.pb.dart';
import 'package:flutter_avif_platform_interface/models/encode_request.pb.dart';
import 'package:flutter_avif_platform_interface/models/frame.pb.dart';
import 'package:flutter_avif_platform_interface/models/key_request.pb.dart';
import 'package:flutter_avif_platform_interface/models/encode_frame.pb.dart';
export 'package:flutter_avif_platform_interface/models/encode_frame.pb.dart';

class FlutterAvifImpl implements FlutterAvif {
  final fa_ffi.FlutterAvifFFI flutterAvifFFI;

  FlutterAvifImpl(ffi.DynamicLibrary dyLib)
      : this.flutterAvifFFI = fa_ffi.FlutterAvifFFI(dyLib) {
    final storeDartPostCObject =
        dyLib.lookupFunction<dartPostCObject, dartPostCObject>(
      'store_dart_post_cobject',
    );
    storeDartPostCObject(NativeApi.postCObject);
  }

  @override
  Future<Frame> decodeSingleFrameImage({required Uint8List avifBytes}) {
    final request = KeyRequest(key: "", data: avifBytes).writeToBuffer();
    final nativeRequest = toPointer(request);

    final completer = Completer<Frame>();
    final port = RawReceivePort();
    port.handler = (response) {
      port.close();

      completer.complete(Frame.fromBuffer(response));
    };

    flutterAvifFFI.decode_single_frame_image(
      port.sendPort.nativePort,
      nativeRequest.$1,
      nativeRequest.$2,
    );

    malloc.free(nativeRequest.$1);

    return completer.future;
  }

  @override
  Future<bool> disposeDecoder({required String key}) {
    final request = KeyRequest(key: key).writeToBuffer();
    final nativeRequest = toPointer(request);

    final completer = Completer<bool>();
    final port = RawReceivePort();
    port.handler = (response) {
      port.close();

      completer.complete(response);
    };

    flutterAvifFFI.dispose_decoder(
      port.sendPort.nativePort,
      nativeRequest.$1,
      nativeRequest.$2,
    );

    malloc.free(nativeRequest.$1);

    return completer.future;
  }

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
  }) {
    final request = EncodeRequest(
      width: width,
      height: height,
      speed: speed,
      maxThreads: maxThreads,
      timescale: timescale,
      maxQuantizer: maxQuantizer,
      minQuantizer: minQuantizer,
      maxQuantizerAlpha: maxQuantizerAlpha,
      minQuantizerAlpha: minQuantizerAlpha,
      imageList: imageSequence,
      exifData: exifData,
    ).writeToBuffer();
    final nativeRequest = toPointer(request);

    final completer = Completer<Uint8List>();
    final port = RawReceivePort();
    port.handler = (response) {
      port.close();

      completer.complete(response);
    };

    flutterAvifFFI.encode_avif(
      port.sendPort.nativePort,
      nativeRequest.$1,
      nativeRequest.$2,
    );

    malloc.free(nativeRequest.$1);

    return completer.future;
  }

  @override
  Future<Frame> getNextFrame({required String key}) {
    final request = KeyRequest(key: key).writeToBuffer();
    final nativeRequest = toPointer(request);

    final completer = Completer<Frame>();
    final port = RawReceivePort();
    port.handler = (response) {
      port.close();

      completer.complete(Frame.fromBuffer(response));
    };

    flutterAvifFFI.get_next_frame(
      port.sendPort.nativePort,
      nativeRequest.$1,
      nativeRequest.$2,
    );

    malloc.free(nativeRequest.$1);

    return completer.future;
  }

  @override
  Future<AvifInfo> initMemoryDecoder({
    required String key,
    required Uint8List avifBytes,
  }) {
    final request = KeyRequest(key: key, data: avifBytes).writeToBuffer();
    final nativeRequest = toPointer(request);

    final completer = Completer<AvifInfo>();
    final port = RawReceivePort();
    port.handler = (response) {
      port.close();

      completer.complete(AvifInfo.fromBuffer(response));
    };

    flutterAvifFFI.init_memory_decoder(
      port.sendPort.nativePort,
      nativeRequest.$1,
      nativeRequest.$2,
    );
    malloc.free(nativeRequest.$1);

    return completer.future;
  }

  @override
  Future<bool> resetDecoder({required String key}) {
    final request = KeyRequest(key: key).writeToBuffer();
    final nativeRequest = toPointer(request);

    final completer = Completer<bool>();
    final port = RawReceivePort();
    port.handler = (response) {
      port.close();

      completer.complete(response);
    };

    flutterAvifFFI.reset_decoder(
      port.sendPort.nativePort,
      nativeRequest.$1,
      nativeRequest.$2,
    );

    malloc.free(nativeRequest.$1);

    return completer.future;
  }
}

abstract class FlutterAvif {
  Future<Frame> decodeSingleFrameImage({required Uint8List avifBytes});

  Future<AvifInfo> initMemoryDecoder({
    required String key,
    required Uint8List avifBytes,
  });

  Future<bool> resetDecoder({required String key});

  Future<bool> disposeDecoder({required String key});

  Future<Frame> getNextFrame({required String key});

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
  });
}

class DecodeData {
  final Uint8List data;
  final Uint32List durations;
  final int width;
  final int height;

  DecodeData({
    required this.data,
    required this.durations,
    required this.width,
    required this.height,
  });
}

(ffi.Pointer<ffi.UnsignedChar>, int) toPointer(Uint8List units) {
  final ffi.Pointer<ffi.UnsignedChar> result =
      malloc.allocate<ffi.UnsignedChar>(
    units.length,
  );

  final Uint8List nativeBytes = result.cast<ffi.Uint8>().asTypedList(
        units.length,
      );
  nativeBytes.setAll(0, units);
  return (result, units.length);
}

typedef dartPostCObject = Pointer Function(
  Pointer<NativeFunction<Int8 Function(Int64, Pointer<Dart_CObject>)>>,
);
