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

    if (context.direction == RevealDirection.conceal) {
      _paintConceal(canvas, size, radius, maxRadius);
      return;
    }

    _paintReveal(canvas, size, radius);
  }

  void _paintReveal(Canvas canvas, Size size, double radius) {
    final outerClip = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addOval(Rect.fromCircle(center: context.center, radius: radius));

    canvas.save();
    canvas.clipPath(outerClip);
    paintImage(
      canvas: canvas,
      rect: Offset.zero & size,
      image: context.snapshotImage,
      fit: BoxFit.cover,
    );
    canvas.restore();
  }

  void _paintConceal(
    Canvas canvas,
    Size size,
    double radius,
    double maxRadius,
  ) {
    final innerClip = Path()
      ..addOval(Rect.fromCircle(center: context.center, radius: radius));

    canvas.save();
    canvas.clipPath(innerClip);
    paintImage(
      canvas: canvas,
      rect: Offset.zero & size,
      image: context.snapshotImage,
      fit: BoxFit.cover,
    );
    canvas.restore();

    if (_shouldPaintGlow(radius, maxRadius)) {
      _paintGlow(canvas, radius, maxRadius);
    }
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
    final progress = context.progress.clamp(0.0, 1.0).toDouble();
    if (context.direction == RevealDirection.conceal) {
      return maxRadius * math.sqrt(1 - progress);
    }
    return maxRadius * math.sqrt(progress);
  }

  bool _shouldPaintGlow(double radius, double maxRadius) {
    if (!enableEdgeGlow || context.direction != RevealDirection.conceal) {
      return false;
    }
    return radius < maxRadius * 0.15;
  }

  void _paintGlow(Canvas canvas, double radius, double maxRadius) {
    final glowProgress = 1 - (radius / (maxRadius * 0.10));
    final alpha = (glowProgress * 0.20).clamp(0.0, 1.0).toDouble();
    canvas.drawCircle(
      context.center,
      radius + 8,
      Paint()
        ..color = _white(alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
  }

  Color _white(double opacity) {
    final alpha = opacity.clamp(0.0, 1.0).toDouble();
    return Color.fromRGBO(255, 255, 255, alpha);
  }
}
