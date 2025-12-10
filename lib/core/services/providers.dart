import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../network/dio_client.dart';
import 'osrm_service.dart';
import 'route_cache_service.dart';
import 'preload_service.dart';
import 'bus_stop_query_service.dart';
import '../models/route_at_stop.dart';
import '../models/unique_bus_stop.dart';
import '../../features/map/data/repositories/vehicle_repository_impl.dart';

part 'providers.g.dart';

/// Provides OSRM service for route geometry fetching
@riverpod
OsrmService osrmService(Ref ref) {
  final dio = ref.watch(dioProvider);
  return OsrmService(dio);
}

/// Provides route cache service for managing OSRM route geometries
@riverpod
RouteCacheService routeCacheService(Ref ref) {
  final osrmService = ref.watch(osrmServiceProvider);
  return RouteCacheService(osrmService);
}

/// Provides preload service for first-launch data caching
@riverpod
PreloadService preloadService(Ref ref) {
  final vehicleRepo = ref.watch(vehicleRepositoryProvider);
  final routeCacheService = ref.watch(routeCacheServiceProvider);
  return PreloadService(vehicleRepo, routeCacheService);
}

/// Checks if preload is complete
@riverpod
Future<bool> isPreloadComplete(Ref ref) async {
  return await PreloadService.isPreloadComplete();
}

/// Provides bus stop query service for finding routes at stops
@riverpod
BusStopQueryService busStopQueryService(Ref ref) {
  return BusStopQueryService();
}

/// Finds all routes that go through a specific bus stop
@riverpod
Future<List<RouteAtStop>> routesAtStop(Ref ref, String stopId) async {
  final queryService = ref.watch(busStopQueryServiceProvider);
  return await queryService.findRoutesAtStop(stopId);
}

/// Gets all unique bus stops from cached data
@riverpod
Future<List<UniqueBusStop>> allBusStops(Ref ref) async {
  final queryService = ref.watch(busStopQueryServiceProvider);
  return await queryService.getAllUniqueStops();
}
