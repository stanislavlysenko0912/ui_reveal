part of 'reveal_core.dart';

/// Hosts reveal transitions above [child].
class RevealHost extends StatefulWidget {
  /// Creates a [RevealHost].
  const RevealHost({
    required this.controller,
    required this.child,
    this.config = const RevealConfig(),
    super.key,
  });

  /// Controller used to start reveal transitions.
  final RevealController controller;

  /// Animation configuration for this host.
  final RevealConfig config;

  /// Content rendered under reveal overlay.
  final Widget child;

  @override
  State<RevealHost> createState() => _RevealHostState();
}

class _RevealHostState extends State<RevealHost>
    with SingleTickerProviderStateMixin
    implements _RevealHostAdapter {
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  late final AnimationController _animationController;
  late Animation<double> _progressAnimation;
  _RevealFrameData? _frameData;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.config.duration,
    );
    _progressAnimation = _createProgressAnimation();
    widget.controller._attachHost(this);
  }

  @override
  void didUpdateWidget(covariant RevealHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncController(oldWidget);
    _syncConfig(oldWidget.config);
  }

  @override
  void dispose() {
    widget.controller._detachHost(this);
    _animationController.dispose();
    _disposeFrameData();
    super.dispose();
  }

  @override
  Future<void> runTransition({
    required Offset center,
    required Future<void> Function() onSwitch,
    required RevealEffect effect,
    required RevealDirection direction,
  }) async {
    final snapshotImage = await _captureSnapshotImage();
    if (snapshotImage == null) {
      await onSwitch();
      return;
    }

    _setFrameData(
      _RevealFrameData(
        snapshotImage: snapshotImage,
        center: center,
        effect: effect,
        direction: direction,
      ),
    );

    await _waitForFrameStabilization();
    try {
      await onSwitch();
      if (mounted) {
        await _animationController.forward(from: 0);
      }
    } finally {
      _clearFrameData();
      _animationController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RepaintBoundary(key: _repaintBoundaryKey, child: widget.child),
        if (_frameData != null)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _progressAnimation,
                builder: _buildOverlay,
              ),
            ),
          ),
      ],
    );
  }

  Animation<double> _createProgressAnimation() {
    return CurvedAnimation(
      parent: _animationController,
      curve: widget.config.curve,
    );
  }

  void _syncController(RevealHost oldWidget) {
    if (identical(oldWidget.controller, widget.controller)) {
      return;
    }
    oldWidget.controller._detachHost(this);
    widget.controller._attachHost(this);
  }

  void _syncConfig(RevealConfig oldConfig) {
    if (oldConfig.duration != widget.config.duration) {
      _animationController.duration = widget.config.duration;
    }
    if (oldConfig.curve != widget.config.curve) {
      _progressAnimation = _createProgressAnimation();
    }
  }

  Widget _buildOverlay(BuildContext context, Widget? _) {
    final frameData = _frameData;
    if (frameData == null) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final effectContext = RevealEffectContext(
          snapshotImage: frameData.snapshotImage,
          center: frameData.center,
          progress: _progressAnimation.value,
          direction: frameData.direction,
          size: constraints.biggest,
        );
        return frameData.effect.buildOverlay(effectContext);
      },
    );
  }

  Future<ui.Image?> _captureSnapshotImage() async {
    await _waitForFrameStabilization();
    if (!mounted) {
      return null;
    }

    final renderObject = _repaintBoundaryKey.currentContext?.findRenderObject();
    if (renderObject is! RenderRepaintBoundary) {
      return null;
    }

    try {
      final mediaQueryRatio = MediaQuery.maybeDevicePixelRatioOf(context);
      final pixelRatio = mediaQueryRatio ?? View.of(context).devicePixelRatio;
      return renderObject.toImage(pixelRatio: pixelRatio);
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'ui_reveal',
          context: ErrorDescription('capturing reveal snapshot'),
        ),
      );
      return null;
    }
  }

  Future<void> _waitForFrameStabilization() {
    return SchedulerBinding.instance.endOfFrame;
  }

  void _setFrameData(_RevealFrameData frameData) {
    if (!mounted) {
      frameData.snapshotImage.dispose();
      return;
    }

    setState(() {
      _disposeFrameData();
      _frameData = frameData;
    });
  }

  void _clearFrameData() {
    if (!mounted) {
      _disposeFrameData();
      return;
    }

    setState(_disposeFrameData);
  }

  void _disposeFrameData() {
    _frameData?.snapshotImage.dispose();
    _frameData = null;
  }
}

class _RevealFrameData {
  const _RevealFrameData({
    required this.snapshotImage,
    required this.center,
    required this.effect,
    required this.direction,
  });

  final ui.Image snapshotImage;
  final Offset center;
  final RevealEffect effect;
  final RevealDirection direction;
}
