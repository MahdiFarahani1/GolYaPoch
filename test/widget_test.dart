import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:golyapooch/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('Royal Noir home shows all three independent game modes', (tester) async {
    await tester.pumpWidget(const GolYaPochApp());
    await tester.pumpAndSettle();
    expect(find.text('گُل یا پوچ'), findsOneWidget);
    for (final name in ['استودیوی فیلیمو','تالار شاه‌گل','نبرد گل']) {
      await tester.scrollUntilVisible(find.text(name), 160,
        scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();
      expect(find.text(name), findsOneWidget);
    }
  });
}
