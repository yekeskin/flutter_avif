import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_avif/flutter_avif.dart';
import 'package:http/http.dart' as http;

///
/// A widget that renders an avif with [AnimationController].
///
@immutable
class AvifAnimation extends StatefulWidget {
  /// Rendered image cache.
  static AnimationCache cache = AnimationCache();

  /// [ImageProvider] of this image. Like [FileAvifImage], [AvifNetworkImage], [AvifAssetImage], [AvifMemoryImage]
  final ImageProvider image;

  /// The playback controller.
  final AnimationController? controller;

  /// A builder that specifies the widget to display to the user while an image is still loading.
  final Widget Function(BuildContext context)? loadingBuilder;

  /// Called when the image is fully loaded and ready to render.
  final void Function(Duration duration, int fps)? onLoaded;

  final double? width;
  final double? height;
  final Color? color;
  final BlendMode? colorBlendMode;
  final BoxFit? fit;
  final AlignmentGeometry alignment;
  final ImageRepeat repeat;
  final Rect? centerSlice;
  final bool matchTextDirection;
  final String? semanticLabel;
  final bool excludeFromSemantics;
  final bool useCache;

  /// Creates a widget that displays a controllable avif.
  const AvifAnimation({
    Key? key,
    required this.image,
    this.controller,
    this.loadingBuilder,
    this.onLoaded,
    this.semanticLabel,
    this.excludeFromSemantics = false,
    this.width,
    this.height,
    this.color,
    this.colorBlendMode,
    this.fit,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.centerSlice,
    this.matchTextDirection = false,
    this.useCache = true,
  }) : super(key: key);

  @override
  State<AvifAnimation> createState() => _AvifAnimationState();
}

///
/// Works as a cache system for already fetched [AvifAnimationInfo].
///
@immutable
class AnimationCache {
  final Map<String, AvifAnimationInfo> caches = {};

  /// Clears all the stored images from the cache.
  void clear() => caches.clear();

  /// Removes an image from the cache.
  bool evict(Object key) => caches.remove(key) != null ? true : false;
}

///
/// Stores all the [ImageInfo] and duration of an avif.
///
@immutable
class AvifAnimationInfo {
  final List<ImageInfo> frames;
  final Duration duration;

  const AvifAnimationInfo({
    required this.frames,
    required this.duration,
  });
}

class _AvifAnimationState extends State<AvifAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  /// List of [ImageInfo] of every frame of this avif.
  List<ImageInfo> _frames = [];

  int _frameIndex = 0;

  /// Current rendered frame.
  ImageInfo? get _frame =>
      _frames.length > _frameIndex ? _frames[_frameIndex] : null;

  @override
  Widget build(BuildContext context) {
    final RawImage image = RawImage(
      image: _frame?.image,
      width: widget.width,
      height: widget.height,
      scale: _frame?.scale ?? 1.0,
      color: widget.color,
      colorBlendMode: widget.colorBlendMode,
      fit: widget.fit,
      alignment: widget.alignment,
      repeat: widget.repeat,
      centerSlice: widget.centerSlice,
      matchTextDirection: widget.matchTextDirection,
    );
    return widget.loadingBuilder != null && _frame == null
        ? widget.loadingBuilder!(context)
        : widget.excludeFromSemantics
            ? image
            : Semantics(
                container: widget.semanticLabel != null,
                image: true,
                label: widget.semanticLabel ?? '',
                child: image,
              );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadFrames();
  }

  @override
  void didUpdateWidget(AvifAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_listener);
      _controller = widget.controller ?? AnimationController(vsync: this);
      _controller.addListener(_listener);
    }
    if (widget.image != oldWidget.image) {
      _loadFrames();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_listener);
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? AnimationController(vsync: this);
    _controller.addListener(_listener);
  }

  /// Get unique image string from [ImageProvider]
  String _getImageKey(ImageProvider provider) {
    return provider is NetworkImage
        ? provider.url
        : provider is AssetImage
            ? provider.assetName
            : provider is FileImage
                ? provider.file.path
                : provider is MemoryImage
                    ? provider.bytes.toString()
                    : "";
  }

  /// Calculates the [_frameIndex] based on the [AnimationController] value.
  ///
  /// The calculation is based on the frames of the avif
  /// and the [Duration] of [AnimationController].
  void _listener() {
    if (_frames.isNotEmpty && mounted) {
      setState(() {
        _frameIndex = _frames.isEmpty
            ? 0
            : ((_frames.length - 1) * _controller.value).floor();
      });
    }
  }

  /// Fetches the frames with [_fetchFrames] and saves them into [_frames].
  ///
  /// When [_frames] is updated [onFetchCompleted] is called.
  Future<void> _loadFrames() async {
    if (!mounted) return;

    AvifAnimationInfo avif = widget.useCache
        ? AvifAnimation.cache.caches.containsKey(_getImageKey(widget.image))
            ? AvifAnimation.cache.caches[_getImageKey(widget.image)]!
            : await _fetchFrames(widget.image)
        : await _fetchFrames(widget.image);

    if (!mounted) return;

    if (widget.useCache) {
      AvifAnimation.cache.caches
          .putIfAbsent(_getImageKey(widget.image), () => avif);
    }

    setState(() {
      _frames = avif.frames;
      _controller.duration = _controller.duration ?? avif.duration;
      if (widget.onLoaded != null) {
        final fps =
            (_frames.length * 1000 / _controller.duration!.inMilliseconds)
                .round();
        widget.onLoaded!(_controller.duration!, fps);
      }
    });
  }

  /// Fetches single avif frames and saves them into the [AnimationCache] of [AvifAnimation]
  static Future<AvifAnimationInfo> _fetchFrames(ImageProvider provider) async {
    late final Uint8List bytes;

    if (provider is NetworkAvifImage) {
      final Uri resolved = Uri.base.resolve(provider.url);
      final httpRequest = http.Request('GET', resolved);
      provider.headers?.forEach(
          (String name, String value) => httpRequest.headers[name] = value);
      final httpResponse = await httpRequest.send();
      bytes = await httpResponse.stream.toBytes();
    } else if (provider is AssetAvifImage) {
      bytes = (await (provider.bundle ?? rootBundle).load(provider.asset))
          .buffer
          .asUint8List();
    } else if (provider is FileAvifImage) {
      bytes = await provider.file.readAsBytes();
    } else if (provider is MemoryAvifImage) {
      bytes = provider.bytes;
    }

    AvifCodec codec = MultiFrameAvifCodec(
      key: Object.hash("animation_", provider.hashCode),
      avifBytes: bytes,
    );
    await codec.ready();
    List<ImageInfo> infos = [];
    Duration duration = const Duration();

    for (int i = 0; i < codec.frameCount; i++) {
      AvifFrameInfo frameInfo = await codec.getNextFrame();
      infos.add(ImageInfo(image: frameInfo.image));
      duration += frameInfo.duration;
    }
    codec.dispose();

    return AvifAnimationInfo(frames: infos, duration: duration);
  }
}
