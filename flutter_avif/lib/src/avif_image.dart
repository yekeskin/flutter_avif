import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/semantics.dart';
import 'dart:ui' as ui;
import 'package:http/http.dart' as http;
import 'package:flutter_avif_platform_interface/flutter_avif_platform_interface.dart'
    as avif_platform;

/// Used to support both Flutter 2.x.x and 3.x.x
///
/// Private since this is the only file that produces
/// binding warnings in the 3.x.x version of flutter.
T? _ambiguate<T>(T? value) => value;

const double _kLowDprLimit = 2.0;

class AvifImage extends StatefulWidget {
  final double? width;
  final double? height;
  final Color? color;
  final Animation<double>? opacity;
  final FilterQuality filterQuality;
  final BlendMode? colorBlendMode;
  final BoxFit? fit;
  final AlignmentGeometry alignment;
  final ImageRepeat repeat;
  final Rect? centerSlice;
  final bool matchTextDirection;
  final bool isAntiAlias;
  final ImageProvider image;
  final ImageErrorWidgetBuilder? errorBuilder;
  final String? semanticLabel;
  final bool excludeFromSemantics;
  final bool gaplessPlayback;
  final ImageFrameBuilder? frameBuilder;
  final ImageLoadingBuilder? loadingBuilder;

  @override
  State<AvifImage> createState() => AvifImageState();

  const AvifImage({
    Key? key,
    required this.image,
    double scale = 1.0,
    this.width,
    this.height,
    this.color,
    this.opacity,
    this.colorBlendMode,
    this.fit,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.centerSlice,
    this.matchTextDirection = false,
    this.isAntiAlias = false,
    this.filterQuality = FilterQuality.low,
    int? cacheWidth,
    int? cacheHeight,
    this.errorBuilder,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.gaplessPlayback = false,
    this.frameBuilder,
    this.loadingBuilder,
  }) : super(key: key);

  AvifImage.file(
    File file, {
    Key? key,
    double scale = 1.0,
    this.width,
    this.height,
    this.color,
    this.opacity,
    this.colorBlendMode,
    this.fit,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.centerSlice,
    this.matchTextDirection = false,
    this.isAntiAlias = false,
    this.filterQuality = FilterQuality.low,
    int? cacheWidth,
    int? cacheHeight,
    int? overrideDurationMs = -1,
    this.errorBuilder,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.gaplessPlayback = false,
    this.frameBuilder,
  })  : image = avif_platform.FlutterAvifPlatform.useNativeDecoder
            ? FileImage(
                file,
                scale: scale,
              ) as ImageProvider
            : FileAvifImage(
                file,
                scale: scale,
                overrideDurationMs: overrideDurationMs,
              ),
        loadingBuilder = null,
        super(key: key);

  AvifImage.asset(
    String name, {
    Key? key,
    double scale = 1.0,
    this.width,
    this.height,
    this.color,
    this.opacity,
    this.colorBlendMode,
    this.fit,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.centerSlice,
    this.matchTextDirection = false,
    this.isAntiAlias = false,
    this.filterQuality = FilterQuality.low,
    int? cacheWidth,
    int? cacheHeight,
    int? overrideDurationMs = -1,
    this.errorBuilder,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.gaplessPlayback = false,
    this.frameBuilder,
    AssetBundle? bundle,
  })  : image = avif_platform.FlutterAvifPlatform.useNativeDecoder
            ? AssetImage(
                name,
                bundle: bundle,
              ) as ImageProvider
            : AssetAvifImage(
                name,
                scale: scale,
                overrideDurationMs: overrideDurationMs,
                bundle: bundle,
              ),
        loadingBuilder = null,
        super(key: key);

  AvifImage.network(
    String url, {
    Key? key,
    double scale = 1.0,
    this.width,
    this.height,
    this.color,
    this.opacity,
    this.colorBlendMode,
    this.fit,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.centerSlice,
    this.matchTextDirection = false,
    this.isAntiAlias = false,
    this.filterQuality = FilterQuality.low,
    int? cacheWidth,
    int? cacheHeight,
    int? overrideDurationMs = -1,
    this.errorBuilder,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.gaplessPlayback = false,
    this.frameBuilder,
    this.loadingBuilder,
    Map<String, String>? headers,
  })  : image = avif_platform.FlutterAvifPlatform.useNativeDecoder
            ? NetworkImage(
                url,
                scale: scale,
                headers: headers,
              ) as ImageProvider
            : NetworkAvifImage(
                url,
                scale: scale,
                overrideDurationMs: overrideDurationMs,
                headers: headers,
              ),
        super(key: key);

