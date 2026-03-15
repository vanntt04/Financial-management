import 'package:flutter_test/flutter_test.dart';

import 'package:financial_management/main.dart';

void main() {
  testWidgets('App renders login screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(isLoggedIn: false));
    await tester.pump();
    expect(find.text('Finance Manager'), findsWidgets);
  });
}
