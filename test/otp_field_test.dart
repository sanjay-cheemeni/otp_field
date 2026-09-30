import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:otp_field/otp_field.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));

void main() {
  testWidgets('renders the requested number of boxes', (tester) async {
    await tester.pumpWidget(_wrap(const OtpField(length: 4)));
    expect(find.byType(AnimatedContainer), findsNWidgets(4));
  });

  testWidgets('shows typed digits', (tester) async {
    await tester.pumpWidget(_wrap(const OtpField(length: 4)));
    await tester.enterText(find.byType(TextField), '12');
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('calls onChanged on every change', (tester) async {
    final values = <String>[];
    await tester.pumpWidget(_wrap(OtpField(length: 4, onChanged: values.add)));
    await tester.enterText(find.byType(TextField), '1');
    await tester.enterText(find.byType(TextField), '12');
    expect(values, ['1', '12']);
  });

  testWidgets('calls onCompleted once when all digits are entered',
      (tester) async {
    final completed = <String>[];
    await tester.pumpWidget(
      _wrap(OtpField(length: 4, onCompleted: completed.add)),
    );
    await tester.enterText(find.byType(TextField), '123');
    expect(completed, isEmpty);
    await tester.enterText(find.byType(TextField), '1234');
    expect(completed, ['1234']);
  });

  testWidgets('ignores non-digit characters by default', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _wrap(OtpField(length: 4, controller: controller)),
    );
    await tester.enterText(find.byType(TextField), 'a1b2');
    expect(controller.text, '12');
  });

  testWidgets('limits input to the given length', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      _wrap(OtpField(length: 4, controller: controller)),
    );
    await tester.enterText(find.byType(TextField), '123456');
    expect(controller.text, '1234');
  });

  testWidgets('obscures digits when obscureText is true', (tester) async {
    await tester.pumpWidget(
      _wrap(const OtpField(length: 4, obscureText: true)),
    );
    await tester.enterText(find.byType(TextField), '12');
    await tester.pump();
    expect(find.text('•'), findsNWidgets(2));
    expect(find.text('1'), findsNothing);
  });
}
