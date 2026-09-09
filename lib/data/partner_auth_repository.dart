import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../models/partner.dart';

/// Thrown for any auth failure, carrying a user-facing message (the API's
/// `detail` when available, otherwise a friendly fallback).
class PartnerAuthException implements Exception {
  PartnerAuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Talks to the Glamira API's `/partner/auth` endpoints and persists the JWT.
class PartnerAuthRepository {
  PartnerAuthRepository(this._dio, this._prefs);

  /// Namespaced so a partner token can never be confused with the customer
  /// app's, even though both apps write to their own sandboxed storage.
  static const _tokenKey = 'partner_auth_token';

  final Dio _dio;
  final SharedPreferences _prefs;

  String? get token => _prefs.getString(_tokenKey);
  bool get isLoggedIn => token != null;

  Future<Partner> signup({
    required String fullName,
    required String businessName,
    required String email,
    required String phoneNumber,
    required String address,
    required String password,
  }) async {
    final data = await _post('/partner/auth/signup', {
      'full_name': fullName.trim(),
      'business_name': businessName.trim(),
      'email': email.trim(),
      'phone_number': phoneNumber.trim(),
      'address': address.trim(),
      'password': password,
    });
    return _handleAuthSuccess(data);
  }

  Future<Partner> login({
    required String email,
    required String password,
  }) async {
    final data = await _post('/partner/auth/login', {
      'email': email.trim(),
      'password': password,
    });
    return _handleAuthSuccess(data);
  }

  /// Requests a reset code. The API always succeeds (it won't reveal whether
  /// the email exists), so this completes unless the network/server fails.
  Future<void> forgotPassword(String email) async {
    await _post('/partner/auth/forgot-password', {'email': email.trim()});
  }

  /// Completes a password reset with the emailed 6-digit code.
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await _post('/partner/auth/reset-password', {
      'email': email.trim(),
      'code': code.trim(),
      'new_password': newPassword,
    });
  }

  /// Signs in with Google. Note the partner endpoint only signs in an existing
  /// account — it never creates one, because a Google token carries no
  /// business name, phone number or address.
  Future<Partner> signInWithGoogle() async {
    final googleSignIn = _googleClient();
    try {
      final account = await googleSignIn.signIn();
      if (account == null) {
        throw PartnerAuthException('Google sign-in was cancelled.');
      }
      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null) {
        throw PartnerAuthException(
          'Could not get Google credentials. Check the app configuration.',
        );
      }
      final data = await _post('/partner/auth/google', {'id_token': idToken});
      return _handleAuthSuccess(data);
    } on PartnerAuthException {
      rethrow;
    } catch (_) {
      throw PartnerAuthException('Google sign-in failed. Please try again.');
    }
  }

  /// Fetches the signed-in partner's profile (`GET /partner/auth/me`).
  Future<Partner> getCurrentPartner() async {
    final t = token;
    if (t == null) throw PartnerAuthException('You are not signed in.');
    try {
      final res = await _dio.get(
        '/partner/auth/me',
        options: Options(headers: {'Authorization': 'Bearer $t'}),
      );
      return Partner.fromJson((res.data as Map).cast<String, dynamic>());
    } on DioException catch (e) {
      throw PartnerAuthException(_messageFor(e));
    }
  }

  Future<void> logout() async {
    await _prefs.remove(_tokenKey);
    // Also sign out of Google so the next "Google" tap shows the account
    // picker instead of silently reusing the last account.
    try {
      await _googleClient().signOut();
    } catch (_) {
      // No active Google session (or plugin error) — local logout still done.
    }
  }

  GoogleSignIn _googleClient() => GoogleSignIn(
        serverClientId:
            googleServerClientId.isEmpty ? null : googleServerClientId,
        scopes: const ['email', 'profile'],
      );

  Partner _handleAuthSuccess(Map<String, dynamic> data) {
    final token = data['access_token'] as String;
    _prefs.setString(_tokenKey, token);
    return Partner.fromJson(data['partner'] as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final res = await _dio.post(path, data: body);
      return (res.data as Map).cast<String, dynamic>();
    } on DioException catch (e) {
      throw PartnerAuthException(_messageFor(e));
    }
  }

  String _messageFor(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['detail'] is String) {
      return data['detail'] as String;
    }
    // FastAPI validation errors arrive as a list of {loc, msg, type}.
    if (data is Map && data['detail'] is List) {
      final first = (data['detail'] as List).firstOrNull;
      if (first is Map && first['msg'] is String) return first['msg'] as String;
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'The server took too long to respond. Please try again.';
      case DioExceptionType.connectionError:
        return 'Could not reach the server. Check your connection and try again.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
