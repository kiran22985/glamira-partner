/// Reusable form-field validators for the auth screens. Each returns `null`
/// when valid, or an error message to display under the field.
///
/// Kept in sync with the customer app's `lib/utils/validators.dart` so both
/// apps reject the same input.
class Validators {
  Validators._();

  static final RegExp _emailRe = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
  static final RegExp _phoneRe = RegExp(r'^\+?[0-9\s()-]{7,20}$');

  static String? requiredField(String? value, {String field = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$field is required.';
    return null;
  }

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email is required.';
    if (!_emailRe.hasMatch(v)) return 'Enter a valid email address.';
    return null;
  }

  static String? password(String? value, {int min = 8}) {
    if (value == null || value.isEmpty) return 'Password is required.';
    if (value.length < min) return 'Password must be at least $min characters.';
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Please confirm your password.';
    if (value != original) return 'Passwords do not match.';
    return null;
  }

  static String? phone(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Phone number is required.';
    if (!_phoneRe.hasMatch(v)) return 'Enter a valid phone number.';
    return null;
  }
}
