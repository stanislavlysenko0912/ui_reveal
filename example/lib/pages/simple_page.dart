import 'package:flutter/material.dart';
import 'package:ui_reveal/ui_reveal.dart';

/// Zero-controller page — only uses `context.startReveal()` extension.
class SimplePage extends StatefulWidget {
  const SimplePage({
    required this.isDark,
    required this.onToggleTheme,
    required this.paletteSeeds,
    required this.paletteIndex,
    required this.onPaletteChanged,
    super.key,
  });

  final bool isDark;
  final VoidCallback onToggleTheme;
  final List<Color> paletteSeeds;
  final int paletteIndex;
  final ValueChanged<int> onPaletteChanged;

  @override
  State<SimplePage> createState() => _SimplePageState();
}

class _SimplePageState extends State<SimplePage> {
  bool _isViewA = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(context),
          const SizedBox(height: 16),
          _buildThemeCard(context),
          const SizedBox(height: 12),
          _buildColorSwapCard(context),
          const SizedBox(height: 12),
          _buildContentSwitchCard(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Center(
        child: Text('Simple', style: theme.textTheme.headlineMedium),
      ),
    );
  }

  Widget _buildThemeCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card.filled(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.startReveal(
          onSwitch: () async => widget.onToggleTheme(),
          center: context.revealCenter,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(
                widget.isDark
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                size: 32,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Theme Toggle',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      widget.isDark ? 'Dark mode' : 'Light mode',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'CircularRevealEffect',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorSwapCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card.filled(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Color Swap', style: theme.textTheme.titleMedium),
                      Text(
                        'Tap a color to switch palette',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'FadeRevealEffect',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.paletteSeeds.length, (index) {
                final isSelected = index == widget.paletteIndex;
                final color = widget.paletteSeeds[index];
                return Padding(
                  padding: EdgeInsets.only(left: index == 0 ? 0 : 16),
                  child: Builder(
                    builder: (dotContext) {
                      return GestureDetector(
                        onTap: isSelected
                            ? null
                            : () => dotContext.startReveal(
                                effect: RevealEffects.fade(),
                                onSwitch: () async =>
                                    widget.onPaletteChanged(index),
                              ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(
                                    color: colorScheme.onSurface,
                                    width: 2,
                                  )
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSwitchCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card.filled(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.startReveal(
          effect: RevealEffects.slide(),
          onSwitch: () async => setState(() => _isViewA = !_isViewA),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Content Switch',
                          style: theme.textTheme.titleMedium,
                        ),
                        Text(
                          'Tap to toggle view',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'SlideRevealEffect',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32),
                decoration: BoxDecoration(
                  color: _isViewA
                      ? colorScheme.primaryContainer
                      : colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      _isViewA
                          ? Icons.wb_sunny_rounded
                          : Icons.nightlight_round_outlined,
                      size: 40,
                      color: _isViewA
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onTertiaryContainer,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isViewA ? 'View A' : 'View B',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: _isViewA
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onTertiaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
