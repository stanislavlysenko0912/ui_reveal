import 'package:flutter/material.dart';
import 'package:ui_reveal/ui_reveal.dart';

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
  RevealDirection _direction = RevealDirection.reveal;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
      home: Builder(builder: (_) => _buildHome()),
    );
  }

  Widget _buildHome() {
    return Scaffold(
      appBar: AppBar(title: const Text('ui_reveal examples')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSelectors(),
            const SizedBox(height: 16),
            _buildActionCard(
              title: 'Theme switch',
              subtitle: 'Toggle between light and dark themes.',
              onSwitch: () => setState(() => _isDarkTheme = !_isDarkTheme),
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              title: 'Layout switch',
              subtitle: 'Switch list/grid presentation.',
              onSwitch: () => setState(() => _isGridLayout = !_isGridLayout),
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              title: 'Palette switch',
              subtitle: 'Cycle app color seed.',
              onSwitch: () => setState(_cyclePalette),
            ),
            const SizedBox(height: 16),
            _PreviewPanel(isGridLayout: _isGridLayout),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectors() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reveal settings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<DemoEffectType>(
                    initialValue: _effectType,
                    decoration: const InputDecoration(labelText: 'Effect'),
                    items: DemoEffectType.values
                        .map(
                          (effectType) => DropdownMenuItem<DemoEffectType>(
                            value: effectType,
                            child: Text(effectType.label),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() => _effectType = value);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<RevealDirection>(
                    initialValue: _direction,
                    decoration: const InputDecoration(labelText: 'Direction'),
                    items: RevealDirection.values
                        .map(
                          (direction) => DropdownMenuItem<RevealDirection>(
                            value: direction,
                            child: Text(direction.name),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setState(() => _direction = value);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required VoidCallback onSwitch,
  }) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Builder(
          builder: (buttonContext) {
            return FilledButton(
              onPressed: () {
                _runReveal(triggerContext: buttonContext, onSwitch: onSwitch);
              },
              child: const Text('Run'),
            );
          },
        ),
      ),
    );
  }

  Future<void> _runReveal({
    required BuildContext triggerContext,
    required VoidCallback onSwitch,
  }) {
    return _revealController.start(
      center: triggerContext.revealCenter,
      direction: _direction,
      effect: _effectType.effect,
      onSwitch: () async => onSwitch(),
    );
  }

  void _cyclePalette() {
    _paletteIndex = (_paletteIndex + 1) % _paletteSeeds.length;
  }

  Color get _currentPaletteSeed => _paletteSeeds[_paletteIndex];
}

class _PreviewPanel extends StatelessWidget {
  const _PreviewPanel({required this.isGridLayout});

  final bool isGridLayout;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      child: isGridLayout ? const _GridPreview() : const _ListPreview(),
    );
  }
}

class _ListPreview extends StatelessWidget {
  const _ListPreview();

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey<String>('list-preview'),
      children: List.generate(
        4,
        (index) => Card(
          child: ListTile(
            leading: CircleAvatar(child: Text('${index + 1}')),
            title: Text('List item ${index + 1}'),
            subtitle: const Text('Preview content'),
          ),
        ),
      ),
    );
  }
}

class _GridPreview extends StatelessWidget {
  const _GridPreview();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      key: const ValueKey<String>('grid-preview'),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        return DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: Text('Tile ${index + 1}')),
        );
      },
    );
  }
}

enum DemoEffectType {
  circular('Circular', CircularRevealEffect()),
  fade('Fade', FadeRevealEffect()),
  scale('Scale', ScaleRevealEffect());

  const DemoEffectType(this.label, this.effect);

  final String label;
  final RevealEffect effect;
}

const List<Color> _paletteSeeds = <Color>[
  Colors.blue,
  Colors.teal,
  Colors.deepOrange,
  Colors.indigo,
];
