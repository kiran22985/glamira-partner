import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';

/// Wraps the whole app so a mobile-first design behaves on every screen size.
///
/// On phones it fills the screen as usual. On wide screens (tablet, desktop,
/// web) it renders inside a centered, phone-width frame instead of stretching —
/// and initializes flutter_screenutil against that *frame* width so fonts and
/// spacing don't balloon.
///
/// Mirrors the customer app's wrapper of the same name so both apps scale
/// identically.
class ResponsiveFrame extends StatelessWidget {
  const ResponsiveFrame({super.key, required this.child});

  final Widget child;

  /// Design frame from the Figma file.
  static const Size designSize = Size(390, 844);

  /// Maximum width of the mobile frame on wide screens.
  static const double maxFrameWidth = 480;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.canvas,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double frameWidth = constraints.maxWidth > maxFrameWidth
              ? maxFrameWidth
              : constraints.maxWidth;
          final double frameHeight = constraints.maxHeight;

          final MediaQueryData mq = MediaQuery.of(context).copyWith(
            size: Size(frameWidth, frameHeight),
          );

          // Scale relative to the (possibly clamped) frame, not the raw window.
          ScreenUtil.configure(
            data: mq,
            designSize: designSize,
            minTextAdapt: true,
            splitScreenMode: true,
          );

          return Center(
            child: SizedBox(
              width: frameWidth,
              height: frameHeight,
              child: ClipRect(
                child: MediaQuery(data: mq, child: child),
              ),
            ),
          );
        },
      ),
    );
  }
}
