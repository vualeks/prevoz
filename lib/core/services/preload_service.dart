import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hive/hive.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bus_stop_cache.dart';
import '../models/route_geometry.dart';
import '../models/route_metadata.dart';
import '../utils/day_of_week.dart';
import '../utils/route_constants.dart';
import '../../features/preload/domain/models/preload_progress.dart';
import '../../features/map/domain/repositories/vehicle_repository.dart';
import 'route_cache_service.dart';

/// Service for preloading and caching all app data on first launch
class PreloadService {
  final VehicleRepository _vehicleRepository;
  final RouteCacheService _routeCacheService;

  // Progress stream for UI updates
  final StreamController<PreloadProgress> _progressController =
      StreamController<PreloadProgress>.broadcast();

  Stream<PreloadProgress> get progressStream => _progressController.stream;

  // Podgorica bounds for tile download
  static final _podgoricaBounds = LatLngBounds(
    LatLng(42.35, 19.15), // Southwest
    LatLng(42.50, 19.35), // Northeast
  );

  PreloadService(this._vehicleRepository, this._routeCacheService);

  /// Execute the complete preload process
  Future<void> executePreload() async {
    try {
      debugPrint('🚀 Starting preload process...');

      // Step 1: Download map tiles (35% of total)
      await _downloadMapTiles();

      // Step 2: Fetch and cache all routes (20% of total)
      await _cacheAllRoutes();

      // Step 3: Cache bus stops for all routes (25% of total)
      await _cacheAllBusStops();

      // Step 4: Cache route geometries from OSRM (20% of total)
      await _cacheAllRouteGeometries();

      // Mark preload as complete
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('preload_completed', true);

      _progressController.add(PreloadProgress.completed());
      debugPrint('✅ Preload completed successfully!');
    } catch (e, stackTrace) {
      debugPrint('❌ Preload failed: $e');
      debugPrint('Stack trace: $stackTrace');
      _progressController.addError(e, stackTrace);
    }
  }

  /// Step 1: Download map tiles for Podgorica area
  Future<void> _downloadMapTiles() async {
    debugPrint('📍 Step 1: Downloading map tiles...');

    try {
      // Initialize FMTC store
      final store = FMTCStore('mapStore');
      await store.manage.create();

      // Define region to download
      final region = RectangleRegion(_podgoricaBounds);

      final downloadable = region.toDownloadable(
        minZoom: 10,
        maxZoom: 16,
        options: TileLayer(
          urlTemplate:
              'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
        ),
      );

      // Start download with progress tracking
      final download = store.download.startForeground(
        region: downloadable,
        parallelThreads: 10,
      );

      await for (final progress in download.downloadProgress) {
        final percentProgress = progress.percentageProgress / 100;

        _progressController.add(PreloadProgress(
          currentStep: PreloadStep.downloadingTiles,
          stepProgress: percentProgress,
          totalProgress: percentProgress * 0.35,
          message: 'Downloading map tiles...',
        ));

        // Log every 25%
        if (progress.percentageProgress % 25 == 0 && progress.percentageProgress > 0) {
          debugPrint('  Map tiles: ${progress.percentageProgress.toInt()}%');
        }
      }

      debugPrint('✓ Map tiles downloaded');
    } catch (e) {
      debugPrint('⚠ Map tiles download failed: $e');
      // Don't throw - tiles can be downloaded later
      // Still report 35% progress to continue
      _progressController.add(const PreloadProgress(
        currentStep: PreloadStep.downloadingTiles,
        stepProgress: 1.0,
        totalProgress: 0.35,
        message: 'Map tiles skipped (will download later)',
      ));
    }
  }

  /// Step 2: Cache all route metadata
  Future<void> _cacheAllRoutes() async {
    debugPrint('🚌 Step 2: Caching routes...');

    final allRouteIds = routeNames.keys.toList();
    final metadataBox = Hive.box<RouteMetadata>('route_metadata');

    for (int i = 0; i < allRouteIds.length; i++) {
      final routeId = allRouteIds[i];
      final routeName = getRouteName(routeId);

      // Store route metadata
      final metadata = RouteMetadata(
        routeId: routeId,
        routeName: routeName,
        hasCachedGeometry: false,
        hasCachedStops: false,
        lastUpdated: DateTime.now(),
      );

      await metadataBox.put(routeId, metadata);

      _progressController.add(PreloadProgress(
        currentStep: PreloadStep.cachingRoutes,
        stepProgress: (i + 1) / allRouteIds.length,
        totalProgress: 0.35 + ((i + 1) / allRouteIds.length) * 0.20,
        message: 'Loading route $routeName...',
        itemsDone: i + 1,
        itemsTotal: allRouteIds.length,
      ));
    }

    debugPrint('✓ Cached ${allRouteIds.length} routes');
  }

