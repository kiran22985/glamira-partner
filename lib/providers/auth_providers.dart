import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../data/partner_auth_repository.dart';

/// Overridden in `main()` with the loaded instance.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider not overridden'),
);

final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      contentType: 'application/json',
    ),
  );
});

final partnerAuthRepositoryProvider = Provider<PartnerAuthRepository>((ref) {
  return PartnerAuthRepository(
    ref.watch(dioProvider),
    ref.watch(sharedPreferencesProvider),
  );
});

/// Reactive "is the partner signed in" flag. Call `refresh()` after a
/// successful login/signup or a logout so the widget tree re-renders.
final authStateProvider =
    NotifierProvider<AuthStateNotifier, bool>(AuthStateNotifier.new);

class AuthStateNotifier extends Notifier<bool> {
  @override
  bool build() => ref.read(partnerAuthRepositoryProvider).isLoggedIn;

  void refresh() =>
      state = ref.read(partnerAuthRepositoryProvider).isLoggedIn;
}

/// Whether the onboarding slides have been seen on this device.
const String kHasSeenOnboardingKey = 'partner_has_seen_onboarding';

final onboardingSeenProvider =
    NotifierProvider<OnboardingSeenNotifier, bool>(OnboardingSeenNotifier.new);

class OnboardingSeenNotifier extends Notifier<bool> {
  @override
  bool build() =>
      ref.read(sharedPreferencesProvider).getBool(kHasSeenOnboardingKey) ??
      false;

  Future<void> markSeen() async {
    await ref
        .read(sharedPreferencesProvider)
        .setBool(kHasSeenOnboardingKey, true);
    state = true;
  }
}
