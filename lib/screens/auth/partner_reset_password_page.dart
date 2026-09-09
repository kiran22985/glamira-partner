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

/// Step 2 of the password reset: the emailed 6-digit code plus a new password.
/// On success it pops back to the login screen.
class PartnerResetPasswordPage extends ConsumerStatefulWidget {
  const PartnerResetPasswordPage({super.key, required this.email});

  final String email;

  @override
  ConsumerState<PartnerResetPasswordPage> createState() =>
      _PartnerResetPasswordPageState();
}

class _PartnerResetPasswordPageState
    extends ConsumerState<PartnerResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _submitting = false;

  @override
  void dispose() {
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);
    try {
      await ref.read(partnerAuthRepositoryProvider).resetPassword(
            email: widget.email,
            code: _codeController.text,
            newPassword: _passwordController.text,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset. Sign in with your new password.'),
        ),
      );
      Navigator.of(context).pop();
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
              'Reset Password',
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
              'Enter the 6-digit code sent to ${widget.email}.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                height: 20 / 14,
                color: AppColors.body,
              ),
            ),
            SizedBox(height: 24.h),
            PartnerTextField(
              label: 'Reset Code',
              hint: '000000',
              controller: _codeController,
              prefixIcon: Icons.confirmation_number_outlined,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              borderRadius: 8,
              validator: Validators.code,
            ),
            SizedBox(height: 20.h),
            PartnerTextField(
              label: 'New Password',
              hint: '••••••••',
              controller: _passwordController,
              prefixIcon: Icons.lock_outline,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              borderRadius: 8,
              validator: Validators.password,
              suffixIcon: _visibilityToggle(
                obscured: _obscurePassword,
                onTap: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            SizedBox(height: 20.h),
            PartnerTextField(
              label: 'Confirm Password',
              hint: '••••••••',
              controller: _confirmController,
              prefixIcon: Icons.lock_outline,
              obscureText: _obscureConfirm,
              textInputAction: TextInputAction.done,
              borderRadius: 8,
              validator: (v) =>
                  Validators.confirmPassword(v, _passwordController.text),
              suffixIcon: _visibilityToggle(
                obscured: _obscureConfirm,
                onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
            SizedBox(height: 24.h),
            PartnerPrimaryButton(
              label: 'Reset Password',
              busy: _submitting,
              onTap: _resetPassword,
            ),
          ],
        ),
      ),
    );
  }

  Widget _visibilityToggle({
    required bool obscured,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(right: 12.w),
      child: GestureDetector(
        onTap: onTap,
        child: Icon(
          obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 18.r,
          color: AppColors.body,
        ),
      ),
    );
  }
}
