import 'package:flutter/material.dart';
import 'package:ui_reveal/ui_reveal.dart';

import 'pages/custom_page.dart';
import 'pages/playground_page.dart';
import 'pages/real_world_page.dart';
import 'pages/simple_page.dart';

void main() {
  runApp(const RevealDemoApp());
}

class RevealDemoApp extends StatefulWidget {
  const RevealDemoApp({super.key});

  @override
  State<RevealDemoApp> createState() => _RevealDemoAppState();
}

class _RevealDemoAppState extends State<RevealDemoApp> {
  bool _isDarkTheme = false;
  int _paletteIndex = 0;
  int _pageIndex = 0;

  static const _paletteSeeds = <Color>[
    Colors.blue,
    Colors.teal,
    Colors.deepOrange,
    Colors.indigo,
  ];

  Color get _currentSeed => _paletteSeeds[_paletteIndex];

  void _toggleTheme() => setState(() => _isDarkTheme = !_isDarkTheme);

  void _setPalette(int index) => setState(() => _paletteIndex = index);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeAnimationDuration: Duration.zero,
      themeMode: _isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: _currentSeed,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: _currentSeed,
        brightness: Brightness.dark,
      ),
      builder: (context, child) {
        return RevealScope(child: child ?? const SizedBox.shrink());
      },
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    return Scaffold(
      body: IndexedStack(
        index: _pageIndex,
        children: [
          SimplePage(
            isDark: _isDarkTheme,
            onToggleTheme: _toggleTheme,
            paletteSeeds: _paletteSeeds,
            paletteIndex: _paletteIndex,
            onPaletteChanged: _setPalette,
          ),
          CustomPage(isDark: _isDarkTheme, onToggleTheme: _toggleTheme),
          const PlaygroundPage(),
          RealWorldPage(isDark: _isDarkTheme, onToggleTheme: _toggleTheme),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _pageIndex,
        onDestinationSelected: (i) => setState(() => _pageIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.touch_app_outlined),
            selectedIcon: Icon(Icons.touch_app),
            label: 'Simple',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_fix_high_outlined),
            selectedIcon: Icon(Icons.auto_fix_high),
            label: 'Custom',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune),
            label: 'Playground',
          ),
          NavigationDestination(
            icon: Icon(Icons.apps_outlined),
            selectedIcon: Icon(Icons.apps),
            label: 'Example',
          ),
        ],
      ),
    );
  }
}
