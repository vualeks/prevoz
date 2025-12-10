import 'package:flutter/material.dart';

/// Route names mapping for Podgorica bus routes
/// Source: https://putevi.me/gradski-prevoz/aktuelni-red-voznje/
///
/// Note: API may return route IDs in different formats (e.g., "15|7" vs "L15/L7")
/// so we include multiple mappings for the same route.
const Map<String, String> routeNames = {
  '0': 'Zlatica - Zabjelo',
  '1': 'Botun - Masline',
  '1_B': 'Kakaricka Gora - Zabjelo',
  '1B': 'Kakaricka Gora - Zabjelo', // Alternative format
  '3': 'Trg Golootočkih žrtava – Tološi',
  '3A': 'Daljam-Sadine-KBC',
  '4': 'Konik - Tološi',
  '5': 'Konik - Gornja Gorica',
  '6': 'Stara Zlatica – City kvart',
  '6_A': 'Trg Golootočkih žrtava - Stara Zlatica',
  '6A': 'Trg Golootočkih žrtava - Stara Zlatica', // Alternative format
  '8/53': 'Stari Aerodrom (KIPS) – Beri',
  '8|53': 'Stari Aerodrom (KIPS) – Beri', // Alternative format (API uses |)
  '9': 'Zabjelo - Zagorič',
  '10': 'Zelenika - Doljani',
  '11': 'Autobuska stanica - Manastir Morača',
  '12': 'Autobuska stanica - Bioče',
  '13': 'Autobuska stanica - Veruša',
  'L15/L7': 'Stari Aerodrom - Mareza',
  '15|7': 'Stari Aerodrom - Mareza', // Alternative format (API uses |)
  '16': 'Trg Golootočkih žrtava - Dahna',
  '18': 'Zabjelo - Blok VI',
  '19': 'Konik - Blok VI',
  '20': 'Rogami - Kokoti',
  '21': 'Zabjelo - Zlatica - Smokovac',
  '23': 'Autobuska stanica - Spuž',
  '30': 'Autobuska stanica - Kuće Rakića',
  '38': 'Crveni krst (A) - Pričelje (B)',
  'L51/52': 'Autobuska S.-Buronji-Progonovići-Kamenica-Barutana',
  '51|52': 'Autobuska S.-Buronji-Progonovići-Kamenica-Barutana', // Alternative format (API uses |)
  '54_B': 'Berska ulica - Autobuska stanica',
  '54B': 'Berska ulica - Autobuska stanica', // Alternative format (API uses no underscore)
  '55': 'Trg Golootočkih žrtava - Grbavci',
  '62': 'Trg Golootočkih žrtava - Kuči',
};

/// Get the full name for a route
String getRouteName(String routeId) {
  return routeNames[routeId] ?? 'Linija $routeId';
}

/// Color scheme for bus routes
/// Uses consistent, vibrant colors that are easily distinguishable
/// Expanded palette to ensure no color repeats across all routes
class RouteColors {
  // Predefined color palette for routes (30+ distinct colors)
  static const List<Color> _palette = [
    Color(0xFF2196F3), // Blue
    Color(0xFFFF5722), // Deep Orange
    Color(0xFF4CAF50), // Green
    Color(0xFF9C27B0), // Purple
    Color(0xFFFF9800), // Orange
    Color(0xFF00BCD4), // Cyan
    Color(0xFFE91E63), // Pink
    Color(0xFF8BC34A), // Light Green
    Color(0xFF3F51B5), // Indigo
    Color(0xFFF44336), // Red
    Color(0xFF009688), // Teal
    Color(0xFFCDDC39), // Lime
    Color(0xFFFFC107), // Amber
    Color(0xFF673AB7), // Deep Purple
    Color(0xFF03A9F4), // Light Blue
    Color(0xFF795548), // Brown
    Color(0xFF607D8B), // Blue Grey
    Color(0xFFFF6F00), // Deep Orange Accent
    Color(0xFF1976D2), // Dark Blue
    Color(0xFFD32F2F), // Dark Red
    Color(0xFF388E3C), // Dark Green
    Color(0xFF7B1FA2), // Dark Purple
    Color(0xFF0288D1), // Dark Cyan
    Color(0xFFC2185B), // Dark Pink
    Color(0xFF689F38), // Olive Green
    Color(0xFF512DA8), // Deep Indigo
    Color(0xFFE64A19), // Burnt Orange
    Color(0xFF00796B), // Dark Teal
    Color(0xFFAFB42B), // Yellow Green
    Color(0xFFFF8F00), // Dark Amber
    Color(0xFF5E35B1), // Medium Purple
    Color(0xFF0277BD), // Ocean Blue
  ];

  /// Normalize route ID to canonical form for color consistency
  /// Ensures alternative formats (e.g., "15|7" vs "L15/L7") get the same color
  static String _normalizeRouteId(String routeId) {
    // Map alternative formats to canonical form
    const normalizationMap = {
      '15|7': 'L15/L7',
      '8|53': '8/53',
      '51|52': 'L51/52',
      '54B': '54_B',
      '1B': '1_B',
      '6A': '6_A',
    };
    return normalizationMap[routeId] ?? routeId;
  }

  /// Get a consistent color for a route ID
  /// Uses hash code to ensure same route always gets same color
  /// Alternative route formats (e.g., "15|7" and "L15/L7") get the same color
  static Color getColorForRoute(String routeId) {
    final normalized = _normalizeRouteId(routeId);
    final hash = normalized.hashCode.abs();
    return _palette[hash % _palette.length];
  }

  /// Get a darker shade of the route color for borders/accents
  static Color getDarkerColor(Color color) {
    return Color.fromARGB(
      (color.a * 255.0).round().clamp(0, 255),
      (color.r * 255.0 * 0.7).round().clamp(0, 255),
      (color.g * 255.0 * 0.7).round().clamp(0, 255),
      (color.b * 255.0 * 0.7).round().clamp(0, 255),
    );
  }
}
