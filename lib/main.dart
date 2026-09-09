import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/auth_providers.dart';
import 'screens/auth/partner_login_page.dart';
import 'screens/onboarding/partner_onboarding_screen.dart';
import 'screens/services/add_service_page.dart';
import 'theme/app_colors.dart';
import 'widgets/responsive_frame.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const PartnerApp(),
    ),
  );
}

class PartnerApp extends StatelessWidget {
  const PartnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Glamira Partner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.brand),
        scaffoldBackgroundColor: AppColors.canvas,
        useMaterial3: true,
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.ink,
          contentTextStyle: const TextStyle(color: Colors.white),
          insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const PartnerAuthGate(),
      // Constrains the mobile design to a centered phone-width frame on large
      // screens and drives flutter_screenutil's scaling. Applies to every route.
      builder: (context, child) => ResponsiveFrame(child: child!),
    );
  }
}

/// Chooses the first screen: the signed-in area if a token is stored,
/// onboarding on a first launch, otherwise login.
class PartnerAuthGate extends ConsumerWidget {
  const PartnerAuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loggedIn = ref.watch(authStateProvider);
    if (loggedIn) return const AddServicePage();

    final seenOnboarding = ref.watch(onboardingSeenProvider);
    return seenOnboarding
        ? const PartnerLoginPage()
        : const PartnerOnboardingScreen();
  }
}
