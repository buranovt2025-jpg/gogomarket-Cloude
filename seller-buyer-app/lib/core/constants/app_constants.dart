class AppConstants {
  AppConstants._();

  // API — prod server
  static const String baseUrl  = 'http://206.189.12.56/api';
  static const String wsUrl    = 'ws://206.189.12.56';
  static const String cdnUrl   = 'http://206.189.12.56';

  // Dev override (comment out in prod)
  // static const String baseUrl = 'http://10.0.2.2:3000';

  // Hive boxes
  static const String tokenBox    = 'token_box';
  static const String userBox     = 'user_box';
  static const String settingsBox = 'settings_box';
  static const String cartBox     = 'cart_box';

  // Hive keys
  static const String accessTokenKey  = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey         = 'user';
  static const String themeKey        = 'theme_mode';

  // Pagination
  static const int defaultPageSize = 20;
  static const int reelsPageSize   = 10;

  // Cache TTL (seconds)
  static const int productCacheTtl = 300;
  static const int feedCacheTtl    = 60;

  // OTP
  static const int otpLength = 4;
  static const int otpTtl    = 60;

  // Seller limits (Basic plan)
  static const int basicMaxProducts = 20;
  static const int basicMaxReels    = 10;

  // Media limits
  static const int maxProductPhotos   = 10;
  static const int maxPhotoSizeMb     = 10;
  static const int maxVideoSizeMb     = 100;
  static const int maxReelDurationSec = 60;
}
