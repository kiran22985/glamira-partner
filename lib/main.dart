import 'package:flutter/material.dart';

import 'screens/auth/partner_login_page.dart';
import 'theme/app_colors.dart';
import 'widgets/responsive_frame.dart';

void main() {
  runApp(const PartnerApp());
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
      home: const PartnerLoginPage(),
      // Constrains the mobile design to a centered phone-width frame on large
      // screens and drives flutter_screenutil's scaling. Applies to every route.
      builder: (context, child) => ResponsiveFrame(child: child!),
    );
  }
}
