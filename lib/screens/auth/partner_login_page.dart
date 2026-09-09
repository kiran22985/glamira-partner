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
import '../services/add_service_page.dart';
import 'partner_forgot_password_page.dart';
import 'partner_signup_page.dart';

/// Partner Login screen — translated from the Figma "Partner Login" frame
/// (node 54:2).
class PartnerLoginPage extends ConsumerStatefulWidget {
  const PartnerLoginPage({super.key});

  @override
  ConsumerState<PartnerLoginPage> createState() => _PartnerLoginPageState();
}

class _PartnerLoginPageState extends ConsumerState<PartnerLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _submitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    await _authenticate(
      () => ref.read(partnerAuthRepositoryProvider).login(
            email: _emailController.text,
            password: _passwordController.text,
          ),
    );
  }

  Future<void> _googleSignIn() async {
    FocusScope.of(context).unfocus();
    await _authenticate(
      () => ref.read(partnerAuthRepositoryProvider).signInWithGoogle(),
    );
  }

  /// Runs [request], then hands off to the signed-in area on success.
  Future<void> _authenticate(Future<void> Function() request) async {
    setState(() => _submitting = true);
    try {
      await request();
      ref.read(authStateProvider.notifier).refresh();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AddServicePage()),
        (route) => false,
      );
    } on PartnerAuthException catch (e) {
      _showError(e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        // minHeight + Center vertically centers the card when it fits, and
        // lets it scroll when the keyboard or a small screen squeezes it.
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 35.5.h),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 420.w),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 32.h, 16.w, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildCard(),
                            SizedBox(height: 32.h),
                            AuthFooterLink(
                              prompt: "Don't have an account?",
                              action: 'Sign Up',
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const PartnerSignupPage(),
                                ),
                              ),
                            ),
                          ],
                        ),
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
              'Please sign in to your account',
              textAlign: TextAlign.center,
              style: GoogleFonts.bodoniModa(
                fontSize: 16.sp,
                height: 24 / 16,
                fontWeight: FontWeight.w400,
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
              textInputAction: TextInputAction.next,
              borderRadius: 8,
              validator: Validators.email,
            ),
            SizedBox(height: 20.h),
            PartnerTextField(
              label: 'Password',
              hint: '••••••••',
              controller: _passwordController,
              prefixIcon: Icons.lock_outline,
              obscureText: _obscure,
              textInputAction: TextInputAction.done,
              borderRadius: 8,
              validator: (v) => Validators.requiredField(v, field: 'Password'),
              labelTrailing: GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PartnerForgotPasswordPage(),
                  ),
                ),
                child: Text(
                  'Forgot Password?',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    height: 16 / 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                    color: AppColors.link,
                  ),
                ),
              ),
              suffixIcon: Padding(
                padding: EdgeInsets.only(right: 12.w),
                child: GestureDetector(
                  onTap: () => setState(() => _obscure = !_obscure),
                  child: Icon(
                    _obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 18.r,
                    color: AppColors.body,
                  ),
                ),
              ),
            ),
            // 20 form gap + 8 button margin from the Figma frame.
            SizedBox(height: 28.h),
            PartnerPrimaryButton(
              label: 'Login',
              busy: _submitting,
              onTap: _login,
            ),
            SizedBox(height: 24.h),
            const OrSeparator(label: 'OR CONTINUE WITH'),
            SizedBox(height: 24.h),
            GoogleButton(busy: _submitting, onTap: _googleSignIn),
          ],
        ),
      ),
    );
  }
}
