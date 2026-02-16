import 'package:flutter/material.dart';

import '../core/reveal_core.dart';

/// Policy for selecting [RevealDirection] at the app layer.
enum RevealDirectionMode {
  /// Use direction selected explicitly by the caller.
  explicit,

  /// Alternate between reveal and conceal on each transition.
  toggle,

  /// Resolve direction from theme brightness change.
  byThemeBrightness,
}

/// Helpers for resolving reveal direction without changing package core API.
final class RevealDirectionResolver {
  const RevealDirectionResolver._();

  /// Returns opposite direction of [previousDirection].
  static RevealDirection toggle({required RevealDirection previousDirection}) {
    if (previousDirection == RevealDirection.reveal) {
      return RevealDirection.conceal;
    }
    return RevealDirection.reveal;
  }

  /// Resolves direction from theme brightness transition.
  ///
  /// Returns [fallbackDirection] when brightness does not change.
  static RevealDirection byThemeBrightness({
    required Brightness fromBrightness,
    required Brightness toBrightness,
    RevealDirection darkerTargetDirection = RevealDirection.reveal,
    RevealDirection lighterTargetDirection = RevealDirection.conceal,
    RevealDirection fallbackDirection = RevealDirection.reveal,
  }) {
    if (fromBrightness == toBrightness) {
      return fallbackDirection;
    }

    if (toBrightness == Brightness.dark) {
      return darkerTargetDirection;
    }
    return lighterTargetDirection;
  }
}
