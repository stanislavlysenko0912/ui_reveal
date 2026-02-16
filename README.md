Snapshot-based UI transitions for Flutter with pluggable reveal effects.

`ui_reveal` captures the previous frame, runs your UI switch exactly once, and animates the transition using an effect strategy.</br>
Most often used to bring a little magic to your theme switching 🙌

## Table of Contents

- [Installation](#installation)
- [Quick Start](#quick-start)
- [API Styles](#api-styles)
- [Built-in Effects](#built-in-effects)
- [Direction Handling](#direction-handling)
- [Custom Effects](#custom-effects)
- [Theme Switching Notes](#theme-switching-notes)
- [FAQ](#faq)

## Installation

```bash
flutter pub add ui_reveal
```

## Quick Start

### 1. Add `RevealScope` via `MaterialApp.builder`

```dart
MaterialApp(
  builder: (context, child) => RevealScope(
    child: child ?? const SizedBox.shrink(),
  ),
  home: const HomePage(),
);
```

### 2. Trigger transition

```dart
await RevealScope.of(context).start(
  center: context.revealCenter,
  effect: RevealEffects.circular(),
  direction: RevealDirection.reveal,
  onSwitch: () async {
    setState(() {
      isDarkTheme = !isDarkTheme;
    });
  },
);
```

## API Styles

### Style A (recommended): `RevealScope.of(context)`

```dart
MaterialApp(
  builder: (context, child) => RevealScope(
    child: child ?? const SizedBox.shrink(),
  ),
  home: const HomePage(),
);

await RevealScope.of(context).start(
  center: context.revealCenter,
  effect: RevealEffects.fade(),
  direction: RevealDirection.reveal,
  onSwitch: () async => setState(() => isGrid = !isGrid),
);
```

### Style B (shortcut): `context.startReveal(...)`

```dart
await context.startReveal(
  effect: RevealEffects.slide(),
  direction: RevealDirection.reveal,
  onSwitch: () async => setState(() => isDark = !isDark),
);
```

## Built-in Effects

```dart
RevealEffects.circular();
RevealEffects.fade();
RevealEffects.slide();
RevealEffects.diagonalWipe();

RevealEffects.circular(enableEdgeGlow: false);
RevealEffects.slide(slideDirection: AxisDirection.right, fadeStrength: 0.6);
```

## Direction Handling

Direction is explicit in the core API:

```dart
direction: RevealDirection.reveal // or RevealDirection.conceal
```

### Explicit

```dart
await controller.start(
  center: context.revealCenter,
  effect: RevealEffects.circular(),
  direction: RevealDirection.conceal,
  onSwitch: () async => setState(() => isDark = false),
);
```

## Custom Effects

See real custom transition implementation in
[`example/lib/pages/custom_page.dart`](example/lib/pages/custom_page.dart) (`_BlindsRevealEffect`).

## Theme Switching Notes

When switching `themeMode`, preferred setup is disabling default theme animation so reveal is the only visible transition:

```dart
MaterialApp(
  themeAnimationDuration: Duration.zero,
  // ...
)
```

## FAQ

### Why is `onSwitch` required?
`onSwitch` defines the exact state-change point between snapshot capture and transition playback.

### Can I use it without manual controller lifecycle?
Yes, use `RevealScope` + `RevealScope.of(context)` or `context.startReveal(...)`.

### Can I build my own effect?
Yes. Implement `RevealEffect` and render from `RevealEffectContext`.
