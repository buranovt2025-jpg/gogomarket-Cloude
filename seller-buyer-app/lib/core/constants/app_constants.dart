class AppConstants {
  AppConstants._();

  // API
  static const String baseUrl = 'https://api.gogomarket.uz/v1';
  static const String wsUrl   = 'wss://api.gogomarket.uz';
  static const String cdnUrl  = 'https://cdn.gogomarket.uz';

  // Hive boxes
  static const String tokenBox   = 'token_box';
  static const String userBox    = 'user_box';
  static const String settingsBox = 'settings_box';
  static const String cartBox    = 'cart_box';

  // Hive keys
  static const String accessTokenKey  = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey         = 'user';
  static const String themeKey        = 'theme_mode';

  // Pagination
  static const int defaultPageSize = 20;
  static const int reelsPageSize   = 10;

  // Cache TTL (seconds)
  static const int productCacheTtl = 300;  // 5 min
  static const int feedCacheTtl    = 60;   // 1 min

  // OTP
  static const int otpLength  = 4;
  static const int otpTtl     = 60;

  // Seller limits (Basic plan)
  static const int basicMaxProducts = 20;
  static const int basicMaxReels    = 10;

  // Image limits
  static const int maxProductPhotos  = 10;
  static const int maxPhotoSizeMb    = 10;
  static const int maxVideoSizeMb    = 100;

  // Video reel
  static const int maxReelDurationSec = 60;
}