  AvifImage.memory(
    Uint8List bytes, {
    Key? key,
    double scale = 1.0,
    this.width,
    this.height,
    this.color,
    this.opacity,
    this.colorBlendMode,
    this.fit,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.centerSlice,
    this.matchTextDirection = false,
    this.isAntiAlias = false,
    this.filterQuality = FilterQuality.low,
    int? cacheWidth,
    int? cacheHeight,
    int? overrideDurationMs = -1,
    this.errorBuilder,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.gaplessPlayback = false,
    this.frameBuilder,
  })  : image = avif_platform.FlutterAvifPlatform.useNativeDecoder
            ? MemoryImage(
                bytes,
                scale: scale,
              ) as ImageProvider
            : MemoryAvifImage(
                bytes,
                scale: scale,
                overrideDurationMs: overrideDurationMs,
              ),
        loadingBuilder = null,
        super(key: key);
}

class AvifImageState extends State<AvifImage> with WidgetsBindingObserver {
  ImageStream? _imageStream;
  ImageInfo? _imageInfo;
  bool _isListeningToStream = false;
  late bool _invertColors;
  late DisposableBuildContext<State<AvifImage>> _scrollAwareContext;
  ImageStreamCompleterHandle? _completerHandle;
  int? _frameNumber;
  Object? _lastException;
  StackTrace? _lastStack;
  bool _wasSynchronouslyLoaded = false;
  ImageChunkEvent? _loadingProgress;

  @override
  void initState() {
    super.initState();
    _ambiguate(WidgetsBinding.instance)?.addObserver(this);
    _scrollAwareContext = DisposableBuildContext<State<AvifImage>>(this);
  }

  @override
  void dispose() {
    assert(_imageStream != null);
    _ambiguate(WidgetsBinding.instance)?.removeObserver(this);
    _stopListeningToStream();
    _completerHandle?.dispose();
    _scrollAwareContext.dispose();
    _replaceImage(info: null);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _updateInvertColors();
    _resolveImage();

    if (TickerMode.of(context)) {
      _listenToStream();
    } else {
      _stopListeningToStream(keepStreamAlive: true);
    }

    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(AvifImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isListeningToStream &&
        (widget.loadingBuilder == null) != (oldWidget.loadingBuilder == null)) {
      final ImageStreamListener oldListener = _getListener();
      _imageStream!.addListener(_getListener(recreateListener: true));
      _imageStream!.removeListener(oldListener);
    }
    if (widget.image != oldWidget.image) {
      final avifFfi = avif_platform.FlutterAvifPlatform.api;
      avifFfi.disposeDecoder(key: oldWidget.image.hashCode.toString());
      _resolveImage();
    }
  }

  @override
  void didChangeAccessibilityFeatures() {
    super.didChangeAccessibilityFeatures();
    setState(() {
      _updateInvertColors();
    });
  }

  @override
  void reassemble() {
    _resolveImage();
    super.reassemble();
  }

  ImageStreamListener? _imageStreamListener;
  ImageStreamListener _getListener({bool recreateListener = false}) {
    if (_imageStreamListener == null || recreateListener) {
      _lastException = null;
      _lastStack = null;
      _imageStreamListener = ImageStreamListener(
        _handleImageFrame,
        onChunk: widget.loadingBuilder == null ? null : _handleImageChunk,
        onError: widget.errorBuilder != null || kDebugMode
            ? (Object error, StackTrace? stackTrace) {
                setState(() {
                  _lastException = error;
                  _lastStack = stackTrace;
                });
                assert(() {
                  if (widget.errorBuilder == null) {
                    // ignore: only_throw_errors, since we're just proxying the error.
                    throw error; // Ensures the error message is printed to the console.
                  }
                  return true;
                }());
              }
            : null,
      );
    }
    return _imageStreamListener!;
  }

  void _handleImageFrame(ImageInfo imageInfo, bool synchronousCall) {
    setState(() {
      _lastException = null;
      _lastStack = null;
      _replaceImage(info: imageInfo);
      _frameNumber = _frameNumber == null ? 0 : _frameNumber! + 1;
      _wasSynchronouslyLoaded = _wasSynchronouslyLoaded | synchronousCall;
      _loadingProgress = null;
    });
  }

