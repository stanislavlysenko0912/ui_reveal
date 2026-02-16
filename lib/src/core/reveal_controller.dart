part of 'reveal_core.dart';

/// Orchestrates reveal transitions for an attached [RevealHost].
class RevealController {
  _RevealHostAdapter? _host;
  bool _isTransitionRunning = false;

  /// Starts a reveal transition.
  ///
  /// Throws [StateError] when no host is attached or when another
  /// transition is already active.
  /// Throws [ArgumentError] when [center] is not finite.
  Future<void> start({
    required Offset center,
    required Future<void> Function() onSwitch,
    required RevealEffect effect,
    RevealDirection direction = RevealDirection.reveal,
  }) async {
    _validateCenter(center);
    if (_isTransitionRunning) {
      throw StateError('Reveal transition is already running.');
    }

    final host = _host;
    if (host == null) {
      throw StateError('RevealController is not attached to a RevealHost.');
    }

    _isTransitionRunning = true;
    try {
      await host.runTransition(
        center: center,
        onSwitch: onSwitch,
        effect: effect,
        direction: direction,
      );
    } finally {
      _isTransitionRunning = false;
    }
  }

  void _attachHost(_RevealHostAdapter host) {
    final currentHost = _host;
    if (currentHost != null && !identical(currentHost, host)) {
      throw StateError(
        'RevealController can only be attached to a single RevealHost.',
      );
    }
    _host = host;
  }

  void _detachHost(_RevealHostAdapter host) {
    if (identical(_host, host)) {
      _host = null;
    }
  }

  void _validateCenter(Offset center) {
    if (center.dx.isFinite && center.dy.isFinite) {
      return;
    }
    throw ArgumentError.value(center, 'center', 'Center must be finite.');
  }
}

abstract interface class _RevealHostAdapter {
  Future<void> runTransition({
    required Offset center,
    required Future<void> Function() onSwitch,
    required RevealEffect effect,
    required RevealDirection direction,
  });
}
