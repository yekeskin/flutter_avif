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

The package also provides `CachedNetworkAvifImage` for caching network images.

```dart
import 'package:flutter_avif/flutter_avif.dart';

CachedNetworkAvifImage(
    "https://test.com/test.avif",
    height: 200,
    fit: BoxFit.contain,
)
```

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

## Decoding

decodeAvif function can be used to decode an avif file to a list of dart:ui [Image](https://api.flutter.dev/flutter/dart-ui/Image-class.html):

```dart
import 'package:flutter_avif/flutter_avif.dart';

final bytes = await rootBundle.load('asset.avif');
final frames = await decodeAvif(bytes.buffer.asUint8List());
```
decodeAvif functions return a list of [AvifFrameInfo](https://pub.dev/documentation/flutter_avif/latest/flutter_avif/AvifFrameInfo-class.html) which has the duration and the image of a frame.

## Custom Animation Controller

`AvifAnimation` can be used together with an `AnimationController` to manipulate the playback of multiframe images.

```dart
import 'package:flutter_avif/flutter_avif.dart';

AnimationController controller = AnimationController(vsync: this);

AvifAnimation(
    controller: controller,
    image: const AssetAvifImage('multiframe.avif'),
    onLoaded: (duration, fps) {
        controller.forward(); // play the animation
    },
),
```