  void _handleImageChunk(ImageChunkEvent event) {
    assert(widget.loadingBuilder != null);
    setState(() {
      _loadingProgress = event;
      _lastException = null;
      _lastStack = null;
    });
  }

  void _listenToStream() {
    if (_isListeningToStream) return;

    _imageStream!.addListener(_getListener());
    _completerHandle?.dispose();
    _completerHandle = null;

    _isListeningToStream = true;
  }

  void _stopListeningToStream({bool keepStreamAlive = false}) {
    if (!_isListeningToStream) return;

    if (keepStreamAlive &&
        _completerHandle == null &&
        _imageStream?.completer != null) {
      _completerHandle = _imageStream!.completer!.keepAlive();
    }

    _imageStream!.removeListener(_getListener());
    _isListeningToStream = false;

    if (_imageStream?.completer != null &&
        (_imageStream!.completer! is AvifImageStreamCompleter) &&
        !(_imageStream!.completer! as AvifImageStreamCompleter)
            .getHasListeners() &&
        !PaintingBinding.instance.imageCache.containsKey(widget.image)) {
      final avifFfi = avif_platform.FlutterAvifPlatform.api;
      avifFfi.disposeDecoder(key: widget.image.hashCode.toString());
    }
  }

  void _updateSourceStream(ImageStream newStream) {
    if (_imageStream?.key == newStream.key) return;

    if (_isListeningToStream) _imageStream!.removeListener(_getListener());

    if (!widget.gaplessPlayback) {
      setState(() {
        _replaceImage(info: null);
      });
    }

    setState(() {
      _frameNumber = null;
      _wasSynchronouslyLoaded = false;
      _loadingProgress = null;
    });

    _imageStream = newStream;
    if (_isListeningToStream) _imageStream!.addListener(_getListener());
  }

  void _updateInvertColors() {
    _invertColors = MediaQuery.maybeOf(context)?.invertColors ??
        _ambiguate(SemanticsBinding.instance)
            ?.accessibilityFeatures
            .invertColors ??
        false;
  }

  void _replaceImage({required ImageInfo? info}) {
    _imageInfo?.dispose();
    _imageInfo = info;
  }

  void _resolveImage() {
    final ScrollAwareImageProvider provider = ScrollAwareImageProvider<Object>(
      context: _scrollAwareContext,
      imageProvider: widget.image,
    );
    final ImageStream newStream =
        provider.resolve(createLocalImageConfiguration(
      context,
      size: widget.width != null && widget.height != null
          ? Size(widget.width!, widget.height!)
          : null,
    ));

    _updateSourceStream(newStream);
  }

  @override
  Widget build(BuildContext context) {
    if (_lastException != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(context, _lastException!, _lastStack);
      }
      if (kDebugMode) {
        return _debugBuildErrorWidget(context, _lastException!);
      }
    }

    Widget result = RawImage(
      image: _imageInfo?.image,
      debugImageLabel: _imageInfo?.debugLabel,
      width: widget.width,
      height: widget.height,
      scale: _imageInfo?.scale ?? 1.0,
      color: widget.color,
      opacity: widget.opacity,
      colorBlendMode: widget.colorBlendMode,
      fit: widget.fit,
      alignment: widget.alignment,
      repeat: widget.repeat,
      centerSlice: widget.centerSlice,
      matchTextDirection: widget.matchTextDirection,
      invertColors: _invertColors,
      isAntiAlias: widget.isAntiAlias,
      filterQuality: widget.filterQuality,
    );

    if (!widget.excludeFromSemantics) {
      result = Semantics(
        container: widget.semanticLabel != null,
        image: true,
        label: widget.semanticLabel ?? '',
        child: result,
      );
    }

    if (widget.frameBuilder != null) {
      result = widget.frameBuilder!(
        context,
        result,
        _frameNumber,
        _wasSynchronouslyLoaded,
      );
    }

    if (widget.loadingBuilder != null) {
      result = widget.loadingBuilder!(context, result, _loadingProgress);
    }

