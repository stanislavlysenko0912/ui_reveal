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
- `RevealConfig`
- `RevealController.start(...)`
- `RevealEffect` / `RevealEffectContext`
- `RevealDirection` (`reveal`, `conceal`)
- `BuildContext.revealCenter`

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

## Effects

Use any built-in effect through the same API:

```dart
const CircularRevealEffect();
const FadeRevealEffect();
const ScaleRevealEffect();
```

You can add custom effects by implementing `RevealEffect`.

## Runtime Guarantees

- `RevealController.start` throws `ArgumentError` when `center` is non-finite.
- `RevealController.start` throws `StateError` when called during an active transition.
- `RevealController.start` throws `StateError` when controller is not attached to `RevealHost`.
- `onSwitch` is called exactly once per `start` call.

## Example

See a complete integration sample in `example/lib/main.dart`.
