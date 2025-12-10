import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:latlong2/latlong.dart';
import '../models/route_geometry.dart';
import 'osrm_service.dart';

/// Service for managing route geometry cache with Hive
///
/// Implements a cache-first strategy:
/// 1. Check if route exists in cache and is not expired
/// 2. If cached → return immediately
/// 3. If not cached or expired → fetch from OSRM
/// 4. Save to cache
/// 5. Return route geometry
class RouteCacheService {
  final OsrmService _osrmService;
  late final Box<RouteGeometry> _cacheBox;

  RouteCacheService(this._osrmService) {
    _cacheBox = Hive.box<RouteGeometry>('route_geometries');
  }

  /// Get route geometry with caching
  ///
  /// [routeId] - The route identifier (e.g., "10", "11")
  /// [directionId] - Direction (0 or 1)
  /// [waypoints] - List of bus stop coordinates to route through
  ///
  /// Returns a list of LatLng points that follow actual roads.
  /// Throws exception if OSRM fails (caller should handle fallback).
  Future<List<LatLng>> getRouteGeometry({
    required String routeId,
    required int directionId,
    required List<LatLng> waypoints,
  }) async {
    final cacheKey = 'route_${routeId}_dir$directionId';

    // Check cache
    final cached = _cacheBox.get(cacheKey);
    if (cached != null && !cached.isExpired) {
      debugPrint('✓ Cache HIT for $cacheKey (${cached.points.length} points)');
      return cached.toLatLngList();
    }

    if (cached != null && cached.isExpired) {
      debugPrint('⚠ Cache EXPIRED for $cacheKey - refetching');
    } else {
      debugPrint('✗ Cache MISS for $cacheKey - fetching from OSRM');
    }

    // Fetch from OSRM
    try {
      final points = await _osrmService.getRouteGeometry(waypoints);

      // Save to cache
      final geometry = RouteGeometry(
        routeId: routeId,
        directionId: directionId,
        points: points.map((p) => LatLngCache.fromLatLng(p)).toList(),
        cachedAt: DateTime.now(),
      );

      await _cacheBox.put(cacheKey, geometry);
      debugPrint(
        '✓ Cached route geometry for $cacheKey (${points.length} points)',
      );

      return points;
    } catch (e) {
      debugPrint('✗ OSRM fetch failed for $cacheKey: $e');
      rethrow;
    }
  }

  /// Clear expired cache entries (older than 30 days)
  ///
  /// Useful for periodic cleanup to free disk space.
  /// Returns the number of entries deleted.
  Future<int> clearExpiredCache() async {
    final keys = _cacheBox.keys.toList();
    int deleted = 0;

    for (var key in keys) {
      final geometry = _cacheBox.get(key);
      if (geometry != null && geometry.isExpired) {
        await _cacheBox.delete(key);
        deleted++;
      }
    }

    debugPrint('Cleared $deleted expired cache entries');
    return deleted;
  }

  /// Clear all cache (for testing/debugging)
  ///
  /// Use with caution - will delete all cached route geometries.
  Future<void> clearAllCache() async {
    await _cacheBox.clear();
    debugPrint('Cleared all route geometry cache');
  }

  /// Get cache statistics
  ///
  /// Returns a map with:
  /// - total_entries: Total number of cached routes
  /// - expired_entries: Number of expired routes
  /// - active_entries: Number of valid cached routes
  Map<String, dynamic> getCacheStats() {
    final total = _cacheBox.length;
    final expired = _cacheBox.values.where((g) => g.isExpired).length;

    return {
      'total_entries': total,
      'expired_entries': expired,
      'active_entries': total - expired,
    };
  }
}
