// test/widget_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:hae_decision_framework/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DecisionFrameworkApp());

    // Verify that the title is present.
    expect(find.text('HAE Sokratik Karar Laboratuvarı'), findsOneWidget);
  });
}