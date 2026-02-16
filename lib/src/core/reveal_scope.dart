import 'package:flutter/widgets.dart';

import 'reveal_core.dart';

/// High-level reveal entrypoint that hosts [RevealHost] and controller.
class RevealScope extends StatefulWidget {
  /// Creates a [RevealScope].
  ///
  /// If [controller] is omitted, an internal controller is created.
  const RevealScope({
    required this.child,
    this.config = const RevealConfig(),
    this.controller,
    super.key,
  });

  /// Descendant subtree that can trigger reveal transitions.
  final Widget child;

  /// Configuration forwarded to inner [RevealHost].
  final RevealConfig config;

  /// Optional externally managed controller.
  final RevealController? controller;

  /// Returns nearest reveal controller in the widget tree.
  ///
  /// Throws [StateError] when no [RevealScope] is found.
  static RevealController of(BuildContext context) {
    final controller = maybeOf(context);
    if (controller == null) {
      throw StateError('RevealScope.of() called with no RevealScope ancestor.');
    }
    return controller;
  }

  /// Returns nearest reveal controller in the widget tree, if any.
  static RevealController? maybeOf(BuildContext context) {
    final inherited = context
        .dependOnInheritedWidgetOfExactType<_RevealScopeInherited>();
    return inherited?.controller;
  }

  @override
  State<RevealScope> createState() => _RevealScopeState();
}

class _RevealScopeState extends State<RevealScope> {
  late final RevealController _internalController = RevealController();

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller ?? _internalController;
    return _RevealScopeInherited(
      controller: controller,
      child: RevealHost(
        controller: controller,
        config: widget.config,
        child: widget.child,
      ),
    );
  }
}

class _RevealScopeInherited extends InheritedWidget {
  const _RevealScopeInherited({required this.controller, required super.child});

  final RevealController controller;

  @override
  bool updateShouldNotify(_RevealScopeInherited oldWidget) {
    return !identical(controller, oldWidget.controller);
  }
}
