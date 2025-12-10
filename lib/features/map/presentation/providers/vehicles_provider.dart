import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/bus_stop.dart';
import '../../data/models/vehicle.dart';
import '../../data/repositories/vehicle_repository_impl.dart';

part 'vehicles_provider.g.dart';

/// Provider that fetches all vehicles
/// Automatically refreshes and handles loading/error states
@riverpod
Future<List<Vehicle>> vehicles(Ref ref) async {
  final repository = ref.watch(vehicleRepositoryProvider);
  return await repository.getVehicles();
}

/// Provider that fetches vehicles for a specific route
@riverpod
Future<List<Vehicle>> vehiclesByRoute(
  Ref ref,
  String routeName,
) async {
  final repository = ref.watch(vehicleRepositoryProvider);
  return await repository.getVehiclesByRoute(routeName);
}

/// Provider that fetches bus stops for a specific route, day, and direction
@riverpod
Future<List<BusStop>> busStops(
  Ref ref, {
  required String routeId,
  required String dayOfWeek,
  required int directionId,
}) async {
  final repository = ref.watch(vehicleRepositoryProvider);
  return await repository.getBusStops(
    routeId: routeId,
    dayOfWeek: dayOfWeek,
    directionId: directionId,
  );
}
