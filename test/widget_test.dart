// Flow tests for onboarding → login → Add Service.
//
// The auth repository is faked so these never touch the network; the real one
// is exercised against the API by the backend's own end-to-end checks.

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:glamira_partner/data/partner_auth_repository.dart';
import 'package:glamira_partner/main.dart';
import 'package:glamira_partner/models/partner.dart';
import 'package:glamira_partner/providers/auth_providers.dart';

const _partner = Partner(
  id: 'p1',
  fullName: 'Kiran Giri',
  businessName: 'Nirjara Beauty Parlor',
  email: 'partner@glamira.com',
  phoneNumber: '+9779812345678',
  address: 'Lazimpat, Kathmandu',
  isActive: true,
);

/// Succeeds without a network call; [failWith] makes it fail instead.
class _FakeAuthRepository extends PartnerAuthRepository {
  _FakeAuthRepository(super.dio, super.prefs, {this.failWith});

  final String? failWith;
  bool loggedIn = false;

  @override
  bool get isLoggedIn => loggedIn;

  @override
  Future<Partner> login({
    required String email,
    required String password,
  }) async {
    if (failWith != null) throw PartnerAuthException(failWith!);
    loggedIn = true;
    return _partner;
  }

  @override
  Future<void> logout() async {
    loggedIn = false;
  }
}

late SharedPreferences _prefs;

Future<void> _pumpApp(WidgetTester tester, {String? loginFails}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(_prefs),
        partnerAuthRepositoryProvider.overrideWith(
          (ref) => _FakeAuthRepository(Dio(), _prefs, failWith: loginFails),
        ),
      ],
      child: const PartnerApp(),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _reachLogin(WidgetTester tester) async {
  for (var i = 0; i < 2; i++) {
    await tester.tap(find.text('NEXT'));
    await tester.pumpAndSettle();
  }
  await tester.tap(find.text('GET STARTED'));
  await tester.pumpAndSettle();
}

Future<void> _fillCredentials(WidgetTester tester) async {
  await tester.enterText(
      find.byType(TextFormField).first, 'partner@glamira.com');
  await tester.enterText(find.byType(TextFormField).last, 'supersecret');
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    _prefs = await SharedPreferences.getInstance();
  });

  testWidgets('Onboarding opens on the first slide', (tester) async {
    await _pumpApp(tester);
    expect(find.text('Grow Your Beauty Business'), findsOneWidget);
    expect(find.text('NEXT'), findsOneWidget);
  });

  testWidgets('NEXT walks through all three slides to GET STARTED',
      (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.text('NEXT'));
    await tester.pumpAndSettle();
    expect(find.text('Seamless Management'), findsOneWidget);

    await tester.tap(find.text('NEXT'));
    await tester.pumpAndSettle();
    expect(find.text('Real-time Insights'), findsOneWidget);
    expect(find.text('GET STARTED'), findsOneWidget);
  });

  testWidgets('GET STARTED opens login and remembers onboarding was seen',
      (tester) async {
    await _pumpApp(tester);
    await _reachLogin(tester);

    expect(find.text('Please sign in to your account'), findsOneWidget);
    expect(_prefs.getBool(kHasSeenOnboardingKey), isTrue);
  });

  testWidgets('Onboarding is skipped once it has been seen', (tester) async {
    SharedPreferences.setMockInitialValues({kHasSeenOnboardingKey: true});
    _prefs = await SharedPreferences.getInstance();

    await _pumpApp(tester);
    expect(find.text('Please sign in to your account'), findsOneWidget);
    expect(find.text('Grow Your Beauty Business'), findsNothing);
  });

  testWidgets('A successful login opens Add Service', (tester) async {
    await _pumpApp(tester);
    await _reachLogin(tester);
    await _fillCredentials(tester);

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Add Service'), findsOneWidget);
    expect(find.text('Service Details'), findsOneWidget);
  });

  testWidgets('A failed login shows the API message and stays put',
      (tester) async {
    await _pumpApp(tester, loginFails: 'Incorrect email or password.');
    await _reachLogin(tester);
    await _fillCredentials(tester);

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Incorrect email or password.'), findsOneWidget);
    expect(find.text('Add Service'), findsNothing);
  });

  testWidgets('Logout returns to login and clears the session',
      (tester) async {
    await _pumpApp(tester);
    await _reachLogin(tester);
    await _fillCredentials(tester);
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    expect(find.text('Add Service'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();

    // Back at login, and the signed-out state is reflected in the app.
    expect(find.text('Please sign in to your account'), findsOneWidget);
    expect(find.text('Add Service'), findsNothing);

    // And logging in again still works.
    await _fillCredentials(tester);
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    expect(find.text('Add Service'), findsOneWidget);
  });

  testWidgets('Forgot Password opens the reset-code request screen',
      (tester) async {
    await _pumpApp(tester);
    await _reachLogin(tester);

    await tester.tap(find.text('Forgot Password?'));
    await tester.pumpAndSettle();

    expect(find.text('Forgot Password'), findsOneWidget);
    expect(find.text('Send Reset Code'), findsOneWidget);
  });

  testWidgets('Sign Up link opens the partner sign-up screen', (tester) async {
    await _pumpApp(tester);
    await _reachLogin(tester);

    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    expect(find.text('Grow Your Business'), findsOneWidget);
    expect(find.text('CREATE PARTNER ACCOUNT'), findsOneWidget);
  });
}
