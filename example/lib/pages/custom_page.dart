import 'package:flutter/material.dart';
import 'package:ui_reveal/ui_reveal.dart';

/// Demonstrates a custom effect that toggles app theme.
class CustomPage extends StatelessWidget {
  const CustomPage({
    required this.isDark,
    required this.onToggleTheme,
    super.key,
  });

  final bool isDark;
  final VoidCallback onToggleTheme;

  static const RevealEffect _effect = _BlindsRevealEffect(bands: 10);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Center(
              child: Text('Custom', style: theme.textTheme.headlineMedium),
            ),
          ),
          const SizedBox(height: 16),
          Card.filled(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Blinds Effect', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(
                    'Custom effect + theme toggle. Tap button to run transition.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Builder(
                    builder: (buttonContext) {
                      return FilledButton.icon(
                        onPressed: () => _run(buttonContext),
                        icon: const Icon(Icons.animation_rounded),
                        label: const Text('Toggle Theme With Custom Effect'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _ThemePreview(isDark: isDark),
        ],
      ),
    );
  }

  Future<void> _run(BuildContext triggerContext) {
    final direction = RevealDirectionResolver.byThemeBrightness(
      fromBrightness: isDark ? Brightness.dark : Brightness.light,
      toBrightness: isDark ? Brightness.light : Brightness.dark,
    );

    return RevealScope.of(triggerContext).start(
      center: triggerContext.revealCenter,
      effect: _effect,
      direction: direction,
      onSwitch: () async => onToggleTheme(),
    );
  }
}

class _ThemePreview extends StatelessWidget {
  const _ThemePreview({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? colors.tertiaryContainer : colors.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            size: 56,
            color: isDark
                ? colors.onTertiaryContainer
                : colors.onPrimaryContainer,
          ),
          const SizedBox(height: 10),
          Text(
            isDark ? 'Dark Theme Active' : 'Light Theme Active',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: isDark
                  ? colors.onTertiaryContainer
                  : colors.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _BlindsRevealEffect extends RevealEffect {
  const _BlindsRevealEffect({this.bands = 10});

  final int bands;

  @override
  Widget buildOverlay(RevealEffectContext context) {
    return CustomPaint(
      size: context.size,
      painter: _BlindsRevealPainter(context: context, bands: bands),
    );
  }
}

class _BlindsRevealPainter extends CustomPainter {
  const _BlindsRevealPainter({required this.context, required this.bands});

  final RevealEffectContext context;
  final int bands;

  @override
  void paint(Canvas canvas, Size size) {
    final progress = context.progress.clamp(0.0, 1.0).toDouble();
    final width = size.width;
    final height = size.height;
    final bandHeight = height / bands;

    for (var i = 0; i < bands; i += 1) {
      final top = i * bandHeight;
      final visible = width * (1 - progress);
      if (visible <= 0) {
        continue;
      }

      final isOdd = i.isOdd;
      final anchorFromRight = _anchorFromRight(isOdd);
      final left = anchorFromRight ? width - visible : 0.0;

      canvas.save();
      canvas.clipRect(Rect.fromLTWH(left, top, visible, bandHeight + 1));
      paintImage(
        canvas: canvas,
        rect: Offset.zero & size,
        image: context.snapshotImage,
        fit: BoxFit.cover,
      );
      canvas.restore();
    }
  }

  bool _anchorFromRight(bool isOddBand) {
    if (context.direction == RevealDirection.reveal) {
      return isOddBand;
    }
    return !isOddBand;
  }

  @override
  bool shouldRepaint(covariant _BlindsRevealPainter oldDelegate) {
    return oldDelegate.context.progress != context.progress ||
        oldDelegate.context.snapshotImage != context.snapshotImage ||
        oldDelegate.context.direction != context.direction ||
        oldDelegate.bands != bands;
  }
}
