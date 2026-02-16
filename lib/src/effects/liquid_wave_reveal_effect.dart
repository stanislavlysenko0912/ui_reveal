import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/reveal_core.dart';

/// Wipe reveal with a fluid sine-wave leading edge.
class LiquidWaveRevealEffect extends RevealEffect {
  /// Creates a liquid wave reveal strategy.
  const LiquidWaveRevealEffect({
    this.waveCount = 3,
    this.amplitude = 18,
    this.slideDirection = AxisDirection.left,
  }) : assert(waveCount > 0, 'waveCount must be greater than zero.'),
       assert(
         amplitude >= 0,
         'amplitude must be greater than or equal to zero.',
       );

  /// Number of wave periods across the orthogonal axis.
  final int waveCount;

  /// Wave amplitude in logical pixels.
  final double amplitude;

  /// Direction the old content is wiped towards.
  final AxisDirection slideDirection;

  @override
  Widget buildOverlay(RevealEffectContext context) {
    return CustomPaint(
      size: context.size,
      painter: _LiquidWaveRevealPainter(
        context: context,
        waveCount: waveCount,
        amplitude: amplitude,
        slideDirection: slideDirection,
      ),
    );
  }
}

class _LiquidWaveRevealPainter extends CustomPainter {
  const _LiquidWaveRevealPainter({
    required this.context,
    required this.waveCount,
    required this.amplitude,
    required this.slideDirection,
  });

  final RevealEffectContext context;
  final int waveCount;
  final double amplitude;
  final AxisDirection slideDirection;

  static const _sampleStep = 6.0;
  static const _overshootPadding = 12.0;

  @override
  void paint(Canvas canvas, Size size) {
    final progress = context.progress.clamp(0.0, 1.0).toDouble();
    final direction = _effectiveDirection();
    final clipPath = _buildPath(size, progress, direction);
    canvas.save();
    canvas.clipPath(clipPath);
    paintImage(
      canvas: canvas,
      rect: Offset.zero & size,
      image: context.snapshotImage,
      fit: BoxFit.cover,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _LiquidWaveRevealPainter oldDelegate) {
    return oldDelegate.context.progress != context.progress ||
        oldDelegate.context.snapshotImage != context.snapshotImage ||
        oldDelegate.context.direction != context.direction ||
        oldDelegate.waveCount != waveCount ||
        oldDelegate.amplitude != amplitude ||
        oldDelegate.slideDirection != slideDirection;
  }

  AxisDirection _effectiveDirection() {
    if (context.direction == RevealDirection.reveal) {
      return slideDirection;
    }
    return switch (slideDirection) {
      AxisDirection.left => AxisDirection.right,
      AxisDirection.right => AxisDirection.left,
      AxisDirection.up => AxisDirection.down,
      AxisDirection.down => AxisDirection.up,
    };
  }

  Path _buildPath(Size size, double progress, AxisDirection direction) {
    return switch (direction) {
      AxisDirection.left => _buildHorizontalPath(size, progress, true),
      AxisDirection.right => _buildHorizontalPath(size, progress, false),
      AxisDirection.up => _buildVerticalPath(size, progress, true),
      AxisDirection.down => _buildVerticalPath(size, progress, false),
    };
  }

  Path _buildHorizontalPath(Size size, double progress, bool fromLeft) {
    final overshoot = amplitude + _overshootPadding;
    final baseX = fromLeft
        ? _lerp(size.width + overshoot, -overshoot, progress)
        : _lerp(-overshoot, size.width + overshoot, progress);
    final path = Path()
      ..moveTo(fromLeft ? -overshoot : size.width + overshoot, -overshoot);
    for (var y = 0.0; y <= size.height; y += _sampleStep) {
      final x = _horizontalWaveX(baseX, y, size);
      path.lineTo(x, y);
    }
    final edgeY = size.height + overshoot;
    path
      ..lineTo(_horizontalWaveX(baseX, size.height, size), size.height)
      ..lineTo(fromLeft ? -overshoot : size.width + overshoot, edgeY);
    return path..close();
  }

  Path _buildVerticalPath(Size size, double progress, bool fromTop) {
    final overshoot = amplitude + _overshootPadding;
    final baseY = fromTop
        ? _lerp(size.height + overshoot, -overshoot, progress)
        : _lerp(-overshoot, size.height + overshoot, progress);
    final path = Path()
      ..moveTo(-overshoot, fromTop ? -overshoot : size.height + overshoot);
    for (var x = 0.0; x <= size.width; x += _sampleStep) {
      final y = _verticalWaveY(baseY, x, size);
      path.lineTo(x, y);
    }
    final edgeX = size.width + overshoot;
    path
      ..lineTo(size.width, _verticalWaveY(baseY, size.width, size))
      ..lineTo(edgeX, fromTop ? -overshoot : size.height + overshoot);
    return path..close();
  }

  double _horizontalWaveX(double baseX, double y, Size size) {
    final phase = (y / size.height) * waveCount * math.pi * 2;
    final animated = phase + (context.progress * math.pi * 2);
    final offset = math.sin(animated) * amplitude;
    return baseX + offset;
  }

  double _verticalWaveY(double baseY, double x, Size size) {
    final phase = (x / size.width) * waveCount * math.pi * 2;
    final animated = phase + (context.progress * math.pi * 2);
    final offset = math.sin(animated) * amplitude;
    return baseY + offset;
  }

  double _lerp(double a, double b, double t) {
    return a + (b - a) * t;
  }
}