    return result;
  }

  Widget _debugBuildErrorWidget(BuildContext context, Object error) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        const Positioned.fill(
          child: Placeholder(
            color: Color(0xCF8D021F),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: FittedBox(
            child: Text(
              '$error',
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
              style: const TextStyle(
                shadows: <Shadow>[
                  Shadow(blurRadius: 1.0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class FileAvifImage extends ImageProvider<FileAvifImage> {
  const FileAvifImage(
    this.file, {
    this.scale = 1.0,
    this.overrideDurationMs = -1,
  });

  final File file;
  final double scale;
  final int? overrideDurationMs;

  @override
  Future<FileAvifImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<FileAvifImage>(this);
  }

  @override
  ImageStreamCompleter loadImage(
      FileAvifImage key, ImageDecoderCallback decode) {
    return AvifImageStreamCompleter(
      key: key,
      codec: _loadAsync(key, decode),
      scale: key.scale,
      debugLabel: key.file.path,
      informationCollector: () => <DiagnosticsNode>[
        ErrorDescription('Path: ${file.path}'),
      ],
    );
  }

  Future<AvifCodec> _loadAsync(
    FileAvifImage key,
    ImageDecoderCallback decode,
  ) async {
    assert(key == this);

    final Uint8List bytes = await file.readAsBytes();

    if (bytes.lengthInBytes == 0) {
      // The file may become available later.
      _ambiguate(PaintingBinding.instance)?.imageCache.evict(key);
      throw StateError('$file is empty and cannot be loaded as an image.');
    }

    final fType = isAvifFile(bytes.sublist(0, 16));
    if (fType == AvifFileType.unknown) {
      throw StateError('$file is not an avif file.');
    }

    final codec = fType == AvifFileType.avif
        ? SingleFrameAvifCodec(bytes: bytes)
        : MultiFrameAvifCodec(
            key: hashCode,
            avifBytes: bytes,
            overrideDurationMs: overrideDurationMs,
          );
    await codec.ready();

    return codec;
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is FileAvifImage &&
        other.file.path == file.path &&
        other.scale == scale;
  }

  @override
  int get hashCode => Object.hash(file.path, scale);

  @override
  String toString() =>
      '${objectRuntimeType(this, 'AvifImage')}("${file.path}", scale: $scale)';
}

class AssetAvifImage extends ImageProvider<AssetAvifImage> {
  const AssetAvifImage(
    this.asset, {
    this.scale = 1.0,
    this.overrideDurationMs = -1,
    this.bundle,
  });

  final String asset;
  final double scale;
  final int? overrideDurationMs;
  final AssetBundle? bundle;

  static const double _naturalResolution = 1.0;

  @override
  Future<AssetAvifImage> obtainKey(ImageConfiguration configuration) {
    // This function tries to return a SynchronousFuture if possible. We do this
    // because otherwise showing an image would always take at least one frame,
    // which would be sad. (This code is called from inside build/layout/paint,
    // which all happens in one call frame; using native Futures would guarantee
    // that we resolve each future in a new call frame, and thus not in this
    // build/layout/paint sequence.)
    final AssetBundle chosenBundle =
        bundle ?? configuration.bundle ?? rootBundle;
    Completer<AssetAvifImage>? completer;
    Future<AssetAvifImage>? result;

    AssetManifest.loadFromAssetBundle(chosenBundle)
        .then((AssetManifest manifest) {
      final Iterable<AssetMetadata>? candidateVariants =
          manifest.getAssetVariants(asset);
      final AssetMetadata chosenVariant = _chooseVariant(
        asset,
        configuration,
        candidateVariants,
      );
      final AssetAvifImage key = AssetAvifImage(
        chosenVariant.key,
        bundle: chosenBundle,
        scale: chosenVariant.targetDevicePixelRatio ?? _naturalResolution,
      );

      if (completer != null) {
        completer.complete(key);
      } else {
        result = SynchronousFuture<AssetAvifImage>(key);
      }
    }).onError((Object error, StackTrace stack) {
      assert(completer != null);
      assert(result == null);
      completer!.completeError(error, stack);
    });

    if (result != null) {
      return result!;
    }

    completer = Completer<AssetAvifImage>();
    return completer.future;
  }

  @override
  ImageStreamCompleter loadImage(
      AssetAvifImage key, ImageDecoderCallback decode) {
    return AvifImageStreamCompleter(
      key: key,
      codec: _loadAsync(key, decode),
      scale: key.scale,
      debugLabel: key.asset,
      informationCollector: () => <DiagnosticsNode>[
        ErrorDescription('Asset: $asset'),
      ],
    );
  }

  Future<AvifCodec> _loadAsync(
    AssetAvifImage key,
    ImageDecoderCallback decode,
  ) async {
    final bytes = await (bundle ?? rootBundle).load(key.asset);

    if (bytes.lengthInBytes == 0) {
      // The file may become available later.
      _ambiguate(PaintingBinding.instance)?.imageCache.evict(key);
      throw StateError('$asset is empty and cannot be loaded as an image.');
    }

    final bytesUint8List = bytes.buffer.asUint8List(0);
    final fType = isAvifFile(bytesUint8List.sublist(0, 16));
    if (fType == AvifFileType.unknown) {
      throw StateError('$asset is not an avif file.');
    }

    final codec = fType == AvifFileType.avif
        ? SingleFrameAvifCodec(bytes: bytesUint8List)
        : MultiFrameAvifCodec(
            key: hashCode,
            avifBytes: bytesUint8List,
            overrideDurationMs: overrideDurationMs,
          );
    await codec.ready();

    return codec;
  }

  AssetMetadata _chooseVariant(
    String mainAssetKey,
    ImageConfiguration config,
    Iterable<AssetMetadata>? candidateVariants,
  ) {
    if (candidateVariants == null ||
        candidateVariants.isEmpty ||
        config.devicePixelRatio == null) {
      return AssetMetadata(
          key: mainAssetKey, targetDevicePixelRatio: null, main: true);
    }

    final SplayTreeMap<double, AssetMetadata> candidatesByDevicePixelRatio =
        SplayTreeMap<double, AssetMetadata>();
    for (final AssetMetadata candidate in candidateVariants) {
      candidatesByDevicePixelRatio[
          candidate.targetDevicePixelRatio ?? _naturalResolution] = candidate;
    }

    return _findBestVariant(
        candidatesByDevicePixelRatio, config.devicePixelRatio!);
  }

  AssetMetadata _findBestVariant(
    SplayTreeMap<double, AssetMetadata> candidatesByDpr,
    double value,
  ) {
    if (candidatesByDpr.containsKey(value)) {
      return candidatesByDpr[value]!;
    }
    final double? lower = candidatesByDpr.lastKeyBefore(value);
    final double? upper = candidatesByDpr.firstKeyAfter(value);
    if (lower == null) {
      return candidatesByDpr[upper]!;
    }
    if (upper == null) {
      return candidatesByDpr[lower]!;
    }

    if (value < _kLowDprLimit || value > (lower + upper) / 2) {
      return candidatesByDpr[upper]!;
    } else {
      return candidatesByDpr[lower]!;
    }
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is AssetAvifImage &&
        other.asset == asset &&
        other.scale == scale;
  }

  @override
  int get hashCode => Object.hash(asset, scale);

  @override
  String toString() =>
      '${objectRuntimeType(this, 'AvifImage')}("$asset", scale: $scale)';
}

class NetworkAvifImage extends ImageProvider<NetworkAvifImage> {
  const NetworkAvifImage(
    this.url, {
    this.scale = 1.0,
    this.overrideDurationMs = -1,
    this.headers,
  });

  final String url;
  final double scale;
  final int? overrideDurationMs;
  final Map<String, String>? headers;

  @override
  Future<NetworkAvifImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<NetworkAvifImage>(this);
  }

  @override
  ImageStreamCompleter loadImage(
      NetworkAvifImage key, ImageDecoderCallback decode) {
    final StreamController<ImageChunkEvent> chunkEvents =
        StreamController<ImageChunkEvent>();

    return AvifImageStreamCompleter(
      key: key,
      codec: _loadAsync(
        key,
        decode,
        chunkEvents,
      ),
      scale: key.scale,
      debugLabel: key.url,
      informationCollector: () => <DiagnosticsNode>[
        ErrorDescription('Url: $url'),
      ],
      chunkEvents: chunkEvents.stream,
    );
  }

  Future<AvifCodec> _loadAsync(
    NetworkAvifImage key,
    ImageDecoderCallback decode,
    StreamController<ImageChunkEvent> chunkEvents,
  ) async {
    assert(key == this);

    final httpRequest = http.Request('GET', Uri.parse(url));
    headers?.forEach((String name, String value) {
      httpRequest.headers[name] = value;
    });
    final httpResponse = await httpRequest.send();
    if (httpResponse.statusCode != HttpStatus.ok) {
      throw StateError(
          '$url cannot be loaded as an image. Http error code ${httpResponse.statusCode}');
    }

    final b = BytesBuilder();
    int cumulative = 0;
    final total = httpResponse.contentLength ?? 0;

    await for (final newBytes in httpResponse.stream) {
      cumulative += newBytes.length;
      b.add(newBytes);
      chunkEvents.add(ImageChunkEvent(
        cumulativeBytesLoaded: cumulative,
        expectedTotalBytes: total,
      ));
    }
    final bytes = b.takeBytes();

    if (bytes.lengthInBytes == 0) {
      // The file may become available later.
      _ambiguate(PaintingBinding.instance)?.imageCache.evict(key);
      throw StateError('$url is empty and cannot be loaded as an image.');
    }

    final fType = isAvifFile(bytes.sublist(0, 16));
    if (fType == AvifFileType.unknown) {
      throw StateError('$url is not an avif file.');
    }

    final codec = fType == AvifFileType.avif
        ? SingleFrameAvifCodec(bytes: bytes)
        : MultiFrameAvifCodec(
            key: hashCode,
            avifBytes: bytes,
            overrideDurationMs: overrideDurationMs,
          );
    await codec.ready();

    return codec;
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) return false;
    return other is NetworkAvifImage &&
        other.url == url &&
        other.scale == scale;
  }

  @override
  int get hashCode => Object.hash(url, scale);

  @override
  String toString() =>
      '${objectRuntimeType(this, 'AvifImage')}("$url", scale: $scale)';
}

class MemoryAvifImage extends ImageProvider<MemoryAvifImage> {
  const MemoryAvifImage(
    this.bytes, {
    this.scale = 1.0,
    this.overrideDurationMs = -1,
  });

  final Uint8List bytes;
  final double scale;
  final int? overrideDurationMs;

  @override
  Future<MemoryAvifImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<MemoryAvifImage>(this);
  }

  @override
  ImageStreamCompleter loadImage(
      MemoryAvifImage key, ImageDecoderCallback decode) {
    return AvifImageStreamCompleter(
      key: key,
      codec: _loadAsync(key, decode),
      scale: key.scale,
      debugLabel: 'MemoryAvifImage(${describeIdentity(key.bytes)})',
    );
  }

  Future<AvifCodec> _loadAsync(
      MemoryAvifImage key, ImageDecoderCallback decode) async {
    assert(key == this);

    final bytesUint8List = bytes.buffer.asUint8List(0);
    final fType = isAvifFile(bytesUint8List.sublist(0, 16));
    if (fType == AvifFileType.unknown) {
      throw StateError('Loaded file is not an avif file.');
    }

    final codec = fType == AvifFileType.avif
        ? SingleFrameAvifCodec(bytes: bytesUint8List)
        : MultiFrameAvifCodec(
            key: hashCode,
            avifBytes: bytesUint8List,
            overrideDurationMs: overrideDurationMs,
          );
    await codec.ready();

    return codec;
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is MemoryAvifImage &&
        other.bytes == bytes &&
        other.scale == scale;
  }

  @override
  int get hashCode => Object.hash(bytes.hashCode, scale);

  @override
  String toString() =>
      '${objectRuntimeType(this, 'MemoryAvifImage')}(${describeIdentity(bytes)}, scale: $scale)';
}

abstract class AvifCodec {
  int get frameCount;
  int get durationMs;

  Future<void> ready();
  Future<AvifFrameInfo> getNextFrame();
  void dispose();
}

class MultiFrameAvifCodec implements AvifCodec {
  final String _key;
  late Completer<void> _ready;

  int _frameCount = 1;
  @override
  int get frameCount => _frameCount;

  int _durationMs = -1;
  @override
  int get durationMs => _durationMs;

  MultiFrameAvifCodec({
    required int key,
    required Uint8List avifBytes,
    int? overrideDurationMs = -1,
  }) : _key = key.toString() {
    _ready = Completer();
    try {
      final avifFfi = avif_platform.FlutterAvifPlatform.api;
      avifFfi.initMemoryDecoder(key: _key, avifBytes: avifBytes).then((info) {
        _frameCount = info.imageCount;
        _durationMs = overrideDurationMs ?? (info.duration * 1000).round();
        _ready.complete();
      });
    } catch (e) {
      _ready.complete();
    }
  }

  @override
  ready() async {
    if (_ready.isCompleted) {
      return;
    }
    await _ready.future;
  }

  @override
  Future<AvifFrameInfo> getNextFrame() async {
    final Completer<AvifFrameInfo> completer = Completer<AvifFrameInfo>.sync();
    final String? error =
        _getNextFrame((ui.Image? image, int durationMilliseconds) {
      if (image == null) {
        completer.completeError(Exception(
            'Codec failed to produce an image, possibly due to invalid image data.'));
      } else {
        completer.complete(AvifFrameInfo(
          image: image,
          duration: Duration(milliseconds: durationMilliseconds),
        ));
      }
    });
    if (error != null) {
      throw Exception(error);
    }
    return completer.future;
  }

  String? _getNextFrame(void Function(ui.Image?, int) callback) {
    try {
      final avifFfi = avif_platform.FlutterAvifPlatform.api;
      avifFfi.getNextFrame(key: _key).then((frame) {
        ui.decodeImageFromPixels(
          Uint8List.fromList(frame.data),
          frame.width,
          frame.height,
          ui.PixelFormat.rgba8888,
          (image) {
            callback(image, (frame.duration * 1000).round());
          },
        );
      });
      return null;
    } catch (e) {
      callback(null, 0);
      return e.toString();
    }
  }

  @override
  void dispose() {
    final avifFfi = avif_platform.FlutterAvifPlatform.api;
    avifFfi.disposeDecoder(key: _key);
  }
}

class SingleFrameAvifCodec implements AvifCodec {
  @override
  int get frameCount => 1;

  @override
  int get durationMs => -1;

  final Uint8List _bytes;

  SingleFrameAvifCodec({
    required Uint8List bytes,
  }) : _bytes = bytes;

  @override
  Future<void> ready() async {}

  @override
  Future<AvifFrameInfo> getNextFrame() async {
    final Completer<AvifFrameInfo> completer = Completer<AvifFrameInfo>.sync();
    final String? error =
        _getNextFrame((ui.Image? image, int durationMilliseconds) {
      if (image == null) {
        completer.completeError(Exception(
            'Codec failed to produce an image, possibly due to invalid image data.'));
      } else {
        completer.complete(AvifFrameInfo(
          image: image,
          duration: Duration(milliseconds: durationMilliseconds),
        ));
      }
    });
    if (error != null) {
      throw Exception(error);
    }
    return completer.future;
  }

  String? _getNextFrame(void Function(ui.Image?, int) callback) {
    try {
      final avifFfi = avif_platform.FlutterAvifPlatform.api;
      avifFfi.decodeSingleFrameImage(avifBytes: _bytes).then((frame) {
        ui.decodeImageFromPixels(
          Uint8List.fromList(frame.data),
          frame.width,
          frame.height,
          ui.PixelFormat.rgba8888,
          (image) {
            callback(image, (frame.duration * 1000).round());
          },
        );
      });
      return null;
    } catch (e) {
      callback(null, 0);
      return e.toString();
    }
  }

  @override
  void dispose() {}
}

class AvifFrameInfo {
  final Duration duration;
  final ui.Image image;

  AvifFrameInfo({required this.duration, required this.image});
}

class AvifImageStreamCompleter extends ImageStreamCompleter {
  AvifImageStreamCompleter({
    required ImageProvider key,
    required Future<AvifCodec> codec,
    required double scale,
    String? debugLabel,
    Stream<ImageChunkEvent>? chunkEvents,
    InformationCollector? informationCollector,
  })  : _informationCollector = informationCollector,
        _scale = scale,
        _key = key {
    this.debugLabel = debugLabel;
    codec.then<void>(_handleCodecReady,
        onError: (Object error, StackTrace stack) {
      reportError(
        context: ErrorDescription('resolving an image codec'),
        exception: error,
        stack: stack,
        informationCollector: informationCollector,
        silent: true,
      );
    });
    if (chunkEvents != null) {
      _chunkSubscription = chunkEvents.listen(
        reportImageChunkEvent,
        onError: (Object error, StackTrace stack) {
          reportError(
            context: ErrorDescription('loading an image'),
            exception: error,
            stack: stack,
            informationCollector: informationCollector,
            silent: true,
          );
        },
      );
    }
  }

  StreamSubscription<ImageChunkEvent>? _chunkSubscription;
  AvifCodec? _codec;
  final double _scale;
  final InformationCollector? _informationCollector;
  AvifFrameInfo? _nextFrame;
  ImageInfo? _currentFrame;
  late Duration _shownTimestamp;
  Duration? _frameDuration;
  int _duration = 0;
  Timer? _timer;
  final ImageProvider _key;

  bool _frameCallbackScheduled = false;

  void _handleCodecReady(AvifCodec codec) {
    _codec = codec;
    assert(_codec != null);

    if (hasListeners) {
      _decodeNextFrameAndSchedule();
    }
  }

  void _handleAppFrame(Duration timestamp) {
    _frameCallbackScheduled = false;
    if (!hasListeners) return;
    assert(_nextFrame != null);
    if (_isFirstFrame() || _hasFrameDurationPassed(timestamp)) {
      _emitFrame(ImageInfo(
        image: _nextFrame!.image.clone(),
        scale: _scale,
        debugLabel: debugLabel,
      ));
      _shownTimestamp = timestamp;
      _frameDuration = _nextFrame!.duration;
      _nextFrame!.image.dispose();
      _nextFrame = null;
      if (_codec!.durationMs == -1 || _codec!.durationMs > _duration) {
        _decodeNextFrameAndSchedule();
      }
      return;
    }
    final Duration delay = _frameDuration! - (timestamp - _shownTimestamp);
    _timer = Timer(delay * timeDilation, () {
      _scheduleAppFrame();
    });
  }

  bool _isFirstFrame() {
    return _frameDuration == null;
  }

  bool _hasFrameDurationPassed(Duration timestamp) {
    return timestamp - _shownTimestamp >= _frameDuration!;
  }

  Future<void> _decodeNextFrameAndSchedule() async {
    _nextFrame?.image.dispose();
    _nextFrame = null;
    try {
      _nextFrame = await _codec!.getNextFrame();
    } catch (exception, stack) {
      reportError(
        context: ErrorDescription('resolving an image frame'),
        exception: exception,
        stack: stack,
        informationCollector: _informationCollector,
        silent: true,
      );
      return;
    }
    if (_codec!.frameCount == 1) {
      if (!hasListeners) {
        return;
      }
      _emitFrame(ImageInfo(
        image: _nextFrame!.image.clone(),
        scale: _scale,
        debugLabel: debugLabel,
      ));
      _nextFrame!.image.dispose();
      _nextFrame = null;
      return;
    }
    _scheduleAppFrame();
  }

  void _scheduleAppFrame() {
    if (_frameCallbackScheduled) {
      return;
    }
    _frameCallbackScheduled = true;
    _ambiguate(SchedulerBinding.instance)!
        .scheduleFrameCallback(_handleAppFrame);
  }

  void _emitFrame(ImageInfo imageInfo) {
    setImage(imageInfo);
    _duration += _nextFrame?.duration.inMilliseconds ?? 0;
  }

  @override
  void addListener(ImageStreamListener listener) {
    if (!hasListeners &&
        _codec != null &&
        (_currentFrame == null || _codec!.frameCount > 1)) {
      _decodeNextFrameAndSchedule();
    }
    super.addListener(listener);
  }

  @override
  void removeListener(ImageStreamListener listener) {
    super.removeListener(listener);
    if (!hasListeners) {
      _timer?.cancel();
      _timer = null;
    }
  }

  bool getHasListeners() => hasListeners;

  @override
  void setImage(ImageInfo image) {
    _currentFrame = image;
    super.setImage(image);
  }

  void dispose() {
    _chunkSubscription?.onData(null);
    _chunkSubscription?.cancel();
    _chunkSubscription = null;
  }

  @override
  ImageStreamCompleterHandle keepAlive() {
    final handle = super.keepAlive();
    return AvifImageStreamCompleterHandle(handle, this);
  }
}

class AvifImageStreamCompleterHandle implements ImageStreamCompleterHandle {
  final ImageStreamCompleterHandle _handle;
  final AvifImageStreamCompleter _completer;

  AvifImageStreamCompleterHandle(this._handle, this._completer);

  @override
  void dispose() {
    _handle.dispose();
    if (!_completer.getHasListeners() &&
        !PaintingBinding.instance.imageCache.containsKey(_completer._key)) {
      _completer._codec?.dispose();
    }
  }
}

enum AvifFileType { avif, avis, unknown }

AvifFileType isAvifFile(Uint8List bytes) {
  if (_isSubset(bytes, [102, 116, 121, 112, 97, 118, 105, 102])) {
    return AvifFileType.avif;
  }

  if (_isSubset(bytes, [102, 116, 121, 112, 97, 118, 105, 115])) {
    return AvifFileType.avis;
  }

  return AvifFileType.unknown;
}

bool _isSubset(List arr1, List arr2) {
  int i = 0, j = 0;
  for (i = 0; i < arr1.length - arr2.length + 1; i++) {
    for (j = 0; j < arr2.length; j++) {
      if (arr1[i + j] != arr2[j]) break;
    }

    if (j == arr2.length) return true;
  }

  return false;
}
