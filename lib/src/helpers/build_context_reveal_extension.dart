import 'package:flutter/material.dart';

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
}
