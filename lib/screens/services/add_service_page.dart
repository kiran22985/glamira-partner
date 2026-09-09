import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/auth_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/auth_widgets.dart';
import '../../widgets/dashed_border.dart';
import '../../widgets/partner_text_field.dart';
import '../../widgets/section_card.dart';
import '../auth/partner_login_page.dart';

/// A staff member who can perform the service.
class _Specialist {
  const _Specialist(this.name, this.avatar);
  final String name;
  final String avatar;
}

/// Add Service form — translated from the Figma "Add_service." frame (73:34).
class AddServicePage extends ConsumerStatefulWidget {
  const AddServicePage({super.key});

  @override
  ConsumerState<AddServicePage> createState() => _AddServicePageState();
}

class _AddServicePageState extends ConsumerState<AddServicePage> {
  static const List<String> _categories = ['Skincare', 'Hair', 'Body', 'Nails'];

  static const List<_Specialist> _specialists = [
    _Specialist('Elena Rostova', 'assets/images/specialist_elena.png'),
    _Specialist('Marcus Chen', 'assets/images/specialist_marcus.png'),
  ];

  static const List<int> _durationOptions = [15, 30, 45, 60, 90, 120];

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  String _category = 'Skincare';
  int? _durationMinutes;
  bool _available = true;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  /// Clears the stored token and returns to login.
  ///
  /// Temporary affordance so the auth flow can be exercised end to end — this
  /// belongs on a profile screen once one exists.
  Future<void> _logout() async {
    await ref.read(partnerAuthRepositoryProvider).logout();
    ref.read(authStateProvider.notifier).refresh();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const PartnerLoginPage()),
      (route) => false,
    );
  }

  Future<void> _pickDuration() async {
    FocusScope.of(context).unfocus();
    final picked = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 8.h),
            for (final minutes in _durationOptions)
              ListTile(
                title: Text(
                  _formatDuration(minutes),
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: AppColors.ink,
                  ),
                ),
                trailing: minutes == _durationMinutes
                    ? const Icon(Icons.check, color: AppColors.brand)
                    : null,
                onTap: () => Navigator.pop(sheetContext, minutes),
              ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _durationMinutes = picked);
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final rest = minutes % 60;
    final hourLabel = '$hours hour${hours > 1 ? 's' : ''}';
    return rest == 0 ? hourLabel : '$hourLabel $rest min';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 96.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildServiceDetailsCard(),
                    SizedBox(height: 24.h),
                    _buildPricingCard(),
                    SizedBox(height: 24.h),
                    _buildStatusCard(),
                    SizedBox(height: 24.h),
                    _buildSpecialistsCard(),
                    SizedBox(height: 32.h),
                    PartnerPrimaryButton(
                      label: 'Save Service',
                      onTap: () => _snack('Save Service — not wired up yet'),
                      borderRadius: 12,
                      shadow: true,
                    ),
                    SizedBox(height: 16.h),
                    _buildCancelButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- Header ------------------------------------------------------------

  Widget _buildHeader() {
    return Container(
      height: 64.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: const BoxDecoration(
        color: AppColors.canvas,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              child: Icon(Icons.arrow_back, size: 16.r, color: AppColors.ink),
            ),
          ),
          Expanded(
            child: Text(
              'Add Service',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.bodoniModa(
                fontSize: 24.sp,
                height: 32 / 24,
                fontWeight: FontWeight.w500,
                color: AppColors.ink,
              ),
            ),
          ),
          // Temporary: not in the Figma frame, here so the auth flow can be
          // tested end to end. Move to a profile screen when one exists.
          GestureDetector(
            onTap: _logout,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              child: Icon(Icons.logout, size: 20.r, color: AppColors.link),
            ),
          ),
        ],
      ),
    );
  }

  // ---- Service details ---------------------------------------------------

  Widget _buildServiceDetailsCard() {
    return SectionCard(
      title: 'Service Details',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PartnerTextField(
            label: 'Service Name',
            hint: 'e.g. Hydra-Glow Facial',
            controller: _nameController,
            hintColor: AppColors.hint,
            labelGap: 8,
            minHeight: 46,
            contentPadding: EdgeInsets.fromLTRB(17.w, 14.h, 17.w, 15.h),
          ),
          SizedBox(height: 20.h),
          _buildCategoryField(),
          SizedBox(height: 20.h),
          PartnerTextField(
            label: 'Description',
            hint: 'Describe the service, benefits, and what the client '
                'can expect...',
            controller: _descriptionController,
            hintColor: AppColors.hint,
            labelGap: 8,
            maxLines: 4,
            minHeight: 86,
            contentPadding: EdgeInsets.fromLTRB(17.w, 13.h, 17.w, 13.h),
          ),
          SizedBox(height: 6.h),
        ],
      ),
    );
  }

  Widget _buildCategoryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Category'),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 10.h,
          children: [
            for (final category in _categories)
              _CategoryChip(
                label: category,
                selected: category == _category,
                onTap: () => setState(() => _category = category),
              ),
            _AddNewChip(onTap: () => _snack('Add category — not wired up yet')),
          ],
        ),
      ],
    );
  }

  // ---- Pricing & duration ------------------------------------------------

  Widget _buildPricingCard() {
    return SectionCard(
      title: 'Pricing & Duration',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPriceField(),
          SizedBox(height: 20.h),
          _buildDurationField(),
        ],
      ),
    );
  }

  Widget _buildPriceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Price'),
        SizedBox(height: 8.h),
        Container(
          height: 46.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Text(
                r'$',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  height: 20 / 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.14,
                  color: AppColors.body,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: TextField(
                  controller: _priceController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.14,
                    color: AppColors.ink,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: '0.00',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.14,
                      color: AppColors.hint,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDurationField() {
    final selected = _durationMinutes != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Duration'),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: _pickDuration,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 13.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selected
                        ? _formatDuration(_durationMinutes!)
                        : 'Select duration',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    // Figma renders the placeholder in ink, same as a value.
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      height: 20 / 14,
                      color: AppColors.ink,
                    ),
                  ),
                ),
                Icon(Icons.keyboard_arrow_down,
                    size: 20.r, color: AppColors.body),
                SizedBox(width: 8.w),
                Icon(Icons.access_time, size: 21.r, color: AppColors.body),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---- Status ------------------------------------------------------------

  Widget _buildStatusCard() {
    return SectionCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Service Status',
                  style: GoogleFonts.bodoniModa(
                    fontSize: 20.sp,
                    height: 28 / 20,
                    fontWeight: FontWeight.w400,
                    color: AppColors.ink,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Available for booking',
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    height: 20 / 14,
                    color: AppColors.body,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          _StatusToggle(
            value: _available,
            onChanged: (v) => setState(() => _available = v),
          ),
        ],
      ),
    );
  }

  // ---- Specialists -------------------------------------------------------

  Widget _buildSpecialistsCard() {
    return SectionCard(
      titleTrailing: GestureDetector(
        onTap: () => _snack('Add specialist — not wired up yet'),
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 12.r, color: AppColors.link),
            SizedBox(width: 4.w),
            Text(
              'Add',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                height: 16 / 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
                color: AppColors.link,
              ),
            ),
          ],
        ),
      ),
      title: 'Specialists',
      gap: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Assign staff members who can perform this service.',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              height: 20 / 14,
              color: AppColors.body,
            ),
          ),
          SizedBox(height: 16.h),
          for (var i = 0; i < _specialists.length; i++) ...[
            if (i > 0) SizedBox(height: 12.h),
            _buildSpecialistRow(_specialists[i]),
          ],
        ],
      ),
    );
  }

  Widget _buildSpecialistRow(_Specialist specialist) {
    return Padding(
      padding: EdgeInsets.all(8.r),
      child: Row(
        children: [
          Container(
            width: 32.r,
            height: 32.r,
            decoration: const BoxDecoration(
              color: AppColors.cardBorder,
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(specialist.avatar, fit: BoxFit.cover),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              specialist.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                height: 20 / 14,
                fontWeight: FontWeight.w500,
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---- Shared bits -------------------------------------------------------

  Widget _label(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 12.sp,
        height: 16 / 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
        color: AppColors.ink,
      ),
    );
  }

  Widget _buildCancelButton() {
    return GestureDetector(
      onTap: () => Navigator.of(context).maybePop(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 13.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          'Cancel',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            height: 16 / 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
            // Figma specifies this olive tone for Cancel (#735C00).
            color: const Color(0xFF735C00),
          ),
        ),
      ),
    );
  }
}

/// A selectable pill in the Category row.
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.chipSelected : null,
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: selected ? AppColors.link : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            height: 16 / 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
            color: selected ? AppColors.link : AppColors.body,
          ),
        ),
      ),
    );
  }
}

/// The dashed "+ Add New" pill that follows the category chips.
class _AddNewChip extends StatelessWidget {
  const _AddNewChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: DashedBorder(
        color: AppColors.border,
        radius: 9999,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 9.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, size: 12.r, color: AppColors.body),
              SizedBox(width: 4.w),
              Text(
                'Add New',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  height: 16 / 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                  color: AppColors.body,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 44x24 pill switch used by the Service Status card.
class _StatusToggle extends StatelessWidget {
  const _StatusToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: 44.w,
        height: 24.h,
        padding: EdgeInsets.all(2.r),
        decoration: BoxDecoration(
          color: value ? AppColors.link : AppColors.border,
          borderRadius: BorderRadius.circular(9999),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20.r,
            height: 20.r,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
