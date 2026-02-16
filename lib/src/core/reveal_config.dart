part of 'reveal_core.dart';

/// Configuration for reveal transition timing.
class RevealConfig {
  /// Creates immutable reveal animation settings.
  const RevealConfig({
    this.duration = const Duration(milliseconds: 560),
    this.curve = Curves.easeInOut,
  });

  /// Duration of a single reveal animation.
  final Duration duration;

  /// Curve applied to transition progress.
  final Curve curve;
}
