# ui_reveal

`ui_reveal` is a Flutter package that animates UI switches using snapshot-based reveal effects.
It is package-agnostic and exposes a minimal API built around `RevealHost`, `RevealController`, and `RevealEffect`.

## Features

- Host-based snapshot overlay with a clean controller API.
- Pluggable effects via `RevealEffect` strategy.
- Built-in effects: `CircularRevealEffect`, `FadeRevealEffect`, `ScaleRevealEffect`.
- Fail-fast runtime checks for invalid usage.
- Fallback path: if snapshot capture fails, `onSwitch` still runs without animation.

## Public API

- `RevealHost`
- `RevealScope` (high-level wrapper with optional auto controller)
- `RevealConfig`
- `RevealController.start(...)`
- `RevealEffect` / `RevealEffectContext`
- `RevealDirection` (`reveal`, `conceal`)
- `BuildContext.revealCenter`
- `BuildContext.startReveal(...)` (convenience)

## Getting Started

Add dependency:

```yaml
dependencies:
  ui_reveal: ^1.0.0
```

Wrap your app content with `RevealHost`:

```dart
final revealController = RevealController();

MaterialApp(
  builder: (context, child) {
    return RevealHost(
      controller: revealController,
      config: const RevealConfig(
        duration: Duration(milliseconds: 560),
        curve: Curves.easeInOut,
      ),
      child: child ?? const SizedBox.shrink(),
    );
  },
);
```

For minimal setup, use `RevealScope`:

```dart
MaterialApp(
  builder: (context, child) => RevealScope(
    child: child ?? const SizedBox.shrink(),
  ),
  home: HomePage(),
);
```

Start transition from a widget center:

```dart
await revealController.start(
  center: context.revealCenter,
  effect: const CircularRevealEffect(),
  direction: RevealDirection.reveal,
  onSwitch: () async {
    setState(() {
      isDarkTheme = !isDarkTheme;
    });
  },
);
```

## API Styles

`RevealScope` gives you two ways to trigger transitions.

### Style A: `RevealScope.of(context)` (recommended)

```dart
await RevealScope.of(context).start(
  center: context.revealCenter,
  effect: const CircularRevealEffect(),
  direction: RevealDirection.reveal,
  onSwitch: () async => setState(() => isDark = !isDark),
);
```

### Style B: `context.startReveal(...)` (shortcut)

```dart
await context.startReveal(
  effect: const CircularRevealEffect(),
  direction: RevealDirection.reveal,
  onSwitch: () async => setState(() => isDark = !isDark),
);
```

## Effects

Use any built-in effect through the same API:

```dart
const CircularRevealEffect();
const FadeRevealEffect();
const ScaleRevealEffect();
```

You can add custom effects by implementing `RevealEffect`.

## Direction Handling

`ui_reveal` keeps direction explicit in the core API:

```dart
direction: RevealDirection.reveal // or RevealDirection.conceal
```

If you want automatic behavior (`toggle` or `byThemeBrightness`), use
`RevealDirectionResolver` and keep the selected mode in app-level state.

### Explicit

```dart
await controller.start(
  center: context.revealCenter,
  effect: const CircularRevealEffect(),
  direction: RevealDirection.conceal,
  onSwitch: () async => setState(() => isDark = false),
);
```

### Toggle

```dart
final direction = RevealDirectionResolver.toggle(
  previousDirection: lastResolvedDirection,
);

await controller.start(
  center: context.revealCenter,
  effect: const FadeRevealEffect(),
  direction: direction,
  onSwitch: () async => setState(() => isGrid = !isGrid),
);
lastResolvedDirection = direction;
```

### By Theme Brightness

```dart
final direction = RevealDirectionResolver.byThemeBrightness(
  fromBrightness: isDark ? Brightness.dark : Brightness.light,
  toBrightness: isDark ? Brightness.light : Brightness.dark,
  fallbackDirection: RevealDirection.reveal,
);

await controller.start(
  center: context.revealCenter,
  effect: const ScaleRevealEffect(),
  direction: direction,
  onSwitch: () async => setState(() => isDark = !isDark),
);
```

## Runtime Guarantees

- `RevealController.start` throws `ArgumentError` when `center` is non-finite.
- `RevealController.start` throws `StateError` when called during an active transition.
- `RevealController.start` throws `StateError` when controller is not attached to `RevealHost`.
- `onSwitch` is called exactly once per `start` call.

## Theme Animation Note

When switching `themeMode` inside `onSwitch`, `MaterialApp` also runs its own
theme transition animation by default. If you want reveal to be the only visible
animation, set:

```dart
MaterialApp(
  themeAnimationDuration: Duration.zero,
  // ...
)
```

## Example

See a complete integration sample in `example/lib/main.dart`.
