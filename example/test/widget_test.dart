import 'package:flutter_test/flutter_test.dart';
import 'package:ui_reveal_example/main.dart';

void main() {
  testWidgets('renders demo app', (tester) async {
    await tester.pumpWidget(const RevealDemoApp());
    expect(find.text('ui_reveal examples'), findsOneWidget);
  });
}
