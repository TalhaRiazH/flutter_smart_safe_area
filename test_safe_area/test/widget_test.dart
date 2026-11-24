import 'package:flutter_test/flutter_test.dart';
import 'package:test_safe_area/main.dart';

void main() {
  testWidgets('test app loads colorful list and bottom nav', (tester) async {
    await tester.pumpWidget(const TestSafeAreaApp());
    expect(find.text('Coral'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
  });
}
