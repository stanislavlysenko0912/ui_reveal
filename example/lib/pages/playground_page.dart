import 'package:flutter/material.dart';
import 'package:ui_reveal/ui_reveal.dart';

enum _EffectType {
  circular('Circular'),
  fade('Fade'),
  slide('Slide');

  const _EffectType(this.label);

  final String label;

  RevealEffect get effect {
    switch (this) {
      case _EffectType.circular:
        return RevealEffects.circular();
      case _EffectType.fade:
        return RevealEffects.fade();
      case _EffectType.slide:
        return RevealEffects.slide();
    }
  }
}

/// Interactive playground with tweakable controls.
class PlaygroundPage extends StatefulWidget {
  const PlaygroundPage({super.key});

  @override
  State<PlaygroundPage> createState() => _PlaygroundPageState();
}

class _PlaygroundPageState extends State<PlaygroundPage> {
  _EffectType _effectType = _EffectType.circular;
  RevealDirection _direction = RevealDirection.reveal;
  double _durationMs = 560;
  Curve _curve = Curves.easeInOut;
  bool _isStateA = true;

  static const _curves = <String, Curve>{
    'easeInOut': Curves.easeInOut,
    'easeIn': Curves.easeIn,
    'easeOut': Curves.easeOut,
    'linear': Curves.linear,
    'elasticOut': Curves.elasticOut,
    'bounceOut': Curves.bounceOut,
  };

  String get _curveLabel =>
      _curves.entries.firstWhere((e) => e.value == _curve).key;

  @override
  Widget build(BuildContext context) {
    return RevealScope(
      config: RevealConfig(
        duration: Duration(milliseconds: _durationMs.round()),
        curve: _curve,
      ),
      child: Builder(builder: (scopeContext) => _buildContent(scopeContext)),
    );
  }

  Widget _buildContent(BuildContext scopeContext) {
    final theme = Theme.of(scopeContext);
    final colorScheme = theme.colorScheme;
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHeader(theme),
                const SizedBox(height: 16),
                _buildControls(theme, colorScheme),
                const SizedBox(height: 16),
                _buildPreview(scopeContext, colorScheme, theme),
              ],
            ),
          ),
          _buildRunButton(scopeContext, colorScheme),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Center(
        child: Text('Playground', style: theme.textTheme.headlineMedium),
      ),
    );
  }

  Widget _buildControls(ThemeData theme, ColorScheme colorScheme) {
    return Card.filled(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Effect', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<_EffectType>(
                segments: _EffectType.values
                    .map((e) => ButtonSegment(value: e, label: Text(e.label)))
                    .toList(),
                selected: {_effectType},
                onSelectionChanged: (s) =>
                    setState(() => _effectType = s.first),
              ),
            ),
            const SizedBox(height: 16),
            Text('Direction', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<RevealDirection>(
                segments: const [
                  ButtonSegment(
                    value: RevealDirection.reveal,
                    label: Text('Reveal'),
                  ),
                  ButtonSegment(
                    value: RevealDirection.conceal,
                    label: Text('Conceal'),
                  ),
                ],
                selected: {_direction},
                onSelectionChanged: (s) => setState(() => _direction = s.first),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('Duration', style: theme.textTheme.labelLarge),
                const Spacer(),
                Text(
                  '${_durationMs.round()} ms',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            Slider(
              value: _durationMs,
              min: 200,
              max: 1500,
              divisions: 26,
              onChanged: (v) => setState(() => _durationMs = v),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Curve', style: theme.textTheme.labelLarge),
                const Spacer(),
                DropdownButton<Curve>(
                  value: _curve,
                  underline: const SizedBox.shrink(),
                  isDense: true,
                  items: _curves.entries
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.value,
                          child: Text(e.key, style: theme.textTheme.bodySmall),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _curve = v);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(
    BuildContext scopeContext,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      decoration: BoxDecoration(
        color: _isStateA
            ? colorScheme.primaryContainer
            : colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            _isStateA ? Icons.play_circle_outline : Icons.check_circle_outline,
            size: 56,
            color: _isStateA
                ? colorScheme.onPrimaryContainer
                : colorScheme.onTertiaryContainer,
          ),
          const SizedBox(height: 12),
          Text(
            _isStateA ? 'State A' : 'State B',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: _isStateA
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onTertiaryContainer,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_effectType.label}  ·  ${_direction.name}  ·  ${_durationMs.round()} ms  ·  $_curveLabel',
            style: theme.textTheme.bodySmall?.copyWith(
              color:
                  (_isStateA
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onTertiaryContainer)
                      .withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRunButton(BuildContext scopeContext, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: Builder(
          builder: (btnContext) {
            return FilledButton.icon(
              onPressed: () => _runTransition(btnContext),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Run Transition'),
            );
          },
        ),
      ),
    );
  }

  Future<void> _runTransition(BuildContext triggerContext) {
    return RevealScope.of(triggerContext).start(
      center: triggerContext.revealCenter,
      direction: _direction,
      effect: _effectType.effect,
      onSwitch: () async => setState(() => _isStateA = !_isStateA),
    );
  }
}
