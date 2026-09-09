/// Base URL of the Glamira API — the same backend the customer app uses; the
/// partner endpoints live under `/partner/auth`.
///
/// Defaults to the deployed backend on Render. For local development against a
/// backend on your machine, override with:
///   --dart-define=API_BASE_URL=http://localhost:8000
/// (On a physical Android device, set up an adb reverse tunnel so the device's
/// localhost maps to the dev machine: `adb reverse tcp:8000 tcp:8000`.)
String get apiBaseUrl {
  const override = String.fromEnvironment('API_BASE_URL');
  return override.isNotEmpty ? override : 'https://glamira-api.onrender.com';
}

/// Google OAuth **Web application** client id (from Google Cloud Console).
///
/// Passed to `google_sign_in` as the `serverClientId` so the ID token's
/// audience matches the backend's `GOOGLE_CLIENT_ID`. This is the same web
/// client the customer app uses — the backend verifies one audience for both.
///
/// Note the *Android* OAuth client is separate and per-package: signing in
/// from this app needs a client registered for `com.glamira.partner` plus the
/// signing SHA-1, or Play Services returns ApiException: 10.
const String googleServerClientId = String.fromEnvironment(
  'GOOGLE_SERVER_CLIENT_ID',
  defaultValue:
      '677033855501-pf739upd5tcb8kmmg9qepih1dmo2etqu.apps.googleusercontent.com',
);
