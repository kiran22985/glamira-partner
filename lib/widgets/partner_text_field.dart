import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

/// Labeled text input used across the partner auth screens.
///
/// Sizing is parameterized so the same widget renders both Figma styles:
/// the Login field (radius 8, leading icon, placeholder) and the Sign-up
/// field (radius 12, no icon, no placeholder).
class PartnerTextField extends StatelessWidget {
  const PartnerTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.labelTrailing,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.borderRadius = 12,
    this.validator,
    this.hintColor = AppColors.border,
    this.contentPadding,
    this.maxLines = 1,
    this.minHeight = 44,
    this.labelGap = 4,
  });

  /// Field label, rendered above the input in small caps-ish tracking.
  final String label;

  /// Placeholder shown inside the input. The sign-up fields have none.
  final String? hint;

  final TextEditingController? controller;

  /// Optional widget pinned to the right of the label row — used for the
  /// Login screen's "Forgot Password?" link.
  final Widget? labelTrailing;

  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  /// 8 on the Login screen, 12 on Sign-up.
  final double borderRadius;

  final String? Function(String?)? validator;

  /// Placeholder colour — [AppColors.border] on the auth screens, the darker
  /// [AppColors.hint] on the Add Service form.
  final Color hintColor;

  /// Overrides the default padding; the Add Service inputs are roomier.
  final EdgeInsetsGeometry? contentPadding;

  /// >1 turns the field into a textarea (the service Description).
  final int maxLines;

  /// Minimum box height, before any error text.
  final double minHeight;

  /// Space between the label and the input — 4 on auth, 8 on Add Service.
  final double labelGap;

  static const Color _errorColor = Color(0xFFB3261E);

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius.r),
          borderSide: BorderSide(color: color),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: labelTrailing != null
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.start,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  height: 16 / 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                  color: AppColors.ink,
                ),
              ),
            ),
            if (labelTrailing != null) Flexible(child: labelTrailing!),
          ],
        ),
        SizedBox(height: labelGap.h),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          maxLines: obscureText ? 1 : maxLines,
          style: GoogleFonts.inter(fontSize: 14.sp, color: AppColors.ink),
          decoration: InputDecoration(
            isDense: true,
            // Keep the designed box height; errors render below it.
            constraints: BoxConstraints(minHeight: minHeight.h),
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 14.sp,
              color: hintColor,
            ),
            filled: true,
            fillColor: Colors.white,
            // 12 + 17 + 12 puts the text at x=41, matching the Figma inputs.
            prefixIcon: prefixIcon == null
                ? null
                : Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Icon(prefixIcon, size: 17.r, color: AppColors.body),
                  ),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
            suffixIcon: suffixIcon,
            suffixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
            contentPadding: contentPadding ??
                EdgeInsets.only(
                  left: prefixIcon == null ? 13.w : 0,
                  right: 13.w,
                  top: 12.h,
                  bottom: 13.h,
                ),
            errorStyle: GoogleFonts.inter(fontSize: 12.sp, color: _errorColor),
            border: border(AppColors.border),
            enabledBorder: border(AppColors.border),
            focusedBorder: border(AppColors.brand),
            errorBorder: border(_errorColor),
            focusedErrorBorder: border(_errorColor),
          ),
        ),
      ],
    );
  }
}
