import 'package:flutter/material.dart';

import '../core/reveal_core.dart';
import '../core/reveal_scope.dart';
import '../effects/circular_reveal_effect.dart';

/// Utilities for reveal transition geometry.
extension BuildContextRevealExtension on BuildContext {
  /// Returns global center for the render box associated with this context.
  ///
  /// Throws [StateError] when context does not resolve to a [RenderBox].
  Offset get revealCenter {
    final renderObject = findRenderObject();
    if (renderObject is! RenderBox) {
      throw StateError(
        'Reveal center is unavailable because context has no RenderBox.',
      );
    }

    final origin = renderObject.localToGlobal(Offset.zero);
    final size = renderObject.size;
    return Offset(origin.dx + size.width / 2, origin.dy + size.height / 2);
  }

  /// Starts reveal transition with a controller from [RevealScope].
  ///
  /// Throws [StateError] when no [RevealScope] exists in the widget tree.
  Future<void> startReveal({
    required Future<void> Function() onSwitch,
    RevealEffect effect = const CircularRevealEffect(),
    RevealDirection direction = RevealDirection.reveal,
    Offset? center,
  }) {
    final controller = RevealScope.maybeOf(this);
    if (controller == null) {
      throw StateError(
        'BuildContext.startReveal() requires a RevealScope ancestor.',
      );
    }

    return controller.start(
      center: center ?? revealCenter,
      onSwitch: onSwitch,
      effect: effect,
      direction: direction,
    );
  }
}
