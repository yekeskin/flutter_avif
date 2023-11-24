import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter_avif_platform_interface/flutter_avif_platform_interface.dart'
    as avif_platform;

Future<Uint8List> encodeAvif(
  Uint8List input, {
  maxThreads = 4,
  speed = 10,
  maxQuantizer = 40,
  minQuantizer = 25,
  maxQuantizerAlpha = 40,
  minQuantizerAlpha = 25,
}) async {
  final avifFfi = avif_platform.FlutterAvifPlatform.api;
  final List<avif_platform.EncodeFrame> encodeFrames = [];
  int averageFps = 0, width = 0, height = 0;

  if (kIsWeb) {
    final decoded = await avif_platform.FlutterAvifPlatform.decode(input);
    int totalDurationMs = 0;
    int frameSize = decoded.width * decoded.height * 4;

    width = decoded.width;
    height = decoded.height;

    for (int i = 0; i < decoded.durations.length; i += 1) {
      totalDurationMs += decoded.durations[i];
    }

    averageFps = decoded.durations.length > 1 && totalDurationMs > 0
        ? (1000 * decoded.durations.length / totalDurationMs).round()
        : 1;
    final timebaseMs = (1000 / averageFps).round();

    for (int i = 0; i < decoded.durations.length; i += 1) {
      final frame = decoded.data.sublist(i * frameSize, (i + 1) * frameSize);
      encodeFrames.add(avif_platform.EncodeFrame(
        data: frame,
        durationInTimescale: (decoded.durations[i] / timebaseMs).round(),
      ));
    }
  } else {
    final decoder = await ui.instantiateImageCodec(input);
    final List<ui.FrameInfo> frames = [];
    int totalDurationMs = 0;
    for (int i = 0; i < decoder.frameCount; i += 1) {
      final frame = await decoder.getNextFrame();
      totalDurationMs += frame.duration.inMilliseconds;
      frames.add(frame);
    }

    width = frames[0].image.width;
    height = frames[0].image.height;
    averageFps = decoder.frameCount > 1 && totalDurationMs > 0
        ? (1000 * decoder.frameCount / totalDurationMs).round()
        : 1;
    final timebaseMs = (1000 / averageFps).round();

    for (int i = 0; i < frames.length; i += 1) {
      final imageData =
          await frames[i].image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (imageData != null) {
        encodeFrames.add(avif_platform.EncodeFrame(
          data: imageData.buffer.asUint8List(),
          durationInTimescale:
              (frames[i].duration.inMilliseconds / timebaseMs).round(),
        ));
      }
    }
  }

  final output = await avifFfi.encodeAvif(
    width: width,
    height: height,
    maxThreads: maxThreads,
    speed: speed,
    timescale: averageFps,
    maxQuantizer: maxQuantizer,
    minQuantizer: minQuantizer,
    maxQuantizerAlpha: maxQuantizerAlpha,
    minQuantizerAlpha: minQuantizerAlpha,
    imageSequence: encodeFrames,
  );

  return output;
}
