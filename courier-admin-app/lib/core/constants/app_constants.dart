class AppConstants {
  AppConstants._();
  static const String baseUrl     = 'https://api.gogomarket.uz/v1';
  static const String wsUrl       = 'wss://api.gogomarket.uz';
  static const String tokenBox    = 'token_box';
  static const String userBox     = 'user_box';
  static const String accessTokenKey  = 'access_token';
  static const String refreshTokenKey = 'refresh_token';

  // GPS update interval (courier)
  static const int gpsIntervalMs = 5000;

  // Map defaults (Tashkent)
  static const double defaultLat = 41.2995;
  static const double defaultLng = 69.2401;
  static const double defaultZoom = 13.0;
}
