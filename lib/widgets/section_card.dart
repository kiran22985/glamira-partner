import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

/// White content card with a hairline border and an optional Bodoni heading —
/// the repeating container on the Add Service form.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.child,
    this.title,
    this.titleTrailing,
    this.gap = 24,
  });

  final Widget child;

  /// Heading rendered above [child]; omit for a card that is just a row.
  final String? title;

  /// Optional action pinned to the right of the heading (e.g. "+ Add").
  final Widget? titleTrailing;

  /// Space between the heading and [child].
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(25.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    title!,
                    style: GoogleFonts.bodoniModa(
                      fontSize: 20.sp,
                      height: 28 / 20,
                      fontWeight: FontWeight.w400,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                ?titleTrailing,
              ],
            ),
            SizedBox(height: gap.h),
          ],
          child,
        ],
      ),
    );
  }
}
