import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';
import '../../utils/validators.dart';
import '../../widgets/auth_widgets.dart';
import '../../widgets/partner_text_field.dart';

/// Partner Sign Up screen — translated from the Figma
/// "Partner Sign Up - Updated Flow" frame (node 54:50).
class PartnerSignupPage extends StatefulWidget {
  const PartnerSignupPage({super.key});

  @override
  State<PartnerSignupPage> createState() => _PartnerSignupPageState();
}

class _PartnerSignupPageState extends State<PartnerSignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _businessNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      _snack('Please accept the Terms & Conditions to continue.');
      return;
    }
    FocusScope.of(context).unfocus();
    // The partner API doesn't exist yet — see the backend's auth-only schema.
    _snack('Partner sign-up — not wired up yet');
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Stack(
        children: [
          // Ambient background pattern (node 54:51).
          const _AmbientBlob(
            size: 384,
            color: Color.fromRGBO(140, 99, 115, 0.2),
            top: -160,
            right: -160,
          ),
          const _AmbientBlob(
            size: 288,
            color: Color.fromRGBO(254, 214, 91, 0.2),
            top: 282.66,
            left: -80,
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.r),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 448.w),
                  child: _buildCard(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          padding: EdgeInsets.all(33.r),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(255, 255, 255, 0.85),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: const Color.fromRGBO(211, 194, 199, 0.3)),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.04),
                offset: Offset(0, 8),
                blurRadius: 32,
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Grow Your Business',
                  style: GoogleFonts.bodoniModa(
                    fontSize: 24.sp,
                    height: 32 / 24,
                    fontWeight: FontWeight.w400,
                    color: AppColors.ink,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "Join Kathmandu's premier beauty network.",
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    height: 20 / 14,
                    color: AppColors.body,
                  ),
                ),
                SizedBox(height: 32.h),
                PartnerTextField(
                  label: 'FULL NAME',
                  controller: _fullNameController,
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      Validators.requiredField(v, field: 'Full name'),
                ),
                SizedBox(height: 20.h),
                PartnerTextField(
                  label: 'BUSINESS NAME',
                  controller: _businessNameController,
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      Validators.requiredField(v, field: 'Business name'),
                ),
                SizedBox(height: 20.h),
                PartnerTextField(
                  label: 'EMAIL',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: Validators.email,
                ),
                SizedBox(height: 20.h),
                PartnerTextField(
                  label: 'PHONE NUMBER',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  validator: Validators.phone,
                ),
                SizedBox(height: 20.h),
                PartnerTextField(
                  label: 'PASSWORD',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  validator: Validators.password,
                  suffixIcon: _visibilityToggle(
                    obscured: _obscurePassword,
                    onTap: () => setState(
                      () => _obscurePassword = !_obscurePassword,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                PartnerTextField(
                  label: 'CONFIRM PASSWORD',
                  controller: _confirmController,
                  obscureText: _obscureConfirm,
                  textInputAction: TextInputAction.done,
                  validator: (v) => Validators.confirmPassword(
                    v,
                    _passwordController.text,
                  ),
                  suffixIcon: _visibilityToggle(
                    obscured: _obscureConfirm,
                    onTap: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                // 20 form gap + the terms row's own 8/16 padding.
                SizedBox(height: 28.h),
                _buildTerms(),
                SizedBox(height: 36.h),
                PartnerPrimaryButton(
                  label: 'CREATE PARTNER ACCOUNT',
                  onTap: _submit,
                  borderRadius: 12,
                  verticalPadding: 13,
                  textColor: Colors.white,
                  shadow: true,
                ),
                SizedBox(height: 32.h),
                AuthFooterLink(
                  prompt: 'Already a partner?',
                  action: 'LOGIN',
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
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

  Widget _buildTerms() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 16.r,
            height: 16.r,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _agreedToTerms ? AppColors.brand : Colors.white,
              borderRadius: BorderRadius.circular(4.r),
              border: Border.all(color: AppColors.border),
            ),
            child: _agreedToTerms
                ? Icon(Icons.check, size: 12.r, color: Colors.white)
                : null,
          ),
        ),
        SizedBox(width: 12.w),
        Flexible(
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'I agree to the '),
                const TextSpan(
                  text: 'Terms & Conditions',
                  style: TextStyle(color: AppColors.link),
                ),
              ],
            ),
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              height: 20 / 14,
              color: AppColors.body,
            ),
          ),
        ),
      ],
    );
  }
}

/// A soft, blurred decorative circle in the sign-up screen's background.
class _AmbientBlob extends StatelessWidget {
  const _AmbientBlob({
    required this.size,
    required this.color,
    this.top,
    this.left,
    this.right,
  });

  final double size;
  final Color color;
  final double? top;
  final double? left;
  final double? right;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top?.h,
      left: left?.w,
      right: right?.w,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
        child: Container(
          width: size.r,
          height: size.r,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }
}