  /// Step 3: Cache bus stops for current day only (optimized for fast first launch)
  Future<void> _cacheAllBusStops() async {
    debugPrint('📍 Step 3: Caching bus stops for today...');

    final allRouteIds = routeNames.keys.toList();
    final directions = [0, 1];
    final today = SerbianDayOfWeek.today;

    final stopsBox = Hive.box<BusStopCache>('bus_stops');
    final metadataBox = Hive.box<RouteMetadata>('route_metadata');

    final total = allRouteIds.length * directions.length;
    int done = 0;
    int successCount = 0;


    for (final routeId in allRouteIds) {
      bool hasAnyStops = false;

      for (final direction in directions) {
        try {
          final stops = await _vehicleRepository.getBusStops(
            routeId: routeId,
            dayOfWeek: today.apiName,
            directionId: direction,
          );

          if (stops.isNotEmpty) {
            hasAnyStops = true;

            // Store in Hive
            final cacheKey =
                'route_${routeId}_dir${direction}_${today.apiName}';
            final cache = BusStopCache(
              routeId: routeId,
              directionId: direction,
              dayOfWeek: today.apiName,
              stops: stops.map((s) => BusStopData.fromBusStop(s)).toList(),
              cachedAt: DateTime.now(),
            );

            await stopsBox.put(cacheKey, cache);
            successCount++;
          }
        } catch (e) {
          // Skip if route/direction doesn't exist for this day
        }

        done++;

        // Update progress every 5 requests to avoid flooding
        if (done % 5 == 0 || done == total) {
          _progressController.add(PreloadProgress(
            currentStep: PreloadStep.cachingStops,
            stepProgress: done / total,
            totalProgress: 0.55 + (done / total) * 0.25,
            message: 'Loading stops for route $routeId...',
            itemsDone: done,
            itemsTotal: total,
          ));
        }
      }

      // Update route metadata to mark stops as cached
      if (hasAnyStops) {
        final metadata = metadataBox.get(routeId);
        if (metadata != null) {
          await metadataBox.put(
            routeId,
            metadata.copyWith(hasCachedStops: true),
          );
        }
      }
    }

    debugPrint('✓ Cached $successCount bus stop sets for ${today.apiName}');
  }

  /// Step 4: Cache route geometries from OSRM
  Future<void> _cacheAllRouteGeometries() async {
    debugPrint('🗺️  Step 4: Caching route geometries...');

    final allRouteIds = routeNames.keys.toList();
    final directions = [0, 1];
    final stopsBox = Hive.box<BusStopCache>('bus_stops');
    final metadataBox = Hive.box<RouteMetadata>('route_metadata');

    final total = allRouteIds.length * directions.length;
    int done = 0;
    int successCount = 0;

    for (final routeId in allRouteIds) {
      bool hasAnyGeometry = false;

      for (final direction in directions) {
        try {
          // Try to get stops from cache for today to extract waypoints
          final today = SerbianDayOfWeek.today;
          final cacheKey =
              'route_${routeId}_dir${direction}_${today.apiName}';
          final cached = stopsBox.get(cacheKey);

          if (cached != null && cached.stops.isNotEmpty) {
            final waypoints = cached.stops
                .map((s) => LatLng(s.latitude, s.longitude))
                .toList();

            // This will fetch from OSRM and cache via RouteCacheService
            await _routeCacheService.getRouteGeometry(
              routeId: routeId,
              directionId: direction,
              waypoints: waypoints,
            );

            hasAnyGeometry = true;
            successCount++;
          }
        } catch (e) {
          // Skip if geometry fetch fails
        }

        done++;

        _progressController.add(PreloadProgress(
          currentStep: PreloadStep.cachingGeometries,
          stepProgress: done / total,
          totalProgress: 0.80 + (done / total) * 0.20,
          message: 'Mapping route $routeId...',
          itemsDone: done,
          itemsTotal: total.toInt(),
        ));
      }

      // Update route metadata to mark geometry as cached
      if (hasAnyGeometry) {
        final metadata = metadataBox.get(routeId);
        if (metadata != null) {
          await metadataBox.put(
            routeId,
            metadata.copyWith(hasCachedGeometry: true),
          );
        }
      }
    }

    debugPrint('✓ Cached $successCount route geometries');
  }

