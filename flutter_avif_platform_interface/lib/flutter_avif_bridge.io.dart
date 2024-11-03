import 'dart:ffi' as ffi;
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
      : this.flutterAvifFFI = fa_ffi.FlutterAvifFFI(dyLib);

  @override
  Future<Frame> decodeSingleFrameImage({required Uint8List avifBytes}) async {
    final request = KeyRequest(
      key: "",
      data: avifBytes,
    ).writeToBuffer();
    final nativeRequest = toPointer(request);

    final result = flutterAvifFFI.decode_single_frame_image(
      nativeRequest[0],
      nativeRequest[1],
    );
    final frameBuffer = fromDartData(result);
    final frame = Frame.fromBuffer(frameBuffer);

    flutterAvifFFI.free_dart_data(result);
    malloc.free(nativeRequest[0]);

    return frame;
  }

  @override
  Future<bool> disposeDecoder({required String key}) async {
    final request = KeyRequest(
      key: key,
      data: Uint8List.fromList([1]),
    ).writeToBuffer();
    final nativeRequest = toPointer(request);

    final result = flutterAvifFFI.dispose_decoder(
      nativeRequest[0],
      nativeRequest[1],
    );

    malloc.free(nativeRequest[0]);

    return result;
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
  }) async {
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

    final result = flutterAvifFFI.encode_avif(
      nativeRequest[0],
      nativeRequest[1],
    );
    final bytes = fromDartData(result);

    flutterAvifFFI.free_dart_data(result);
    malloc.free(nativeRequest[0]);

    return bytes;
  }

  @override
  Future<Frame> getNextFrame({required String key}) async {
    final request = KeyRequest(
      key: key,
      data: Uint8List.fromList([1]),
    ).writeToBuffer();
    final nativeRequest = toPointer(request);

    final result = flutterAvifFFI.get_next_frame(
      nativeRequest[0],
      nativeRequest[1],
    );
    final frameBuffer = fromDartData(result);
    final frame = Frame.fromBuffer(frameBuffer);

    flutterAvifFFI.free_dart_data(result);
    malloc.free(nativeRequest[0]);

    return frame;
  }

  @override
  Future<AvifInfo> initMemoryDecoder({
    required String key,
    required Uint8List avifBytes,
  }) async {
    final request = KeyRequest(
      key: key,
      data: avifBytes,
    ).writeToBuffer();
    final nativeRequest = toPointer(request);

    final result = flutterAvifFFI.init_memory_decoder(
      nativeRequest[0],
      nativeRequest[1],
    );
    final resultBuffer = fromDartData(result);
    final info = AvifInfo.fromBuffer(resultBuffer);

    flutterAvifFFI.free_dart_data(result);
    malloc.free(nativeRequest[0]);

    return info;
  }

  @override
  Future<bool> resetDecoder({required String key}) async {
    final request = KeyRequest(
      key: key,
      data: Uint8List.fromList([1]),
    ).writeToBuffer();
    final nativeRequest = toPointer(request);

    final result = flutterAvifFFI.reset_decoder(
      nativeRequest[0],
      nativeRequest[1],
    );

    malloc.free(nativeRequest[0]);

    return result;
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

List toPointer(Uint8List units) {
  final ffi.Pointer<ffi.Uint8> result = malloc.allocate<ffi.Uint8>(
    units.length + 1,
  );

  final Uint8List nativeBytes = result.asTypedList(units.length + 1);
  nativeBytes.setAll(0, units);
  nativeBytes[units.length] = 0;
  ffi.Pointer<ffi.Uint8> data = result.cast();
  int dataLength = units.length;

  return [data, dataLength];
}

Uint8List fromDartData(fa_ffi.DartData data) {
  return Uint8List.fromList(data.ptr.asTypedList(data.len));
}
