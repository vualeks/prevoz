import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/bus_stop_cache.dart';
import '../models/route_at_stop.dart';
import '../models/unique_bus_stop.dart';
import '../utils/day_of_week.dart';

/// Service for querying bus stop data from cache
class BusStopQueryService {
  /// Find all routes that go through a specific bus stop
  ///
  /// Searches through all cached routes for the current day and finds
  /// which ones contain the specified stopId.
  ///
  /// Returns a sorted list of routes (by arrival time).
  Future<List<RouteAtStop>> findRoutesAtStop(String stopId) async {
    try {
      final stopsBox = Hive.box<BusStopCache>('bus_stops');
      final today = SerbianDayOfWeek.today;
      final routesAtStop = <RouteAtStop>[];

      // Iterate through all cached routes for today
      for (final key in stopsBox.keys) {
        final cacheKey = key.toString();

        // Only check today's data
        if (!cacheKey.endsWith('_${today.apiName}')) continue;

        final cache = stopsBox.get(cacheKey);
        if (cache == null || cache.isExpired) continue;

        // Search for the stop in this route's stops
        final matchingStop = cache.stops.firstWhere(
          (stop) => stop.stopId == stopId,
          orElse: () => cache.stops.first, // dummy
        );

        // If found (not dummy), add to results
        if (matchingStop.stopId == stopId) {
          routesAtStop.add(RouteAtStop.fromStopData(
            routeId: cache.routeId,
            directionId: cache.directionId,
            arrivalTime: matchingStop.arrivalTime,
            departureTime: matchingStop.departureTime,
          ));
        }
      }

      // Sort by arrival time for better UX
      routesAtStop.sort((a, b) {
        try {
          return a.arrivalTime.compareTo(b.arrivalTime);
        } catch (e) {
          return 0;
        }
      });

      debugPrint('Found ${routesAtStop.length} routes at stop $stopId');
      return routesAtStop;
    } catch (e) {
      debugPrint('Error finding routes at stop: $e');
      return [];
    }
  }

  /// Get a human-readable summary of routes at a stop
  String getRoutesSummary(List<RouteAtStop> routes) {
    if (routes.isEmpty) return 'No routes found';

    final uniqueRoutes = routes.map((r) => r.routeId).toSet();
    if (uniqueRoutes.length == 1) {
      return '1 route';
    }

    return '${uniqueRoutes.length} routes';
  }

  /// Get all unique bus stops from cached data
  ///
  /// Extracts all unique bus stops from the Hive cache for today's schedule.
  /// Returns a list of UniqueBusStop objects with aggregated data.
  Future<List<UniqueBusStop>> getAllUniqueStops() async {
    try {
      final stopsBox = Hive.box<BusStopCache>('bus_stops');
      final today = SerbianDayOfWeek.today;
      final uniqueStopsMap = <String, Map<String, dynamic>>{};

      // Iterate through all cached routes for today
      for (final key in stopsBox.keys) {
        final cacheKey = key.toString();

        // Only check today's data
        if (!cacheKey.endsWith('_${today.apiName}')) continue;

        final cache = stopsBox.get(cacheKey);
        if (cache == null || cache.isExpired) continue;

        // Process each stop in this route
        for (final stop in cache.stops) {
          if (uniqueStopsMap.containsKey(stop.stopId)) {
            // Increment route count for existing stop
            uniqueStopsMap[stop.stopId]!['routeCount'] =
                (uniqueStopsMap[stop.stopId]!['routeCount'] as int) + 1;
          } else {
            // Add new unique stop
            uniqueStopsMap[stop.stopId] = {
              'stopName': stop.stopName,
              'latitude': stop.latitude,
              'longitude': stop.longitude,
              'routeCount': 1,
            };
          }
        }
      }

      // Convert map to list of UniqueBusStop objects
      final uniqueStops = uniqueStopsMap.entries.map((entry) {
        return UniqueBusStop(
          stopId: entry.key,
          stopName: entry.value['stopName'] as String,
          latitude: entry.value['latitude'] as double,
          longitude: entry.value['longitude'] as double,
          routeCount: entry.value['routeCount'] as int,
        );
      }).toList();

      // Sort by stop name for consistency
      uniqueStops.sort((a, b) => a.stopName.compareTo(b.stopName));

      debugPrint('Found ${uniqueStops.length} unique bus stops');
      return uniqueStops;
    } catch (e) {
      debugPrint('Error getting all unique stops: $e');
      return [];
    }
  }
}
