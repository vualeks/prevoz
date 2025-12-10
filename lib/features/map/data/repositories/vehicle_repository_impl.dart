import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../datasources/vehicle_remote_datasource.dart';
import '../models/bus_stop.dart';
import '../models/vehicle.dart';

part 'vehicle_repository_impl.g.dart';

/// Implementation of VehicleRepository
class VehicleRepositoryImpl implements VehicleRepository {
  final VehicleRemoteDataSource _remoteDataSource;

  VehicleRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Vehicle>> getVehicles() async {
    return await _remoteDataSource.getVehicles();
  }

  @override
  Future<List<Vehicle>> getVehiclesByRoute(String routeName) async {
    return await _remoteDataSource.getVehiclesByRoute(routeName);
  }

  @override
  Future<List<BusStop>> getBusStops({
    required String routeId,
    required String dayOfWeek,
    required int directionId,
  }) async {
    return await _remoteDataSource.getBusStops(
      routeId: routeId,
      dayOfWeek: dayOfWeek,
      directionId: directionId,
    );
  }
}

/// Provider for VehicleRepository
@riverpod
VehicleRepository vehicleRepository(Ref ref) {
  final dataSource = ref.watch(vehicleRemoteDataSourceProvider);
  return VehicleRepositoryImpl(dataSource);
}
