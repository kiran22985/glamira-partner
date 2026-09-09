import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/app_colors.dart';

/// Labelled, full-width drop area that picks an image from the gallery.
///
/// Matches the width of the form's text fields and stands 150px tall, with the
/// prompt inside the box. Once a picture is chosen it fills the box, with a
/// clear button in the corner.
///
/// The gallery hands back whatever the user taps, so the extension is checked
/// afterwards and anything outside [_allowedExtensions] is rejected — the hint
/// alone can't enforce it.
class ImagePickerField extends StatefulWidget {
  const ImagePickerField({
    super.key,
    required this.label,
    required this.onChanged,
    this.hint = 'Select image in jpg, jpeg, png',
    this.value,
  });

  final String label;

  /// Called with the chosen file, or null when the picture is removed.
  final ValueChanged<File?> onChanged;

  final String hint;

  /// Current selection, owned by the parent form.
  final File? value;

  @override
  State<ImagePickerField> createState() => _ImagePickerFieldState();
}

class _ImagePickerFieldState extends State<ImagePickerField> {
  static const _allowedExtensions = {'jpg', 'jpeg', 'png'};
  static const double _boxHeight = 150;

  bool _picking = false;

  Future<void> _pick() async {
    if (_picking) return;
    setState(() => _picking = true);
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        // Parlor photos are shown small; cap the decode so a 12MP shot
        // doesn't become a huge bitmap.
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (picked == null) return;

      final extension = picked.path.split('.').last.toLowerCase();
      if (!_allowedExtensions.contains(extension)) {
        _error('Please choose a JPG, JPEG or PNG image.');
        return;
      }
      widget.onChanged(File(picked.path));
    } catch (_) {
      _error('Could not open the gallery.');
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  void _error(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            height: 16 / 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
            color: AppColors.ink,
          ),
        ),
        SizedBox(height: 4.h),
        GestureDetector(
          onTap: _pick,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: double.infinity,
            height: _boxHeight.h,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.border),
            ),
            child: _buildContents(),
          ),
        ),
      ],
    );
  }

  Widget _buildContents() {
    if (_picking) {
      return const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation(AppColors.brand),
          ),
        ),
      );
    }

    final file = widget.value;
    if (file == null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 32.r,
                color: AppColors.hint,
              ),
              SizedBox(height: 8.h),
              Text(
                widget.hint,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  height: 20 / 14,
                  color: AppColors.hint,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.file(file, fit: BoxFit.cover, cacheWidth: 1200),
        Positioned(
          top: 8.h,
          right: 8.w,
          child: GestureDetector(
            onTap: () => widget.onChanged(null),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: EdgeInsets.all(6.r),
              decoration: const BoxDecoration(
                color: Color.fromRGBO(0, 0, 0, 0.45),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, size: 16.r, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
