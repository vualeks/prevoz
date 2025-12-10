# OSRM Routing with Hive Caching - Implementation Plan

## Overview
Replace straight-line route polylines with road-following geometry from OSRM (Open Source Routing Machine), cached locally using Hive for instant subsequent loads.

## Current State Analysis

### What We Have
- ✅ Straight-line polylines connecting bus stops in sequence
- ✅ Bus stops fetched from API with latitude/longitude
- ✅ Stop sequence ordering for correct route flow
- ✅ Two-direction support (direction 0 and 1)

### What We Need
- 🔲 OSRM API integration for road-following routes
- 🔲 Hive database for persistent caching
- 🔲 Route geometry model with Hive TypeAdapter
- 🔲 Fallback mechanism (OSRM fails → use straight lines)
- 🔲 Cache invalidation strategy (30-day expiry)

## OSRM API Investigation

### Endpoint Format
```
GET https://router.project-osrm.org/route/v1/driving/{coordinates}?overview=simplified&geometries=geojson
```

### Coordinates Format
Semicolon-separated `longitude,latitude` pairs:
```
lon1,lat1;lon2,lat2;lon3,lat3;...
```

**Example Request** (3 stops):
```
https://router.project-osrm.org/route/v1/driving/
  19.2594,42.4304;19.2650,42.4350;19.2700,42.4400
  ?overview=simplified&geometries=geojson
```

### Expected Response
```json
{
  "code": "Ok",
  "routes": [
    {
      "geometry": {
        "coordinates": [
          [19.2594, 42.4304],
          [19.2598, 42.4308],
          [19.2605, 42.4315],
          // ... many more points following roads
          [19.2700, 42.4400]
        ],
        "type": "LineString"
      },
      "distance": 1234.5,
      "duration": 123.4
    }
  ],
  "waypoints": [...]
}
```

### API Characteristics
- **Free**: No API key required
- **Rate limit**: ~5000 requests/hour (should be fine with caching)
- **Response time**: ~500ms - 2 seconds for city routes
- **Data source**: OpenStreetMap (updated regularly)
- **Reliability**: Public instance, 99%+ uptime

## Hive Setup

### Dependencies to Add
```yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.13  # Already in project
```

### Hive Initialization (in main.dart)
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(RouteGeometryAdapter());
  Hive.registerAdapter(LatLngCacheAdapter());

  // Open boxes
  await Hive.openBox<RouteGeometry>('route_geometries');

  runApp(const ProviderScope(child: PrevozApp()));
}
```

## Data Models

### RouteGeometry Model (with Hive annotations)
```dart
import 'package:hive/hive.dart';
import 'package:latlong2/latlong.dart';

part 'route_geometry.g.dart';

@HiveType(typeId: 0)
class RouteGeometry {
  @HiveField(0)
  final String routeId;

  @HiveField(1)
  final int directionId;

  @HiveField(2)
  final List<LatLngCache> points;

  @HiveField(3)
  final DateTime cachedAt;

  @HiveField(4)
  final double? distance;

  @HiveField(5)
  final double? duration;

  RouteGeometry({
    required this.routeId,
    required this.directionId,
    required this.points,
    required this.cachedAt,
    this.distance,
    this.duration,
  });

  /// Check if cache is expired (30 days)
  bool get isExpired {
    final now = DateTime.now();
    return now.difference(cachedAt).inDays > 30;
  }

  /// Get cache key for storage
  String get cacheKey => 'route_${routeId}_dir$directionId';

  /// Convert to LatLng list for polyline
  List<LatLng> toLatLngList() {
    return points.map((p) => LatLng(p.latitude, p.longitude)).toList();
  }
}

/// Wrapper for LatLng to make it Hive-compatible
@HiveType(typeId: 1)
class LatLngCache {
  @HiveField(0)
  final double latitude;

  @HiveField(1)
  final double longitude;

  LatLngCache({
    required this.latitude,
    required this.longitude,
  });

