import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

/// Solid brand action button — the Login and "Create Partner Account" buttons.
///
/// Both Figma buttons share a fill and type ramp but differ in corner radius
/// and padding, so those are parameterized.
class PartnerPrimaryButton extends StatelessWidget {
  const PartnerPrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.borderRadius = 8,
    this.verticalPadding = 12,
    this.textColor = AppColors.onBrand,
    this.fontWeight = FontWeight.w600,
    this.trailing,
    this.shadow = false,
    this.busy = false,
  });

  final String label;
  final VoidCallback onTap;
  final double borderRadius;
  final double verticalPadding;
  final Color textColor;

  /// w600 on the auth screens, w700 on the onboarding CTAs.
  final FontWeight fontWeight;

  /// Optional icon drawn 8px after the label — the onboarding arrow.
  final Widget? trailing;

  /// The sign-up submit carries a 1px drop shadow; the login button doesn't.
  final bool shadow;

  /// When true, shows a spinner and ignores taps (request in flight).
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: busy ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: verticalPadding.h),
        decoration: BoxDecoration(
          color: AppColors.brand,
          borderRadius: BorderRadius.circular(borderRadius.r),
          boxShadow: shadow
              ? const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.05),
                    offset: Offset(0, 1),
                    blurRadius: 1,
                  ),
                ]
              : null,
        ),
        child: busy
            ? Center(
                child: SizedBox(
                  width: 16.r,
                  height: 16.r,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(textColor),
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        height: 16 / 12,
                        fontWeight: fontWeight,
                        letterSpacing: 0.6,
                        color: textColor,
                      ),
                    ),
                  ),
                  if (trailing != null) ...[
                    SizedBox(width: 8.w),
                    trailing!,
                  ],
                ],
              ),
      ),
    );
  }
}

/// White outlined "Google" button on the Login screen.
class GoogleButton extends StatelessWidget {
  const GoogleButton({super.key, required this.onTap, this.busy = false});

  final VoidCallback onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: busy ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 11.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.border),
        ),
        child: busy
            ? Center(
                child: SizedBox(
                  width: 16.r,
                  height: 16.r,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(AppColors.brand),
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/svg/google_logo.svg',
                    width: 20.r,
                    height: 20.r,
                  ),
                  SizedBox(width: 12.w),
                  Flexible(
                    child: Text(
                      'Google',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        height: 16 / 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// "──── OR CONTINUE WITH ────" separator.
class OrSeparator extends StatelessWidget {
  const OrSeparator({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    const divider = Expanded(
      child: SizedBox(height: 1, child: ColoredBox(color: AppColors.border)),
    );
    return Row(
      children: [
        divider,
        Flexible(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                height: 16 / 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
                color: AppColors.body,
              ),
            ),
          ),
        ),
        divider,
      ],
    );
  }
}

/// Left-aligned back chevron for the secondary auth screens.
class AuthBackButton extends StatelessWidget {
  const AuthBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () => Navigator.of(context).maybePop(),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: EdgeInsets.all(8.r),
          child: Icon(Icons.arrow_back, size: 20.r, color: AppColors.ink),
        ),
      ),
    );
  }
}

/// Footer row: muted prompt followed by a brand-coloured action link.
class AuthFooterLink extends StatelessWidget {
  const AuthFooterLink({
    super.key,
    required this.prompt,
    required this.action,
    required this.onTap,
  });

  final String prompt;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            prompt,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              height: 20 / 14,
              color: AppColors.body,
            ),
          ),
        ),
        SizedBox(width: 4.w),
        Flexible(
          child: GestureDetector(
            onTap: onTap,
            child: Text(
              action,
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                height: 16 / 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
                color: AppColors.link,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
