class ApiEndpoints {
  const ApiEndpoints._();

  static const String prefix = '/api/v1';

  // Auth
  static const String login = '$prefix/auth/login';
  static const String refresh = '$prefix/auth/refresh';
  static const String logout = '$prefix/auth/logout';

  // Users
  static const String users = '$prefix/users';
  static String user(int id) => '$prefix/users/$id';
  static const String myProfile = '$prefix/users/me';
  static const String myPassword = '$prefix/users/me/password';

  // Categories
  static const String categories = '$prefix/categories';
  static const String categoryTree = '$prefix/categories/tree';
  static String category(int id) => '$prefix/categories/$id';
  static String categoryChildren(int id) => '$prefix/categories/$id/children';

  // Assets
  static const String assets = '$prefix/assets';
  static String asset(int id) => '$prefix/assets/$id';
  static String assetStatus(int id) => '$prefix/assets/$id/status';
  static const String assetSummary = '$prefix/assets/summary';

  // Rentals
  static const String rentals = '$prefix/rentals';
  static String rental(int id) => '$prefix/rentals/$id';
  static String rentalReturn(int id) => '$prefix/rentals/$id/return';
  static String rentalExtend(int id) => '$prefix/rentals/$id/extend';
  static String rentalCancel(int id) => '$prefix/rentals/$id/cancel';
  static const String rentalDashboard = '$prefix/rentals/dashboard';
  static const String rentalOverdue = '$prefix/rentals/overdue';
  static String rentalHistory(int assetId) =>
      '$prefix/rentals/asset/$assetId/history';

  // Notifications
  static const String notifications = '$prefix/notifications';
  static const String unreadCount = '$prefix/notifications/unread-count';
  static String notificationRead(int id) => '$prefix/notifications/$id/read';
  static const String notificationReadAll = '$prefix/notifications/read-all';
}