import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/reveal_core.dart';

/// Scale-and-fade transition effect for reveal snapshots.
class ScaleRevealEffect extends RevealEffect {
  /// Creates a scale reveal strategy.
  const ScaleRevealEffect({this.maxScale = 1.08})
    : assert(maxScale >= 1, 'maxScale must be at least 1.0');

  /// Maximum scale reached at the end of reveal direction.
  final double maxScale;

  @override
  Widget buildOverlay(RevealEffectContext context) {
    return CustomPaint(
      size: context.size,
      painter: _ScaleRevealPainter(context: context, maxScale: maxScale),
    );
  }
}

class _ScaleRevealPainter extends CustomPainter {
  const _ScaleRevealPainter({required this.context, required this.maxScale});

  final RevealEffectContext context;
  final double maxScale;

  @override
  void paint(Canvas canvas, Size size) {
    final progress = context.progress;
    final opacity = _calculateOpacity(progress);
    final scale = _calculateScale(progress);

    canvas.save();
    canvas.translate(context.center.dx, context.center.dy);
    canvas.scale(scale, scale);
    canvas.translate(-context.center.dx, -context.center.dy);
    paintImage(
      canvas: canvas,
      rect: Offset.zero & size,
      image: context.snapshotImage,
      fit: BoxFit.cover,
      colorFilter: ColorFilter.mode(_white(opacity), BlendMode.modulate),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ScaleRevealPainter oldDelegate) {
    return oldDelegate.context.progress != context.progress ||
        oldDelegate.context.snapshotImage != context.snapshotImage ||
        oldDelegate.context.center != context.center ||
        oldDelegate.context.direction != context.direction ||
        oldDelegate.maxScale != maxScale;
  }

  double _calculateOpacity(double progress) {
    return 1 - progress;
  }

  double _calculateScale(double progress) {
    if (context.direction == RevealDirection.conceal) {
      return lerpDouble(maxScale, 1, progress) ?? 1;
    }
    return lerpDouble(1, maxScale, progress) ?? 1;
  }

  Color _white(double opacity) {
    final alpha = opacity.clamp(0.0, 1.0).toDouble();
    return Color.fromRGBO(255, 255, 255, alpha);
  }
}