  factory LatLngCache.fromLatLng(LatLng latLng) {
    return LatLngCache(
      latitude: latLng.latitude,
      longitude: latLng.longitude,
    );
  }
}
```

## OSRM Service Implementation

### File: `lib/core/services/osrm_service.dart`
```dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import '../models/route_geometry.dart';

class OsrmService {
  final Dio _dio;
  static const String _baseUrl = 'https://router.project-osrm.org';

  OsrmService(this._dio);

  /// Fetch route geometry from OSRM
  /// Returns list of LatLng points following roads
  Future<List<LatLng>> getRouteGeometry(List<LatLng> waypoints) async {
    if (waypoints.length < 2) {
      throw ArgumentError('Need at least 2 waypoints for routing');
    }

    try {
      // Build coordinates string: lon,lat;lon,lat;...
      final coordinates = waypoints
          .map((point) => '${point.longitude},${point.latitude}')
          .join(';');

      final url = '$_baseUrl/route/v1/driving/$coordinates';

      final response = await _dio.get(
        url,
        queryParameters: {
          'overview': 'simplified',  // Simplified geometry (fewer points)
          'geometries': 'geojson',   // GeoJSON format
        },
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['code'] != 'Ok') {
          throw Exception('OSRM error: ${data['code']}');
        }

        final routes = data['routes'] as List;
        if (routes.isEmpty) {
          throw Exception('No routes found');
        }

        final geometry = routes[0]['geometry'];
        final coordinates = geometry['coordinates'] as List;

        // Convert to LatLng (OSRM returns [lon, lat] format)
        return coordinates
            .map((coord) => LatLng(coord[1] as double, coord[0] as double))
            .toList();
      } else {
        throw Exception('OSRM request failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('OSRM API error: $e');
      rethrow;
    }
  }
}
```

### OSRM Service Provider
```dart
// In lib/core/services/providers.dart (create if doesn't exist)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/dio_client.dart';
import 'osrm_service.dart';

final osrmServiceProvider = Provider<OsrmService>((ref) {
  final dio = ref.watch(dioProvider);
  return OsrmService(dio);
});
```

## Route Geometry Cache Service

### File: `lib/core/services/route_cache_service.dart`
```dart
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:latlong2/latlong.dart';
import '../models/route_geometry.dart';
import 'osrm_service.dart';

class RouteCacheService {
  final OsrmService _osrmService;
  late final Box<RouteGeometry> _cacheBox;

  RouteCacheService(this._osrmService) {
    _cacheBox = Hive.box<RouteGeometry>('route_geometries');
  }

  /// Get route geometry with caching
  /// 1. Check cache first
  /// 2. If not cached or expired, fetch from OSRM
  /// 3. Save to cache
  /// 4. Return geometry points
  Future<List<LatLng>> getRouteGeometry({
    required String routeId,
    required int directionId,
    required List<LatLng> waypoints,
  }) async {
    final cacheKey = 'route_${routeId}_dir$directionId';

    // Check cache
    final cached = _cacheBox.get(cacheKey);
    if (cached != null && !cached.isExpired) {
      debugPrint('✓ Cache HIT for $cacheKey');
      return cached.toLatLngList();
    }

    debugPrint('✗ Cache MISS for $cacheKey - fetching from OSRM');

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
      debugPrint('✓ Cached route geometry for $cacheKey (${points.length} points)');

      return points;
    } catch (e) {
      debugPrint('✗ OSRM fetch failed: $e');
      rethrow;
    }
  }

  /// Clear expired cache entries
  Future<void> clearExpiredCache() async {
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
  }

  /// Clear all cache (for testing/debugging)
  Future<void> clearAllCache() async {
    await _cacheBox.clear();
    debugPrint('Cleared all route geometry cache');
  }

