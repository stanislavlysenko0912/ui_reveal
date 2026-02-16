import 'package:flutter/material.dart';
import 'package:ui_reveal/ui_reveal.dart';

/// Effect type for choice chips.
enum DemoEffectType {
  circular('Circular', CircularRevealEffect()),
  fade('Fade', FadeRevealEffect()),
  scale('Scale', ScaleRevealEffect());

  const DemoEffectType(this.label, this.effect);

  final String label;
  final RevealEffect effect;
}

extension RevealDirectionModeLabel on RevealDirectionMode {
  String get label {
    switch (this) {
      case RevealDirectionMode.explicit:
        return 'Explicit';
      case RevealDirectionMode.toggle:
        return 'Toggle';
      case RevealDirectionMode.byThemeBrightness:
        return 'By Theme';
    }
  }
}

const List<Color> paletteSeeds = <Color>[
  Colors.blue,
  Colors.teal,
  Colors.deepOrange,
  Colors.indigo,
];

/// Mock contact for the list preview.
class MockContact {
  const MockContact(this.name, this.role, this.initials);

  final String name;
  final String role;
  final String initials;
}

const mockContacts = <MockContact>[
  MockContact('Alex Morgan', 'Product Designer', 'AM'),
  MockContact('Sam Chen', 'Flutter Engineer', 'SC'),
  MockContact('Jordan Lee', 'UX Researcher', 'JL'),
  MockContact('Taylor Kim', 'DevOps Lead', 'TK'),
  MockContact('Riley Park', 'QA Engineer', 'RP'),
];

/// Mock stat tile for the grid preview.
class MockGridItem {
  const MockGridItem(this.icon, this.value, this.label);

  final IconData icon;
  final String value;
  final String label;
}

const mockGridItems = <MockGridItem>[
  MockGridItem(Icons.people_rounded, '1.2k', 'Users'),
  MockGridItem(Icons.trending_up_rounded, '94%', 'Growth'),
  MockGridItem(Icons.star_rounded, '4.9', 'Rating'),
  MockGridItem(Icons.bolt_rounded, '12ms', 'Latency'),
  MockGridItem(Icons.code_rounded, '3.2k', 'Commits'),
  MockGridItem(Icons.favorite_rounded, '856', 'Likes'),
];
