part of 'reveal_core.dart';

/// Strategy interface for rendering reveal overlays.
abstract class RevealEffect {
  /// Creates a reveal effect strategy.
  const RevealEffect();

  /// Builds a widget for the current animation frame.
  Widget buildOverlay(RevealEffectContext context);
}
