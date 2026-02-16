import '../core/reveal_core.dart';
import 'circular_reveal_effect.dart';
import 'fade_reveal_effect.dart';
import 'scale_reveal_effect.dart';

/// Built-in reveal effects namespace.
final class RevealEffects {
  const RevealEffects._();

  /// Circular reveal effect factory.
  static CircularRevealEffect circular({bool enableEdgeGlow = true}) {
    return CircularRevealEffect(enableEdgeGlow: enableEdgeGlow);
  }

  /// Fade reveal effect factory.
  static FadeRevealEffect fade() {
    return const FadeRevealEffect();
  }

  /// Scale reveal effect factory.
  static ScaleRevealEffect scale({double maxScale = 1.08}) {
    return ScaleRevealEffect(maxScale: maxScale);
  }

  /// Returns all default built-in effects.
  static List<RevealEffect> all() {
    return <RevealEffect>[circular(), fade(), scale()];
  }
}
