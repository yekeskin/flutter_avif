import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/semantics.dart';
import 'dart:ui' as ui;
import 'package:flutter_avif_platform_interface/flutter_avif_platform_interface.dart'
    as avif_platform;

/// Used to support both Flutter 2.x.x and 3.x.x
///
/// Private since this is the only file that produces
/// binding warnings in the 3.x.x version of flutter.
T? _ambiguate<T>(T? value) => value;

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
  })  : image = FileAvifImage(
          file,
          scale: scale,
          overrideDurationMs: overrideDurationMs,
        ),
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
  })  : image = AssetAvifImage(
          name,
          scale: scale,
          overrideDurationMs: overrideDurationMs,
        ),
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
  })  : image = NetworkAvifImage(
          url,
          scale: scale,
          overrideDurationMs: overrideDurationMs,
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
  })  : image = MemoryAvifImage(
          bytes,
          scale: scale,
          overrideDurationMs: overrideDurationMs,
        ),
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
        onChunk: null,
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

    setState(() {
      _replaceImage(info: null);
      _frameNumber = null;
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

    return RawImage(
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
  ImageStreamCompleter loadBuffer(
      FileAvifImage key, DecoderBufferCallback decode) {
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
    DecoderBufferCallback decode,
  ) async {
    assert(key == this);

    final Uint8List bytes = await file.readAsBytes();

    if (bytes.lengthInBytes == 0) {
      // The file may become available later.
      _ambiguate(PaintingBinding.instance)?.imageCache.evict(key);
      throw StateError('$file is empty and cannot be loaded as an image.');
    }

    final avifFfi = avif_platform.FlutterAvifPlatform.api;
    final info = await avifFfi.getImageInfo(avifBytes: bytes);
    final codec = info.imageCount == 1
        ? SingleFrameAvifCodec(info: info)
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
  });

  final String asset;
  final double scale;
  final int? overrideDurationMs;

  @override
  Future<AssetAvifImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<AssetAvifImage>(this);
  }

  @override
  ImageStreamCompleter loadBuffer(
      AssetAvifImage key, DecoderBufferCallback decode) {
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
    DecoderBufferCallback decode,
  ) async {
    assert(key == this);

    final bytes = await rootBundle.load(asset);

    if (bytes.lengthInBytes == 0) {
      // The file may become available later.
      _ambiguate(PaintingBinding.instance)?.imageCache.evict(key);
      throw StateError('$asset is empty and cannot be loaded as an image.');
    }

    final avifFfi = avif_platform.FlutterAvifPlatform.api;
    final info =
        await avifFfi.getImageInfo(avifBytes: bytes.buffer.asUint8List(0));
    final codec = info.imageCount == 1
        ? SingleFrameAvifCodec(info: info)
        : MultiFrameAvifCodec(
            key: hashCode,
            avifBytes: bytes.buffer.asUint8List(0),
            overrideDurationMs: overrideDurationMs,
          );
    await codec.ready();

    return codec;
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
  });

  final String url;
  final double scale;
  final int? overrideDurationMs;

  @override
  Future<NetworkAvifImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<NetworkAvifImage>(this);
  }

  @override
  ImageStreamCompleter loadBuffer(
      NetworkAvifImage key, DecoderBufferCallback decode) {
    return AvifImageStreamCompleter(
      key: key,
      codec: _loadAsync(key, decode),
      scale: key.scale,
      debugLabel: key.url,
      informationCollector: () => <DiagnosticsNode>[
        ErrorDescription('Url: $url'),
      ],
    );
  }

  Future<AvifCodec> _loadAsync(
    NetworkAvifImage key,
    DecoderBufferCallback decode,
  ) async {
    assert(key == this);
    final bytes = await NetworkAssetBundle(Uri.parse(url)).load(url);

    if (bytes.lengthInBytes == 0) {
      // The file may become available later.
      _ambiguate(PaintingBinding.instance)?.imageCache.evict(key);
      throw StateError('$url is empty and cannot be loaded as an image.');
    }

    final avifFfi = avif_platform.FlutterAvifPlatform.api;
    final info =
        await avifFfi.getImageInfo(avifBytes: bytes.buffer.asUint8List(0));
    final codec = info.imageCount == 1
        ? SingleFrameAvifCodec(info: info)
        : MultiFrameAvifCodec(
            key: hashCode,
            avifBytes: bytes.buffer.asUint8List(0),
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
  ImageStreamCompleter loadBuffer(
      MemoryAvifImage key, DecoderBufferCallback decode) {
    return AvifImageStreamCompleter(
      key: key,
      codec: _loadAsync(key, decode),
      scale: key.scale,
      debugLabel: 'MemoryAvifImage(${describeIdentity(key.bytes)})',
    );
  }

  Future<AvifCodec> _loadAsync(
      MemoryAvifImage key, DecoderBufferCallback decode) async {
    assert(key == this);

    final avifFfi = avif_platform.FlutterAvifPlatform.api;
    final info =
        await avifFfi.getImageInfo(avifBytes: bytes.buffer.asUint8List(0));
    final codec = info.imageCount == 1
        ? SingleFrameAvifCodec(info: info)
        : MultiFrameAvifCodec(
            key: hashCode,
            avifBytes: bytes.buffer.asUint8List(0),
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
          frame.data,
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

  final avif_platform.AvifInfo _info;

  SingleFrameAvifCodec({
    required avif_platform.AvifInfo info,
  }) : _info = info;

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
      ui.decodeImageFromPixels(
        _info.frame.data,
        _info.frame.width,
        _info.frame.height,
        ui.PixelFormat.rgba8888,
        (image) {
          callback(image, (_info.frame.duration * 1000).round());
        },
      );
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
