import 'package:flutter/material.dart';
import 'package:ui_reveal/ui_reveal.dart';

import 'demo_data.dart';
import 'widgets/demo_action_card.dart';
import 'widgets/effect_settings.dart';
import 'widgets/preview_panel.dart';

void main() {
  runApp(const RevealDemoApp());
}

class RevealDemoApp extends StatefulWidget {
  const RevealDemoApp({super.key});

  @override
  State<RevealDemoApp> createState() => _RevealDemoAppState();
}

class _RevealDemoAppState extends State<RevealDemoApp> {
  final RevealController _revealController = RevealController();
  bool _isDarkTheme = false;
  bool _isGridLayout = false;
  int _paletteIndex = 0;
  DemoEffectType _effectType = DemoEffectType.circular;
  RevealDirectionMode _directionMode = RevealDirectionMode.explicit;
  RevealDirection _explicitDirection = RevealDirection.reveal;
  RevealDirection _lastResolvedDirection = RevealDirection.conceal;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeAnimationDuration: Duration.zero,
      themeMode: _isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: _currentPaletteSeed,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: _currentPaletteSeed,
        brightness: Brightness.dark,
      ),
      builder: (context, child) {
        return RevealHost(
          controller: _revealController,
          config: const RevealConfig(duration: Duration(milliseconds: 500)),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: Builder(builder: (homeContext) => _buildHome(homeContext)),
    );
  }

  Widget _buildHome(BuildContext homeContext) {
    final theme = Theme.of(homeContext);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            EffectSettings(
              effectType: _effectType,
              directionMode: _directionMode,
              direction: _explicitDirection,
              onEffectChanged: (v) => setState(() => _effectType = v),
              onDirectionModeChanged: (v) => setState(() => _directionMode = v),
              onDirectionChanged: (v) => setState(() => _explicitDirection = v),
            ),
            const SizedBox(height: 20),
            _buildSectionHeader(theme, 'Transitions'),
            const SizedBox(height: 8),
            _buildThemeToggleCard(colorScheme),
            const SizedBox(height: 12),
            _buildLayoutToggleCard(colorScheme),
            const SizedBox(height: 12),
            _buildPaletteCard(theme, colorScheme),
            const SizedBox(height: 24),
            _buildSectionHeader(theme, 'Preview'),
            const SizedBox(height: 8),
            PreviewPanel(isGridLayout: _isGridLayout),
          ],
        ),
      ),
      floatingActionButton: Builder(
        builder: (fabContext) {
          return FloatingActionButton(
            onPressed: () => _runReveal(
              triggerContext: fabContext,
              onSwitch: () => setState(() => _isDarkTheme = !_isDarkTheme),
            ),
            tooltip: 'Toggle theme',
            child: Icon(
              _isDarkTheme ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildThemeToggleCard(ColorScheme colorScheme) {
    return DemoActionCard(
      title: 'Theme',
      subtitle: _isDarkTheme ? 'Dark mode active' : 'Light mode active',
      badge: _isDarkTheme ? 'Dark' : 'Light',
      badgeColor: colorScheme.tertiaryContainer,
      badgeTextColor: colorScheme.onTertiaryContainer,
      onRun: (ctx) => _runReveal(
        triggerContext: ctx,
        nextBrightness: _isDarkTheme ? Brightness.light : Brightness.dark,
        onSwitch: () => setState(() => _isDarkTheme = !_isDarkTheme),
      ),
    );
  }

  Widget _buildLayoutToggleCard(ColorScheme colorScheme) {
    return DemoActionCard(
      title: 'Layout',
      subtitle: _isGridLayout ? 'Grid presentation' : 'List presentation',
      badge: _isGridLayout ? 'Grid' : 'List',
      badgeColor: colorScheme.secondaryContainer,
      badgeTextColor: colorScheme.onSecondaryContainer,
      onRun: (ctx) => _runReveal(
        triggerContext: ctx,
        onSwitch: () => setState(() => _isGridLayout = !_isGridLayout),
      ),
    );
  }

  Widget _buildPaletteCard(ThemeData theme, ColorScheme colorScheme) {
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Color Palette',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    'Tap a color to switch',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(paletteSeeds.length, (index) {
                final isSelected = index == _paletteIndex;
                final color = paletteSeeds[index];
                return Padding(
                  padding: EdgeInsets.only(left: index == 0 ? 0 : 8),
                  child: Builder(
                    builder: (dotContext) {
                      return GestureDetector(
                        onTap: isSelected
                            ? null
                            : () => _runReveal(
                                triggerContext: dotContext,
                                onSwitch: () =>
                                    setState(() => _paletteIndex = index),
                              ),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(
                                    color: colorScheme.onSurface,
                                    width: 3,
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

  Future<void> _runReveal({
    required BuildContext triggerContext,
    required VoidCallback onSwitch,
    Brightness? nextBrightness,
  }) {
    final direction = _resolveDirection(nextBrightness: nextBrightness);
    _lastResolvedDirection = direction;
    return _revealController.start(
      center: triggerContext.revealCenter,
      direction: direction,
      effect: _effectType.effect,
      onSwitch: () async => onSwitch(),
    );
  }

  RevealDirection _resolveDirection({Brightness? nextBrightness}) {
    switch (_directionMode) {
      case RevealDirectionMode.explicit:
        return _explicitDirection;
      case RevealDirectionMode.toggle:
        return RevealDirectionResolver.toggle(
          previousDirection: _lastResolvedDirection,
        );
      case RevealDirectionMode.byThemeBrightness:
        if (nextBrightness == null) {
          return _explicitDirection;
        }
        return RevealDirectionResolver.byThemeBrightness(
          fromBrightness: _isDarkTheme ? Brightness.dark : Brightness.light,
          toBrightness: nextBrightness,
          fallbackDirection: _explicitDirection,
        );
    }
  }

  Color get _currentPaletteSeed => paletteSeeds[_paletteIndex];
}
