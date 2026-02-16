part of 'reveal_core.dart';

/// Rendering data for a single reveal frame.
class RevealEffectContext {
  /// Creates immutable rendering input for [RevealEffect].
  RevealEffectContext({
    required this.snapshotImage,
    required this.center,
    required this.progress,
    required this.direction,
    required this.size,
  }) {
    if (!center.dx.isFinite || !center.dy.isFinite) {
      throw ArgumentError.value(center, 'center', 'Center must be finite.');
    }
    if (!progress.isFinite || progress < 0 || progress > 1) {
      throw ArgumentError.value(
        progress,
        'progress',
        'Progress must be in [0, 1].',
      );
    }
    if (!size.width.isFinite || !size.height.isFinite) {
      throw ArgumentError.value(size, 'size', 'Size must be finite.');
    }
  }

  /// Snapshot captured before content switch.
  final ui.Image snapshotImage;

  /// Global transition center.
  final Offset center;

  /// Animation progress in range [0, 1].
  final double progress;

  /// Direction selected for current transition.
  final RevealDirection direction;

  /// Paint area size.
  final Size size;
}
