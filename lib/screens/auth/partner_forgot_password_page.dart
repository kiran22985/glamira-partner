import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/partner_auth_repository.dart';
import '../../providers/auth_providers.dart';
import '../../theme/app_colors.dart';
import '../../utils/validators.dart';
import '../../widgets/auth_widgets.dart';
import '../../widgets/partner_text_field.dart';
import 'partner_reset_password_page.dart';

/// Step 1 of the password reset: ask for the email, then move to the code
/// screen. There's no Figma frame for this — it reuses the login card styling.
class PartnerForgotPasswordPage extends ConsumerStatefulWidget {
  const PartnerForgotPasswordPage({super.key});

  @override
  ConsumerState<PartnerForgotPasswordPage> createState() =>
      _PartnerForgotPasswordPageState();
}

class _PartnerForgotPasswordPageState
    extends ConsumerState<PartnerForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailController.text.trim();

    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);
    try {
      await ref.read(partnerAuthRepositoryProvider).forgotPassword(email);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PartnerResetPasswordPage(email: email),
        ),
      );
    } on PartnerAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 32.h,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 420.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const AuthBackButton(),
                          SizedBox(height: 16.h),
                          _buildCard(),
                          SizedBox(height: 32.h),
                          AuthFooterLink(
                            prompt: 'Remembered it?',
                            action: 'Back to Login',
                            onTap: () => Navigator.of(context).maybePop(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      padding: EdgeInsets.all(25.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Forgot Password',
              textAlign: TextAlign.center,
              style: GoogleFonts.bodoniModa(
                fontSize: 24.sp,
                height: 32 / 24,
                fontWeight: FontWeight.w500,
                color: AppColors.ink,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "Enter your email and we'll send you a 6-digit reset code.",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                height: 20 / 14,
                color: AppColors.body,
              ),
            ),
            SizedBox(height: 24.h),
            PartnerTextField(
              label: 'Email Address',
              hint: 'partner@glamira.com',
              controller: _emailController,
              prefixIcon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              borderRadius: 8,
              validator: Validators.email,
            ),
            SizedBox(height: 24.h),
            PartnerPrimaryButton(
              label: 'Send Reset Code',
              busy: _submitting,
              onTap: _sendCode,
            ),
          ],
        ),
      ),
    );
  }
}
