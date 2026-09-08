import 'package:flutter/material.dart';

/// Design tokens for the Glamira **Partner** app, taken from the Figma
/// "Partner Login" (54:2) and "Partner Sign Up" (54:50) frames.
///
/// Deliberately distinct from the customer app's palette: the partner brand is
/// a lighter mauve (#8C6373 vs #795465) and headings use Bodoni Moda rather
/// than Playfair Display.
class AppColors {
  AppColors._();

  /// Screen background.
  static const Color canvas = Color(0xFFFBF9F8);

  /// Primary action colour (buttons).
  static const Color brand = Color(0xFF8C6373);

  /// Text drawn on top of [brand] — the Login button's warm off-white.
  static const Color onBrand = Color(0xFFFFEFF3);

  /// Inline links: "Forgot Password?", "Sign Up", "Terms & Conditions".
  static const Color link = Color(0xFF714B5B);

  /// Headings and field labels.
  static const Color ink = Color(0xFF1B1C1C);

  /// Body / secondary text.
  static const Color body = Color(0xFF4F4447);

  /// Input, card and divider borders. Doubles as the input placeholder colour.
  static const Color border = Color(0xFFD3C2C7);

  /// Warm accent used by the sign-up screen's ambient background blob.
  static const Color gold = Color(0xFFFED65B);

  /// Hairline around content cards, and the onboarding artwork frame.
  static const Color cardBorder = Color(0xFFE4E2E2);

  /// Inactive onboarding progress dot (the active one uses [link]).
  static const Color dotInactive = cardBorder;

  /// Placeholder / helper text inside inputs on the Add Service form.
  static const Color hint = Color(0xFF817478);

  /// Fill of a selected category chip.
  static const Color chipSelected = Color(0xFFFFD8E5);
}
