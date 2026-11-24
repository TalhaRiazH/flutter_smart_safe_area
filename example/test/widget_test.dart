import 'package:flutter_test/flutter_test.dart';
import 'package:smart_safe_area_example/main.dart';

void main() {
  testWidgets('example app loads', (tester) async {
    await tester.pumpWidget(const SmartSafeAreaExampleApp());
    expect(find.text('smart_safe_area'), findsOneWidget);
  });
}
