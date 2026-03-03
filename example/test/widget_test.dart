import 'package:flutter_test/flutter_test.dart';

import 'package:example/main.dart';

void main() {
  testWidgets('OTP verification page renders', (WidgetTester tester) async {
    await tester.pumpWidget(const OtpExampleApp());
    expect(find.text('OTP Verification'), findsOneWidget);
  });
}
