/// Map tile provider configuration (CARTO basemaps)
class MapTiles {
  MapTiles._();

  /// CARTO basemaps API key, provided at build time:
  /// `flutter run --dart-define-from-file=dart_defines.json`
  static const String cartoApiKey = String.fromEnvironment('CARTO_API_KEY');

  static const String urlTemplate =
      'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png?key=$cartoApiKey';

  static const List<String> subdomains = ['a', 'b', 'c', 'd'];

  /// FMTC store holding cached tiles
  static const String storeName = 'cartoTiles';

  /// Previous store, may contain "API KEY REQUIRED" placeholder tiles
  static const String legacyStoreName = 'mapStore';
}
