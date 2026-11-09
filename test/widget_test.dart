import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:golyapooch/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('Royal Noir home shows all three independent game modes', (tester) async {
    await tester.pumpWidget(const GolYaPochApp());
    await tester.pumpAndSettle();
    expect(find.text('گُل یا پوچ'), findsOneWidget);
    expect(find.text('استودیوی فیلیمو'), findsOneWidget);
    expect(find.text('تالار شاه‌گل'), findsOneWidget);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -450));
    await tester.pumpAndSettle();
    expect(find.text('نبرد گل'), findsOneWidget);
  });
}
