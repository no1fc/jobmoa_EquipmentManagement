class AppConfig {
  const AppConfig._();

  static const String appName = '잡모아 장비관리';
  static const String appVersion = '1.0.0';

  // API
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://58.151.241.130:4590',
  );
  static const String apiPrefix = '/api/v1';

  // Token
  static const int accessTokenExpiryMinutes = 30;
  static const int refreshTokenExpiryDays = 7;

  // Pagination
  static const int defaultPageSize = 20;

  // File Upload
  static const int maxImageSizeMB = 5;
  static const List<String> allowedImageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'webp',
  ];

  // Rental
  static const int maxRentalDays = 30;
  static const int maxExtensionDays = 14;
  static const int maxExtensionCount = 1;
}