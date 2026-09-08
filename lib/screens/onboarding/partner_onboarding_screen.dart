import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_colors.dart';
import '../../widgets/auth_widgets.dart';
import '../auth/partner_login_page.dart';

/// One onboarding slide's content.
class _OnboardingPage {
  const _OnboardingPage({
    required this.image,
    required this.title,
    required this.body,
    this.framed = false,
  });

  final String image;
  final String title;
  final String body;

  /// The "Real-time Insights" artwork sits in a bordered white card; the
  /// other two are full-bleed squares.
  final bool framed;
}

/// Partner onboarding — three swipeable slides translated from the Figma
/// frames "Partner Onboarding - Grow Business" (56:266), "- Seamless
/// management" (61:3) and "- real time insignts" (61:2).
///
/// The slide order comes from the active progress dot in each frame, not from
/// the node ids: Grow → Seamless → Insights (which carries "GET STARTED").
class PartnerOnboardingScreen extends StatefulWidget {
  const PartnerOnboardingScreen({super.key});

  @override
  State<PartnerOnboardingScreen> createState() =>
      _PartnerOnboardingScreenState();
}

class _PartnerOnboardingScreenState extends State<PartnerOnboardingScreen> {
  /// Corner radius of the slide artwork.
  static const double _artworkRadius = 20;

  final _controller = PageController();
  int _index = 0;

  static const List<_OnboardingPage> _pages = [
    _OnboardingPage(
      image: 'assets/images/onboarding_grow.png',
      title: 'Grow Your Beauty Business',
      body: 'Connect with thousands of clients in Kathmandu and '
          'manage your salon with ease.',
    ),
    _OnboardingPage(
      image: 'assets/images/onboarding_manage.png',
      title: 'Seamless Management',
      body: 'Effortlessly manage appointments, staff schedules, '
          'and service listings in one place.',
    ),
    _OnboardingPage(
      image: 'assets/images/onboarding_insights.png',
      title: 'Real-time Insights',
      body: 'Track your earnings, customer growth, and performance '
          'with detailed analytics.',
      framed: true,
    ),
  ];

  bool get _isLast => _index == _pages.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _advance() {
    if (_isLast) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PartnerLoginPage()),
      );
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) => _buildSlide(_pages[i]),
              ),
            ),
            _buildDots(),
            SizedBox(height: 40.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: PartnerPrimaryButton(
                label: _isLast ? 'GET STARTED' : 'NEXT',
                onTap: _advance,
                borderRadius: 12,
                verticalPadding: 16,
                textColor: Colors.white,
                fontWeight: FontWeight.w700,
                shadow: true,
                trailing: SvgPicture.asset(
                  'assets/svg/arrow_right.svg',
                  width: 12.r,
                  height: 12.r,
                ),
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(_OnboardingPage page) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        children: [
          // 100px from the frame top in Figma, less the status bar that
          // SafeArea already accounts for.
          SizedBox(height: 53.h),
          _buildArtwork(page),
          SizedBox(height: 45.h),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.bodoniModa(
              fontSize: 28.sp,
              height: 36 / 28,
              fontWeight: FontWeight.w400,
              color: AppColors.ink,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            page.body,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              height: 24 / 16,
              fontWeight: FontWeight.w400,
              color: AppColors.body,
            ),
          ),
        ],
      ),
    );
  }

  /// The artwork is a square that fills the content width, matching the
  /// 358x358 box inset 35px in the 428-wide Figma frame.
  Widget _buildArtwork(_OnboardingPage page) {
    final image = Image.asset(
      page.image,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );

    return AspectRatio(
      aspectRatio: 1,
      child: page.framed
          ? Container(
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(_artworkRadius.r),
                border: Border.all(color: AppColors.dotInactive),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.05),
                    offset: Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                // Inset by the 1px border so the corners stay concentric.
                borderRadius: BorderRadius.circular(_artworkRadius.r - 1),
                child: image,
              ),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(_artworkRadius.r),
              child: image,
            ),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < _pages.length; i++) ...[
          if (i > 0) SizedBox(width: 8.w),
          Container(
            width: 8.r,
            height: 8.r,
            decoration: BoxDecoration(
              color: i == _index ? AppColors.link : AppColors.dotInactive,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ],
    );
  }
}
