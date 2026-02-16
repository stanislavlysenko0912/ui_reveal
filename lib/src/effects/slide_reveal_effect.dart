import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/reveal_core.dart';

/// Slide transition effect that wipes old content away in [slideDirection].
///
/// The snapshot is clipped to a shrinking rectangle — the new content is
/// progressively uncovered from the opposite edge.
///
/// When [enableFade] is `true`, a gradient fade softens the leading edge
/// of the wipe instead of a hard cut.
class SlideRevealEffect extends RevealEffect {
  /// Creates a slide reveal strategy.
  const SlideRevealEffect({
    this.slideDirection = AxisDirection.left,
    this.enableFade = true,
    this.fadeStrength = 1.0,
  }) : assert(
         fadeStrength >= 0 && fadeStrength <= 1,
         'fadeStrength must be in [0, 1].',
       );

  /// Direction the old content is wiped **towards** during reveal.
  final AxisDirection slideDirection;

  /// When `true`, applies a gradient fade at the leading edge of the wipe.
  final bool enableFade;

  /// Edge fade intensity in range [0, 1].
  ///
  /// `0` disables fade softness (hard edge), `1` is the default softness.
  final double fadeStrength;

  @override
  Widget buildOverlay(RevealEffectContext context) {
    return CustomPaint(
      size: context.size,
      painter: _SlideRevealPainter(
        context: context,
        slideDirection: slideDirection,
        enableFade: enableFade,
        fadeStrength: fadeStrength,
      ),
    );
  }
}

class _SlideRevealPainter extends CustomPainter {
  const _SlideRevealPainter({
    required this.context,
    required this.slideDirection,
    required this.enableFade,
    required this.fadeStrength,
  });

  final RevealEffectContext context;
  final AxisDirection slideDirection;
  final bool enableFade;
  final double fadeStrength;

  static const _fadeEdgeRatio = 0.18;
  static const _minFadeExtent = 6.0;

  @override
  void paint(Canvas canvas, Size size) {
    final progress = context.progress.clamp(0.0, 1.0).toDouble();
    final effectiveDirection = _effectiveDirection;
    final clipRect = _calculateClipRect(progress, size, effectiveDirection);

    canvas.save();
    canvas.clipRect(Offset.zero & size);

    if (enableFade && fadeStrength > 0) {
      _paintWithEdgeFade(canvas, size, clipRect, effectiveDirection);
    } else {
      canvas.clipRect(clipRect);
      paintImage(
        canvas: canvas,
        rect: Offset.zero & size,
        image: context.snapshotImage,
        fit: BoxFit.cover,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SlideRevealPainter oldDelegate) {
    return oldDelegate.context.progress != context.progress ||
        oldDelegate.context.snapshotImage != context.snapshotImage ||
        oldDelegate.context.direction != context.direction ||
        oldDelegate.slideDirection != slideDirection ||
        oldDelegate.enableFade != enableFade ||
        oldDelegate.fadeStrength != fadeStrength;
  }

  /// Conceal flips the wipe direction so the snapshot enters from the
  /// opposite side instead of replaying the same wipe backwards.
  AxisDirection get _effectiveDirection {
    if (context.direction == RevealDirection.conceal) {
      return switch (slideDirection) {
        AxisDirection.left => AxisDirection.right,
        AxisDirection.right => AxisDirection.left,
        AxisDirection.up => AxisDirection.down,
        AxisDirection.down => AxisDirection.up,
      };
    }
    return slideDirection;
  }

  /// Clip rect that shrinks from full → zero in [direction].
  Rect _calculateClipRect(double progress, Size size, AxisDirection direction) {
    final t = progress;

    return switch (direction) {
      AxisDirection.left => Rect.fromLTRB(
        0,
        0,
        size.width * (1 - t),
        size.height,
      ),
      AxisDirection.right => Rect.fromLTRB(
        size.width * t,
        0,
        size.width,
        size.height,
      ),
      AxisDirection.up => Rect.fromLTRB(
        0,
        0,
        size.width,
        size.height * (1 - t),
      ),
      AxisDirection.down => Rect.fromLTRB(
        0,
        size.height * t,
        size.width,
        size.height,
      ),
    };
  }

  /// Paints the snapshot with a gradient fade at the leading edge.
  void _paintWithEdgeFade(
    Canvas canvas,
    Size size,
    Rect clipRect,
    AxisDirection direction,
  ) {
    final isHorizontal =
        direction == AxisDirection.left || direction == AxisDirection.right;
    final totalExtent = isHorizontal ? size.width : size.height;
    final clipExtent = isHorizontal ? clipRect.width : clipRect.height;
    if (clipExtent <= _minFadeExtent) {
      canvas.clipRect(clipRect);
      paintImage(
        canvas: canvas,
        rect: Offset.zero & size,
        image: context.snapshotImage,
        fit: BoxFit.cover,
      );
      return;
    }

    final fadeExtent = _calculateFadeExtent(totalExtent, clipExtent);

    final shader = _buildEdgeGradient(clipRect, direction, fadeExtent);
    final maskPaint = Paint()
      ..shader = shader
      ..blendMode = BlendMode.dstIn;

    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.clipRect(clipRect);
    paintImage(
      canvas: canvas,
      rect: Offset.zero & size,
      image: context.snapshotImage,
      fit: BoxFit.cover,
    );
    canvas.drawRect(clipRect, maskPaint);
    canvas.restore();
  }

  /// Gradient that goes from opaque (trailing side) to transparent
  /// (leading edge of the wipe).
  ui.Shader _buildEdgeGradient(
    Rect clipRect,
    AxisDirection direction,
    double fadeExtent,
  ) {
    final (Offset begin, Offset end) = switch (direction) {
      AxisDirection.left => (
        Offset(clipRect.right - fadeExtent, 0),
        Offset(clipRect.right, 0),
      ),
      AxisDirection.right => (
        Offset(clipRect.left + fadeExtent, 0),
        Offset(clipRect.left, 0),
      ),
      AxisDirection.up => (
        Offset(0, clipRect.bottom - fadeExtent),
        Offset(0, clipRect.bottom),
      ),
      AxisDirection.down => (
        Offset(0, clipRect.top + fadeExtent),
        Offset(0, clipRect.top),
      ),
    };

    return ui.Gradient.linear(
      begin,
      end,
      const [Color(0xFFFFFFFF), Color(0xFFFFFFFF), Color(0x00FFFFFF)],
      const [0.0, 0.35, 1.0],
    );
  }

  double _calculateFadeExtent(double totalExtent, double clipExtent) {
    final desired = totalExtent * _fadeEdgeRatio * fadeStrength;
    final maxAllowed = clipExtent * 0.8;
    final minAllowed = _minFadeExtent * fadeStrength;
    return desired.clamp(minAllowed, maxAllowed);
  }
}
