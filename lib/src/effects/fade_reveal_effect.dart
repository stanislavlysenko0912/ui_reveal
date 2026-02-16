import 'package:flutter/material.dart';

import '../core/reveal_core.dart';

/// Fade transition effect for reveal snapshots.
class FadeRevealEffect extends RevealEffect {
  /// Creates a fade reveal strategy.
  const FadeRevealEffect();

  @override
  Widget buildOverlay(RevealEffectContext context) {
    return CustomPaint(
      size: context.size,
      painter: _FadeRevealPainter(context),
    );
  }
}

class _FadeRevealPainter extends CustomPainter {
  const _FadeRevealPainter(this.context);

  final RevealEffectContext context;

  @override
  void paint(Canvas canvas, Size size) {
    final opacity = _calculateOpacity();
    paintImage(
      canvas: canvas,
      rect: Offset.zero & size,
      image: context.snapshotImage,
      fit: BoxFit.cover,
      colorFilter: ColorFilter.mode(_white(opacity), BlendMode.modulate),
    );
  }

  @override
  bool shouldRepaint(covariant _FadeRevealPainter oldDelegate) {
    return oldDelegate.context.progress != context.progress ||
        oldDelegate.context.snapshotImage != context.snapshotImage ||
        oldDelegate.context.direction != context.direction;
  }

  double _calculateOpacity() {
    return 1 - context.progress;
  }

  Color _white(double opacity) {
    final alpha = opacity.clamp(0.0, 1.0).toDouble();
    return Color.fromRGBO(255, 255, 255, alpha);
  }
}
