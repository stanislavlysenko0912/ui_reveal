import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/reveal_core.dart';

/// Circular reveal effect centered at transition origin.
class CircularRevealEffect extends RevealEffect {
  /// Creates a circular reveal strategy.
  const CircularRevealEffect({this.enableEdgeGlow = true});

  /// Enables subtle edge glow near animation end for conceal direction.
  final bool enableEdgeGlow;

  @override
  Widget buildOverlay(RevealEffectContext context) {
    return CustomPaint(
      size: context.size,
      painter: _CircularRevealPainter(
        context: context,
        enableEdgeGlow: enableEdgeGlow,
      ),
    );
  }
}

class _CircularRevealPainter extends CustomPainter {
  const _CircularRevealPainter({
    required this.context,
    required this.enableEdgeGlow,
  });

  final RevealEffectContext context;
  final bool enableEdgeGlow;

  @override
  void paint(Canvas canvas, Size size) {
    final maxRadius = _calculateMaxRadius(context.center, size);
    final radius = _calculateRadius(maxRadius);
    final opacity = _calculateOpacity(radius, maxRadius);

    canvas.saveLayer(Offset.zero & size, Paint());
    paintImage(
      canvas: canvas,
      rect: Offset.zero & size,
      image: context.snapshotImage,
      fit: BoxFit.cover,
      colorFilter: ColorFilter.mode(_white(opacity), BlendMode.modulate),
    );

    canvas.drawCircle(
      context.center,
      radius,
      Paint()
        ..blendMode = BlendMode.dstOut
        ..style = PaintingStyle.fill,
    );

    if (_shouldPaintGlow(radius, maxRadius)) {
      _paintGlow(canvas, radius, maxRadius);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CircularRevealPainter oldDelegate) {
    return oldDelegate.context.progress != context.progress ||
        oldDelegate.context.snapshotImage != context.snapshotImage ||
        oldDelegate.context.center != context.center ||
        oldDelegate.context.direction != context.direction ||
        oldDelegate.enableEdgeGlow != enableEdgeGlow;
  }

  double _calculateMaxRadius(Offset center, Size size) {
    final topLeft = center.distance;
    final topRight = (center - Offset(size.width, 0)).distance;
    final bottomLeft = (center - Offset(0, size.height)).distance;
    final bottomRight = (center - Offset(size.width, size.height)).distance;
    return [topLeft, topRight, bottomLeft, bottomRight].reduce(math.max);
  }

  double _calculateRadius(double maxRadius) {
    final progress = context.progress;
    if (context.direction == RevealDirection.conceal) {
      return maxRadius * (1 - progress);
    }
    return maxRadius * progress;
  }

  double _calculateOpacity(double radius, double maxRadius) {
    if (context.direction != RevealDirection.conceal) {
      return 1;
    }

    final fadeThreshold = maxRadius * 0.15;
    if (radius >= fadeThreshold) {
      return 1;
    }

    final normalized = (radius / fadeThreshold).clamp(0.0, 1.0).toDouble();
    return math.pow(normalized, 0.7).toDouble();
  }

  bool _shouldPaintGlow(double radius, double maxRadius) {
    if (!enableEdgeGlow || context.direction != RevealDirection.conceal) {
      return false;
    }
    return radius < maxRadius * 0.10;
  }

  void _paintGlow(Canvas canvas, double radius, double maxRadius) {
    final glowProgress = 1 - (radius / (maxRadius * 0.10));
    final alpha = (glowProgress * 0.25).clamp(0.0, 1.0).toDouble();
    canvas.drawCircle(
      context.center,
      radius + 12,
      Paint()
        ..color = _white(alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
  }

  Color _white(double opacity) {
    final alpha = opacity.clamp(0.0, 1.0).toDouble();
    return Color.fromRGBO(255, 255, 255, alpha);
  }
}
