// Smoke tests for the partner app's onboarding → login flow.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:glamira_partner/main.dart';

void main() {
  testWidgets('Onboarding opens on the first slide',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PartnerApp());

    expect(find.text('Grow Your Beauty Business'), findsOneWidget);
    expect(find.text('NEXT'), findsOneWidget);
  });

  testWidgets('NEXT walks through all three slides to GET STARTED',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PartnerApp());

    await tester.tap(find.text('NEXT'));
    await tester.pumpAndSettle();
    expect(find.text('Seamless Management'), findsOneWidget);

    await tester.tap(find.text('NEXT'));
    await tester.pumpAndSettle();
    expect(find.text('Real-time Insights'), findsOneWidget);
    expect(find.text('GET STARTED'), findsOneWidget);
  });

  testWidgets('GET STARTED opens the login screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PartnerApp());

    for (var i = 0; i < 2; i++) {
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('GET STARTED'));
    await tester.pumpAndSettle();

    expect(find.text('Please sign in to your account'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('Logging in opens the Add Service page',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PartnerApp());

    for (var i = 0; i < 2; i++) {
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('GET STARTED'));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.byType(TextFormField).first, 'partner@glamira.com');
    await tester.enterText(find.byType(TextFormField).last, 'supersecret');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Add Service'), findsOneWidget);
    expect(find.text('Service Details'), findsOneWidget);
    expect(find.text('Save Service'), findsOneWidget);
  });

  testWidgets('Sign Up link opens the partner sign-up screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PartnerApp());

    for (var i = 0; i < 2; i++) {
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('GET STARTED'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    expect(find.text('Grow Your Business'), findsOneWidget);
    expect(find.text('CREATE PARTNER ACCOUNT'), findsOneWidget);
  });
}
