# flutter_avif

A flutter plugin to view and encode avif images.

## Installation

To add the flutter_avif to your Flutter application follow the [installation instructions](https://pub.dev/packages/flutter_avif/install) on pub.dev.

## Usage

AvifImage widget has a similar api as Flutter Image widget.

```dart
import 'package:flutter_avif/flutter_avif.dart';

AvifImage.file(
    file,
    height: 200,
    fit: BoxFit.contain,
),

AvifImage.asset(
    "test.avif",
    height: 200,
    fit: BoxFit.contain,
),

AvifImage.network(
    "https://test.com/test.avif",
    height: 200,
    fit: BoxFit.contain,
),
```
For documentation on widget properties, please refer to <https://api.flutter.dev/flutter/widgets/Image-class.html>.

## Encoding

To convert an image to avif:

```dart
import 'package:flutter_avif/flutter_avif.dart';

final asset = await rootBundle.load("asset.gif");
final avifBytes = await encodeAvif(asset.buffer.asUint8List());
final outputFile = File('output.avif');
outputFile.writeAsBytes(avifBytes);
```
```dart
import 'package:flutter_avif/flutter_avif.dart';

final inputFile = File('input.png');
final inputBytes = await inputFile.readAsBytes();
final avifBytes = await encodeAvif(inputBytes);
final outputFile = File('output.avif');
outputFile.writeAsBytes(avifBytes);
```

## Custom Animation Controller

`AvifAnimation` can be used together with an `AnimationController` to manipulate the playback of multiframe images.

```dart
import 'package:flutter_avif/flutter_avif.dart';

AnimationController controller = AnimationController(vsync: this);

AvifAnimation(
    controller: controller,
    image: const AssetAvifImage('multiframe.avif'),
    loadingBuilder: (context) => const Center(
        child: CircularProgressIndicator(),
    ),
    onLoaded: (duration, fps) {
        controller.forward(); // play the animation
    },
),
```