import 'package:flutter/painting.dart';

import '../core/reveal_core.dart';
import 'circular_reveal_effect.dart';
import 'diagonal_wipe_reveal_effect.dart';
import 'fade_reveal_effect.dart';
import 'slide_reveal_effect.dart';

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

  /// Slide reveal effect factory.
  static SlideRevealEffect slide({
    AxisDirection slideDirection = AxisDirection.left,
    bool enableFade = true,
    double fadeStrength = 1.0,
  }) {
    return SlideRevealEffect(
      slideDirection: slideDirection,
      enableFade: enableFade,
      fadeStrength: fadeStrength,
    );
  }

  /// Diagonal wipe reveal effect factory.
  static DiagonalWipeRevealEffect diagonalWipe({
    DiagonalWipeDirection direction =
        DiagonalWipeDirection.topLeftToBottomRight,
  }) {
    return DiagonalWipeRevealEffect(direction: direction);
  }

  /// Returns all default built-in effects.
  static List<RevealEffect> all() {
    return <RevealEffect>[circular(), fade(), slide(), diagonalWipe()];
  }
}
