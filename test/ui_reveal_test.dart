import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_reveal/ui_reveal.dart';

void main() {
  group('RevealController', () {
    test('throws StateError when host is not attached', () async {
      final controller = RevealController();

      await expectLater(
        controller.start(
          center: const Offset(20, 20),
          onSwitch: () async {},
          effect: RevealEffects.fade(),
        ),
        throwsStateError,
      );
    });

    testWidgets('throws ArgumentError for non-finite center', (tester) async {
      final controller = RevealController();
      await _pumpHost(tester, controller: controller);

      await expectLater(
        controller.start(
          center: const Offset(double.nan, 12),
          onSwitch: () async {},
          effect: RevealEffects.fade(),
        ),
        throwsArgumentError,
      );
    });

    testWidgets('throws StateError on reentry', (tester) async {
      final controller = RevealController();
      await _pumpHost(tester, controller: controller);
      final gate = Completer<void>();

      final first = controller.start(
        center: const Offset(24, 24),
        onSwitch: () => gate.future,
        effect: RevealEffects.fade(),
      );
      await tester.pump();
      await tester.pump();

      await expectLater(
        controller.start(
          center: const Offset(24, 24),
          onSwitch: () async {},
          effect: RevealEffects.fade(),
        ),
        throwsStateError,
      );

      gate.complete();
      await first;
      await tester.pump();
    });

    testWidgets('calls onSwitch when snapshot is unavailable', (tester) async {
      final controller = RevealController();
      await _pumpHost(tester, controller: controller);
      var switchCalls = 0;

      final transition = controller.start(
        center: const Offset(16, 16),
        onSwitch: () async {
          switchCalls += 1;
        },
        effect: RevealEffects.fade(),
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await transition;
      expect(switchCalls, 1);
    });

    testWidgets('runs all built-in effects through one API', (tester) async {
      final controller = RevealController();
      final key = GlobalKey();
      await _pumpHost(
        tester,
        controller: controller,
        child: SizedBox(key: key, width: 40, height: 40),
      );

      final center = key.currentContext!.revealCenter;
      final effects = <RevealEffect>[
        RevealEffects.circular(),
        RevealEffects.diagonalWipe(),
        RevealEffects.fade(),
        RevealEffects.slide(),
      ];

      for (final effect in effects) {
        var switchCalls = 0;
        final transition = controller.start(
          center: center,
          onSwitch: () async {
            switchCalls += 1;
          },
          effect: effect,
          direction: RevealDirection.conceal,
        );
        await tester.pump();
        await tester.pump();
        await transition;
        expect(switchCalls, 1);
        await tester.pump();
      }
    });
  });

  group('BuildContextRevealExtension', () {
    testWidgets('returns global center for RenderBox', (tester) async {
      final key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(child: SizedBox(key: key, width: 80, height: 40)),
          ),
        ),
      );

      final context = key.currentContext!;
      final renderBox = context.findRenderObject()! as RenderBox;
      final topLeft = renderBox.localToGlobal(Offset.zero);
      final center = context.revealCenter;

      expect(center.dx, topLeft.dx + 40);
      expect(center.dy, topLeft.dy + 20);
    });

    testWidgets('startReveal throws without RevealScope', (tester) async {
      final key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: SizedBox(key: key, width: 40)),
        ),
      );

      expect(
        () => key.currentContext!.startReveal(onSwitch: () async {}),
        throwsStateError,
      );
    });

    testWidgets('startReveal works with RevealScope', (tester) async {
      final key = GlobalKey();
      var switchCalls = 0;

      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) {
            return RevealScope(
              config: const RevealConfig(duration: Duration.zero),
              child: child ?? const SizedBox.shrink(),
            );
          },
          home: Scaffold(
            body: Center(child: SizedBox(key: key, width: 50)),
          ),
        ),
      );

      final transition = key.currentContext!.startReveal(
        effect: RevealEffects.fade(),
        onSwitch: () async {
          switchCalls += 1;
        },
      );

      await tester.pump();
      await tester.pump();
      await transition;
      expect(switchCalls, 1);
    });
  });
}

Future<void> _pumpHost(
  WidgetTester tester, {
  required RevealController controller,
  Widget child = const SizedBox(width: 100, height: 100),
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: RevealHost(
        controller: controller,
        config: const RevealConfig(duration: Duration.zero),
        child: Scaffold(body: Center(child: child)),
      ),
    ),
  );
}
