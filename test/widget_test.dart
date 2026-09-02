// Basic smoke test for the partner app's entry screen.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:glamira_partner/main.dart';

void main() {
  testWidgets('Login screen renders its form and actions',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PartnerApp());

    expect(find.text('Please sign in to your account'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('OR CONTINUE WITH'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
  });

  testWidgets('Sign Up link opens the partner sign-up screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PartnerApp());

    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    expect(find.text('Grow Your Business'), findsOneWidget);
    expect(find.text('CREATE PARTNER ACCOUNT'), findsOneWidget);
  });
}