  /// Get cache statistics
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
```

### Provider
```dart
// In lib/core/services/providers.dart
final routeCacheServiceProvider = Provider<RouteCacheService>((ref) {
  final osrmService = ref.watch(osrmServiceProvider);
  return RouteCacheService(osrmService);
});
```

## Integration into MapScreen

### Modified `_buildRoutePolyline` Method
```dart
Future<Polyline?> _buildRoutePolylineWithOSRM(
  List<BusStop> stops,
  Color color,
  String routeId,
  int directionId,
) async {
  if (stops.isEmpty) return null;

  // Sort by stopSequence to ensure correct order
  final sortedStops = List<BusStop>.from(stops)
    ..sort((a, b) => a.stopSequence.compareTo(b.stopSequence));

  // Extract waypoints (stop coordinates)
  final waypoints = sortedStops
      .map((stop) => LatLng(stop.latitude, stop.longitude))
      .toList();

  try {
    // Get route geometry from cache or OSRM
    final cacheService = ref.read(routeCacheServiceProvider);
    final routePoints = await cacheService.getRouteGeometry(
      routeId: routeId,
      directionId: directionId,
      waypoints: waypoints,
    );

    return Polyline(
      points: routePoints,
      strokeWidth: 4.0,
      color: color,
    );
  } catch (e) {
    debugPrint('Failed to get OSRM route, falling back to straight lines: $e');

    // Fallback to straight lines
    return Polyline(
      points: waypoints,
      strokeWidth: 4.0,
      color: color,
      isDotted: true,  // Visual indicator it's fallback
    );
  }
}
```

### Modified `_onBusTapped` Method
```dart
Future<void> _onBusTapped(String routeName) async {
  if (_selectedRoute == routeName) return;

  setState(() {
    _selectedRoute = routeName;
    _isLoadingRoute = true;
    _directionZeroStops = [];
    _directionOneStops = [];
    _directionZeroPolyline = null;  // NEW
    _directionOnePolyline = null;   // NEW
  });

  try {
    final day = SerbianDayOfWeek.today.apiName;

    // Fetch both directions in parallel
    final results = await Future.wait([
      ref.read(busStopsProvider(
        routeId: routeName,
        dayOfWeek: day,
        directionId: 0,
      ).future),
      ref.read(busStopsProvider(
        routeId: routeName,
        dayOfWeek: day,
        directionId: 1,
      ).future),
    ]);

    if (mounted) {
      final uniqueStopsDir0 = _getUniqueStops(results[0]);
      final uniqueStopsDir1 = _getUniqueStops(results[1]);

      // Build polylines with OSRM (in parallel)
      final polylines = await Future.wait([
        _buildRoutePolylineWithOSRM(
          uniqueStopsDir0,
          Colors.blue,
          routeName,
          0,
        ),
        _buildRoutePolylineWithOSRM(
          uniqueStopsDir1,
          Colors.orange,
          routeName,
          1,
        ),
      ]);

      if (mounted) {
        setState(() {
          _directionZeroStops = uniqueStopsDir0;
          _directionOneStops = uniqueStopsDir1;
          _directionZeroPolyline = polylines[0];  // NEW
          _directionOnePolyline = polylines[1];   // NEW
          _isLoadingRoute = false;
        });

        if (uniqueStopsDir0.isEmpty && uniqueStopsDir1.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No stops found for route $routeName'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    }
  } catch (e) {
    debugPrint('Error loading route: $e');
    if (mounted) {
      setState(() {
        _isLoadingRoute = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load route information: $e'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () => _onBusTapped(routeName),
          ),
        ),
      );
    }
  }
}
```

### State Variables to Add
```dart
// Add to MapScreen state
Polyline? _directionZeroPolyline;
Polyline? _directionOnePolyline;
```

### Updated PolylineLayer
```dart
// Route Polylines (shown when route is selected)
if (_selectedRoute != null) ...[
  PolylineLayer(
    polylines: [
      if (_directionZeroPolyline != null) _directionZeroPolyline!,
      if (_directionOnePolyline != null) _directionOnePolyline!,
    ].whereType<Polyline>().toList(),
  ),
],
```

## Implementation Phases

### Phase 1: Dependencies & Models ⏱️ ~30 min
1. Add Hive dependencies to pubspec.yaml
2. Run `flutter pub get`
3. Create `route_geometry.dart` model with Hive annotations
4. Run `flutter pub run build_runner build` to generate adapters
5. Verify generated files (`route_geometry.g.dart`)

### Phase 2: Hive Initialization ⏱️ ~15 min
1. Update `main.dart` with Hive initialization
2. Register adapters
3. Open route_geometries box
4. Test app launches without errors

### Phase 3: OSRM Service ⏱️ ~45 min
1. Create `osrm_service.dart`
2. Implement `getRouteGeometry()` method
3. Create provider
4. Test with sample coordinates (use Postman or browser first)
5. Add error handling and logging

### Phase 4: Cache Service ⏱️ ~1 hour
1. Create `route_cache_service.dart`
2. Implement cache get/set logic
3. Implement expiration checking
4. Implement cache stats/clearing utilities
5. Create provider
6. Add debug logging for cache hits/misses

### Phase 5: MapScreen Integration ⏱️ ~1 hour
1. Add state variables for polylines
2. Modify `_onBusTapped()` to build OSRM polylines
3. Update PolylineLayer rendering
4. Add fallback to straight lines (dotted)
5. Test on device with various routes

### Phase 6: Testing & Polish ⏱️ ~30 min
1. Run `flutter analyze`
2. Test cache hit/miss scenarios
3. Test OSRM failure fallback
4. Test expired cache handling
5. Verify memory usage is reasonable
6. Test offline behavior

**Total Estimated Time: ~4 hours**

## Testing Checklist

### Unit Tests
- [ ] RouteGeometry model serialization
- [ ] Cache expiration logic
- [ ] OSRM coordinate formatting

### Integration Tests
- [ ] OSRM API call with real coordinates
- [ ] Cache service saves and retrieves correctly
- [ ] Expired cache is detected and refetched

### Manual Device Tests
- [ ] First route load fetches from OSRM (check logs)
- [ ] Second route load uses cache (check logs)
- [ ] Route polylines follow roads visually
- [ ] Fallback to straight lines if OSRM fails (simulate by turning off WiFi)
- [ ] Different routes cache separately
- [ ] App restart preserves cache
- [ ] Routes load quickly from cache (<100ms)

## Error Handling Strategy

### OSRM API Failures
- **Network error**: Fallback to straight lines (dotted), show info snackbar
- **Invalid response**: Log error, fallback to straight lines
- **Timeout**: 10-second timeout, fallback to straight lines

### Cache Failures
- **Box not initialized**: Crash early with clear error (dev error)
- **Corrupted data**: Delete corrupted entry, refetch from OSRM
- **Disk full**: Unlikely, but handle gracefully

### Fallback Visual Indicators
- Straight lines use `isDotted: true` to indicate fallback mode
- Show subtle info message: "Route preview (detailed map unavailable)"

## Performance Considerations

### OSRM Request Optimization
- Use `overview=simplified` to reduce point count (~50-100 points vs 1000+)
- Batch waypoints (all stops in one request, not per-segment)
- 10-second timeout to prevent hanging

### Cache Performance
- Hive is fast (~1ms read time)
- Keep cache size reasonable (30-day expiry)
- Lazy box opening (only when needed)

### Memory Management
- Don't keep all route geometries in memory
- Load polylines on-demand when route selected
- Clear polylines when route deselected

## Future Enhancements

### V1 (This Implementation)
- ✅ Basic OSRM routing
- ✅ Hive caching with expiration
- ✅ Fallback to straight lines

### V2 (Future)
- Manual cache refresh option (pull-to-refresh cache)
- Cache preloading for all routes on startup
- Offline mode detection (skip OSRM if offline)
- Route color customization per route
- Route statistics (distance, duration from OSRM)

### V3 (Future)
- Alternative routing engines (GraphHopper, Valhalla)
- Route smoothing/simplification options
- Turn-by-turn navigation hints
- Traffic-aware routing (requires different API)

## Success Criteria

✅ Route polylines follow actual roads visually
✅ First load fetches from OSRM (~1-2 seconds)
✅ Subsequent loads instant from cache (<100ms)
✅ Cache persists across app restarts
✅ Graceful fallback if OSRM unavailable
✅ No performance degradation on map interactions
✅ `flutter analyze` passes with no warnings
✅ Works offline with cached routes
