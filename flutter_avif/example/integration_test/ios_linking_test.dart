import 'dart:ffi';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_avif/flutter_avif.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('iOS retains the codec entry points and loads an AVIF frame',
      (tester) async {
    final library = DynamicLibrary.executable();
    for (final symbol in [
      'store_dart_post_cobject',
      'decode_single_frame_image',
      'init_memory_decoder',
      'reset_decoder',
      'dispose_decoder',
      'get_next_frame',
      'encode_avif',
    ]) {
      expect(library.providesSymbol(symbol), isTrue, reason: symbol);
    }

    await tester.runAsync(() async {
      final asset = await rootBundle.load('assets/vettel.avif');
      final codec = MultiFrameAvifCodec(
        key: 1,
        avifBytes: asset.buffer.asUint8List(),
      );
      try {
        await codec.ready();
        final frame = await codec.getNextFrame();
        expect(frame.image.width, greaterThan(0));
        expect(frame.image.height, greaterThan(0));
        frame.image.dispose();
      } finally {
        codec.dispose();
      }
    });
  }, skip: !Platform.isIOS);
}
