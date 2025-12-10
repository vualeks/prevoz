/// Application-wide constants
class AppConstants {
  AppConstants._();

  // Map Configuration
  static const double defaultMapZoom = 14.0;
  static const double minMapZoom = 10.0;
  static const double maxMapZoom = 18.0;

  // Podgorica center coordinates
  static const double podgoricaLat = 42.4304;
  static const double podgoricaLng = 19.2594;

  // Refresh intervals
  static const Duration busLocationRefreshInterval = Duration(seconds: 15);
  static const Duration stationRefreshInterval = Duration(minutes: 5);

  // API Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);

  // Storage Keys
  static const String favoritesKey = 'favorites';
  static const String themeKey = 'theme_mode';
}
