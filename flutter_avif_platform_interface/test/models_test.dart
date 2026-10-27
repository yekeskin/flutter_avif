import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_avif_platform_interface/models/avif_info.pb.dart';
import 'package:flutter_avif_platform_interface/models/encode_frame.pb.dart';
import 'package:flutter_avif_platform_interface/models/encode_request.pb.dart';
import 'package:flutter_avif_platform_interface/models/frame.pb.dart';
import 'package:flutter_avif_platform_interface/models/key_request.pb.dart';

void main() {
  test('AvifInfo round-trip', () {
    final m = AvifInfo(width: 640, height: 480, imageCount: 3, duration: 1.5);
    expect(AvifInfo.fromBuffer(m.writeToBuffer()), m);
  });
  test('Frame round-trip', () {
    final m = Frame(data: Uint8List.fromList([1, 2, 3]), duration: 0.25);
    expect(Frame.fromBuffer(m.writeToBuffer()), m);
  });
  test('other messages round-trip', () {
    expect(EncodeFrame.fromBuffer(EncodeFrame().writeToBuffer()), EncodeFrame());
    expect(EncodeRequest.fromBuffer(EncodeRequest().writeToBuffer()), EncodeRequest());
    expect(KeyRequest.fromBuffer(KeyRequest().writeToBuffer()), KeyRequest());
  });
}
