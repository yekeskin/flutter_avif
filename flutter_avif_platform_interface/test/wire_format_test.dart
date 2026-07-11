import 'dart:typed_data';

import 'package:flutter_avif_platform_interface/models/avif_info.pb.dart';
import 'package:flutter_avif_platform_interface/models/encode_frame.pb.dart';
import 'package:flutter_avif_platform_interface/models/encode_request.pb.dart';
import 'package:flutter_avif_platform_interface/models/frame.pb.dart';
import 'package:flutter_avif_platform_interface/models/key_request.pb.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('key request keeps the native bridge byte representation', () {
    final encoded = KeyRequest(key: 'a', data: [1, 2]).writeToBuffer();

    expect(encoded, [0x0a, 0x01, 0x61, 0x12, 0x02, 1, 2]);
    final decoded = KeyRequest.fromBuffer([...encoded, 0x78, 0x07]);
    expect(decoded.key, 'a');
    expect(decoded.data, [1, 2]);
  });

  test('encode request supports signed values and nested frames', () {
    final request = EncodeRequest(
      width: 300,
      height: 200,
      speed: -5,
      maxThreads: 4,
      timescale: 24,
      maxQuantizer: 40,
      minQuantizer: -1,
      maxQuantizerAlpha: 30,
      minQuantizerAlpha: 10,
      imageList: [
        EncodeFrame(data: [1, 2, 3], durationInTimescale: 2)
      ],
      exifData: [9, 8],
    );

    final decoded = EncodeRequest.fromBuffer(request.writeToBuffer());
    expect(decoded.width, 300);
    expect(decoded.height, 200);
    expect(decoded.speed, -5);
    expect(decoded.maxThreads, 4);
    expect(decoded.timescale, 24);
    expect(decoded.maxQuantizer, 40);
    expect(decoded.minQuantizer, -1);
    expect(decoded.maxQuantizerAlpha, 30);
    expect(decoded.minQuantizerAlpha, 10);
    expect(decoded.imageList.single.data, [1, 2, 3]);
    expect(decoded.imageList.single.durationInTimescale, 2);
    expect(decoded.exifData, [9, 8]);
  });

  test('large frame payloads decode without a configured size ceiling', () {
    final rgba = Uint8List(1024 * 1024)..[0] = 42;
    final frame = Frame(
      data: rgba,
      duration: 1.5,
      width: 512,
      height: 512,
    );

    final decoded = Frame.fromBuffer(frame.writeToBuffer());
    expect(decoded.data.length, rgba.length);
    expect(decoded.data.first, 42);
    expect(decoded.duration, 1.5);
    expect(decoded.width, 512);
    expect(decoded.height, 512);
  });

  test('decoder metadata round trips all fields', () {
    final info = AvifInfo(
      width: 1920,
      height: 1080,
      imageCount: 12,
      duration: 0.5,
    );

    final decoded = AvifInfo.fromBuffer(info.writeToBuffer());
    expect(decoded.width, 1920);
    expect(decoded.height, 1080);
    expect(decoded.imageCount, 12);
    expect(decoded.duration, 0.5);
  });

  test('malformed messages fail instead of reading out of bounds', () {
    expect(
      () => Frame.fromBuffer([0x0a, 0x05, 1]),
      throwsFormatException,
    );
    expect(
      () => Frame.fromBuffer(List<int>.filled(11, 0x80)),
      throwsFormatException,
    );
  });
}
