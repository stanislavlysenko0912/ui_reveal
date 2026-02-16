import 'package:flutter/material.dart';
import 'package:ui_reveal/ui_reveal.dart';

import '../demo_data.dart';

/// Row of filter chips for effect + segmented button for direction.
class EffectSettings extends StatelessWidget {
  const EffectSettings({
    required this.effectType,
    required this.directionMode,
    required this.direction,
    required this.onEffectChanged,
    required this.onDirectionModeChanged,
    required this.onDirectionChanged,
    super.key,
  });

  final DemoEffectType effectType;
  final RevealDirectionMode directionMode;
  final RevealDirection direction;
  final ValueChanged<DemoEffectType> onEffectChanged;
  final ValueChanged<RevealDirectionMode> onDirectionModeChanged;
  final ValueChanged<RevealDirection> onDirectionChanged;

  @override
  Widget build(BuildContext context) {
    return Card.filled(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              children: DemoEffectType.values
                  .map(
                    (type) => ChoiceChip(
                      label: Text(type.label),
                      selected: effectType == type,
                      onSelected: (_) => onEffectChanged(type),
                    ),
                  )
                  .toList(growable: false),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: RevealDirectionMode.values
                  .map(
                    (mode) => ChoiceChip(
                      label: Text(mode.label),
                      selected: directionMode == mode,
                      onSelected: (_) => onDirectionModeChanged(mode),
                    ),
                  )
                  .toList(growable: false),
            ),
            const SizedBox(height: 12),
            Opacity(
              opacity: directionMode == RevealDirectionMode.explicit ? 1 : 0.55,
              child: IgnorePointer(
                ignoring: directionMode != RevealDirectionMode.explicit,
                child: SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<RevealDirection>(
                    segments: const [
                      ButtonSegment<RevealDirection>(
                        value: RevealDirection.reveal,
                        label: Text('Reveal'),
                      ),
                      ButtonSegment<RevealDirection>(
                        value: RevealDirection.conceal,
                        label: Text('Conceal'),
                      ),
                    ],
                    selected: {direction},
                    onSelectionChanged: (s) => onDirectionChanged(s.first),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