  /// Check if preload has been completed
  static Future<bool> isPreloadComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasCompletedFlag = prefs.getBool('preload_completed') ?? false;

      if (!hasCompletedFlag) {
        return false;
      }

      // Verify data actually exists (use typed boxes)
      final routeGeometriesBox = Hive.box<RouteGeometry>('route_geometries');
      final busStopsBox = Hive.box<BusStopCache>('bus_stops');
      final routeMetadataBox = Hive.box<RouteMetadata>('route_metadata');

      final hasRouteGeometries = routeGeometriesBox.isNotEmpty;
      final hasBusStops = busStopsBox.isNotEmpty;
      final hasRouteMetadata = routeMetadataBox.isNotEmpty;

      final isComplete = hasRouteGeometries && hasBusStops && hasRouteMetadata;

      if (!isComplete) {
        debugPrint('⚠️  Preload incomplete: geometries=$hasRouteGeometries, stops=$hasBusStops, metadata=$hasRouteMetadata');
      }

      return isComplete;
    } catch (e) {
      debugPrint('❌ Error checking preload status: $e');
      return false;
    }
  }

  /// Check if we have cached data for today
  static Future<bool> hasTodaysData() async {
    try {
      final stopsBox = Hive.box<BusStopCache>('bus_stops');
      final today = SerbianDayOfWeek.today;

      // Check if we have at least some stops for today
      final todaysKeys = stopsBox.keys.where((key) {
        return key.toString().endsWith('_${today.apiName}');
      });

      final hasTodayStops = todaysKeys.isNotEmpty;

      if (!hasTodayStops) {
        debugPrint('📅 No cached data for ${today.apiName}, will refresh');
      }

      return hasTodayStops;
    } catch (e) {
      debugPrint('❌ Error checking today\'s data: $e');
      return false;
    }
  }

  /// Refresh data for current day (fast background update)
  Future<void> refreshTodaysData() async {
    debugPrint('🔄 Refreshing data for today...');

    try {
      final today = SerbianDayOfWeek.today;
      final allRouteIds = routeNames.keys.toList();
      final directions = [0, 1];
      final stopsBox = Hive.box<BusStopCache>('bus_stops');

      int updated = 0;

      for (final routeId in allRouteIds) {
        for (final direction in directions) {
          try {
            final stops = await _vehicleRepository.getBusStops(
              routeId: routeId,
              dayOfWeek: today.apiName,
              directionId: direction,
            );

            if (stops.isNotEmpty) {
              final cacheKey =
                  'route_${routeId}_dir${direction}_${today.apiName}';
              final cache = BusStopCache(
                routeId: routeId,
                directionId: direction,
                dayOfWeek: today.apiName,
                stops: stops.map((s) => BusStopData.fromBusStop(s)).toList(),
                cachedAt: DateTime.now(),
              );

              await stopsBox.put(cacheKey, cache);
              updated++;
            }
          } catch (e) {
            // Skip if route/direction doesn't exist
          }
        }
      }

      debugPrint('✓ Refreshed $updated bus stop sets for ${today.apiName}');
    } catch (e) {
      debugPrint('✗ Failed to refresh today\'s data: $e');
    }
  }

  /// Reset preload status (for testing or re-caching)
  static Future<void> resetPreloadStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('preload_completed', false);

    // Optionally clear all caches (use typed boxes)
    await Hive.box<RouteGeometry>('route_geometries').clear();
    await Hive.box<BusStopCache>('bus_stops').clear();
    await Hive.box<RouteMetadata>('route_metadata').clear();

    debugPrint('🔄 Preload status reset');
  }

  /// Dispose resources
  void dispose() {
    _progressController.close();
  }
}
