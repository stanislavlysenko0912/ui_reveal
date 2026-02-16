import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_reveal/ui_reveal.dart';
import 'package:ui_reveal_example/main.dart';

void main() {
  testWidgets('renders demo app', (tester) async {
    await tester.pumpWidget(const RevealDemoApp());
    await tester.pump();
    expect(find.byType(RevealHost), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
