import 'dart:typed_data';

import 'package:flutter_avif_platform_interface/models/avif_info.pb.dart';
export 'package:flutter_avif_platform_interface/models/avif_info.pb.dart';
import 'package:flutter_avif_platform_interface/models/frame.pb.dart';
export 'package:flutter_avif_platform_interface/models/frame.pb.dart';
import 'package:flutter_avif_platform_interface/models/encode_frame.pb.dart';
export 'package:flutter_avif_platform_interface/models/encode_frame.pb.dart';

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
