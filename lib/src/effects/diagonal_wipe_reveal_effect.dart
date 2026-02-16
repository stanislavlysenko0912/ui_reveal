import 'package:flutter/material.dart';

import '../core/reveal_core.dart';

/// Diagonal wipe transition that uncovers new content along a diagonal.
class DiagonalWipeRevealEffect extends RevealEffect {
  /// Creates a diagonal wipe reveal strategy.
  const DiagonalWipeRevealEffect({
    this.direction = DiagonalWipeDirection.topLeftToBottomRight,
  });

  /// Diagonal direction used for reveal animation.
  final DiagonalWipeDirection direction;

  @override
  Widget buildOverlay(RevealEffectContext context) {
    return CustomPaint(
      size: context.size,
      painter: _DiagonalWipeRevealPainter(
        context: context,
        direction: direction,
      ),
    );
  }
}

/// Supported diagonal wipe directions.
enum DiagonalWipeDirection { topLeftToBottomRight, bottomRightToTopLeft }

class _DiagonalWipeRevealPainter extends CustomPainter {
  const _DiagonalWipeRevealPainter({
    required this.context,
    required this.direction,
  });

  final RevealEffectContext context;
  final DiagonalWipeDirection direction;

  @override
  void paint(Canvas canvas, Size size) {
    final progress = context.progress.clamp(0.0, 1.0).toDouble();
    final activeDirection = _effectiveDirection();
    final clipPath = _buildVisiblePath(size, progress, activeDirection);
    if (clipPath == null) {
      return;
    }

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
  bool shouldRepaint(covariant _DiagonalWipeRevealPainter oldDelegate) {
    return oldDelegate.context.progress != context.progress ||
        oldDelegate.context.snapshotImage != context.snapshotImage ||
        oldDelegate.context.direction != context.direction ||
        oldDelegate.direction != direction;
  }

  DiagonalWipeDirection _effectiveDirection() {
    if (context.direction == RevealDirection.conceal) {
      return direction == DiagonalWipeDirection.topLeftToBottomRight
          ? DiagonalWipeDirection.bottomRightToTopLeft
          : DiagonalWipeDirection.topLeftToBottomRight;
    }
    return direction;
  }

  Path? _buildVisiblePath(
    Size size,
    double progress,
    DiagonalWipeDirection diagonalDirection,
  ) {
    final maxValue = size.width + size.height;
    final points = <Offset>[
      Offset.zero,
      Offset(size.width, 0),
      Offset(size.width, size.height),
      Offset(0, size.height),
    ];
    final threshold = switch (diagonalDirection) {
      DiagonalWipeDirection.topLeftToBottomRight => progress * maxValue,
      DiagonalWipeDirection.bottomRightToTopLeft => (1 - progress) * maxValue,
    };
    final keepHigh =
        diagonalDirection == DiagonalWipeDirection.topLeftToBottomRight;
    final clipped = _clipPolygonByDiagonal(points, threshold, keepHigh);
    if (clipped.isEmpty) {
      return null;
    }
    return Path()..addPolygon(clipped, true);
  }

  List<Offset> _clipPolygonByDiagonal(
    List<Offset> polygon,
    double threshold,
    bool keepHigh,
  ) {
    final result = <Offset>[];
    for (var i = 0; i < polygon.length; i += 1) {
      final current = polygon[i];
      final next = polygon[(i + 1) % polygon.length];
      final currentInside = _isInside(current, threshold, keepHigh);
      final nextInside = _isInside(next, threshold, keepHigh);

      if (currentInside && nextInside) {
        result.add(next);
        continue;
      }
      if (currentInside && !nextInside) {
        result.add(_intersect(current, next, threshold));
        continue;
      }
      if (!currentInside && nextInside) {
        result.add(_intersect(current, next, threshold));
        result.add(next);
      }
    }
    return result;
  }

  bool _isInside(Offset point, double threshold, bool keepHigh) {
    final value = point.dx + point.dy;
    if (keepHigh) {
      return value >= threshold;
    }
    return value <= threshold;
  }

  Offset _intersect(Offset a, Offset b, double threshold) {
    final delta = (b.dx + b.dy) - (a.dx + a.dy);
    if (delta.abs() < 0.0001) {
      return a;
    }
    final t = ((threshold - (a.dx + a.dy)) / delta).clamp(0.0, 1.0);
    return Offset(a.dx + (b.dx - a.dx) * t, a.dy + (b.dy - a.dy) * t);
  }
}
