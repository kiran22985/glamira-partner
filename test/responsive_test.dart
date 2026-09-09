// Pumps every screen at a range of device sizes and orientations, failing on
// any layout overflow. Guards the mobile-first design against small phones,
// landscape, tablets and large system font scales.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:glamira_partner/main.dart';
import 'package:glamira_partner/providers/auth_providers.dart';
import 'package:glamira_partner/screens/auth/partner_forgot_password_page.dart';
import 'package:glamira_partner/screens/auth/partner_login_page.dart';
import 'package:glamira_partner/screens/auth/partner_reset_password_page.dart';
import 'package:glamira_partner/screens/auth/partner_signup_page.dart';
import 'package:glamira_partner/screens/onboarding/partner_onboarding_screen.dart';
import 'package:glamira_partner/screens/services/add_service_page.dart';
import 'package:glamira_partner/widgets/responsive_frame.dart';

late SharedPreferences _prefs;

/// Logical sizes worth supporting, smallest first.
const Map<String, Size> _devices = {
  'iPhone SE 1 (320x568)': Size(320, 568),
  'Android small (360x640)': Size(360, 640),
  'iPhone SE 2 (375x667)': Size(375, 667),
  'design size (390x844)': Size(390, 844),
  'Figma frame (428x926)': Size(428, 926),
  'phone landscape (844x390)': Size(844, 390),
  'iPad portrait (768x1024)': Size(768, 1024),
  'iPad landscape (1024x768)': Size(1024, 768),
};

/// Wraps a screen the same way `main.dart` does, so ScreenUtil is configured
/// and the Riverpod providers the auth screens read are available.
Widget _host(Widget child) {
  return ProviderScope(
    overrides: [sharedPreferencesProvider.overrideWithValue(_prefs)],
    child: MaterialApp(
      home: child,
      builder: (context, c) => ResponsiveFrame(child: c!),
    ),
  );
}

Future<void> _pumpAt(
  WidgetTester tester,
  Size size,
  Widget widget, {
  double textScale = 1.0,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(
        size: size,
        textScaler: TextScaler.linear(textScale),
      ),
      child: widget,
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    _prefs = await SharedPreferences.getInstance();
  });

  for (final entry in _devices.entries) {
    testWidgets('Onboarding lays out on ${entry.key}',
        (WidgetTester tester) async {
      await _pumpAt(tester, entry.value, _host(const PartnerOnboardingScreen()));
      expect(tester.takeException(), isNull);
    });

    testWidgets('Login lays out on ${entry.key}', (WidgetTester tester) async {
      await _pumpAt(tester, entry.value, _host(const PartnerLoginPage()));
      expect(tester.takeException(), isNull);
    });

    testWidgets('Sign-up lays out on ${entry.key}',
        (WidgetTester tester) async {
      await _pumpAt(tester, entry.value, _host(const PartnerSignupPage()));
      expect(tester.takeException(), isNull);
    });

    testWidgets('Add Service lays out on ${entry.key}',
        (WidgetTester tester) async {
      await _pumpAt(tester, entry.value, _host(const AddServicePage()));
      expect(tester.takeException(), isNull);
    });

    testWidgets('Forgot password lays out on ${entry.key}',
        (WidgetTester tester) async {
      await _pumpAt(
          tester, entry.value, _host(const PartnerForgotPasswordPage()));
      expect(tester.takeException(), isNull);
    });

    testWidgets('Reset password lays out on ${entry.key}',
        (WidgetTester tester) async {
      await _pumpAt(
        tester,
        entry.value,
        _host(const PartnerResetPasswordPage(email: 'partner@glamira.com')),
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Screens survive a 1.5x system font scale',
      (WidgetTester tester) async {
    for (final screen in <Widget>[
      const PartnerOnboardingScreen(),
      const PartnerLoginPage(),
      const PartnerSignupPage(),
      const AddServicePage(),
      const PartnerForgotPasswordPage(),
      const PartnerResetPasswordPage(email: 'partner@glamira.com'),
    ]) {
      await _pumpAt(tester, const Size(360, 640), _host(screen),
          textScale: 1.5);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('Full app boots without overflow on the smallest phone',
      (WidgetTester tester) async {
    await _pumpAt(
      tester,
      const Size(320, 568),
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(_prefs)],
        child: const PartnerApp(),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
