import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/bus_stop.dart';
import '../models/realtime_arrival.dart';
import '../models/vehicle.dart';

part 'vehicle_remote_datasource.g.dart';

/// Remote data source for fetching vehicle data from the API
class VehicleRemoteDataSource {
  final Dio _dio;

  VehicleRemoteDataSource(this._dio);

  /// Fetches all vehicles currently in traffic
  Future<List<Vehicle>> getVehicles() async {
    try {
      final response = await _dio.get(ApiEndpoints.vehicles);

      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => Vehicle.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch vehicles: ${e.message}');
    }
  }

  /// Fetches vehicles for a specific route
  Future<List<Vehicle>> getVehiclesByRoute(String routeName) async {
    try {
      final vehicles = await getVehicles();
      return vehicles.where((v) => v.routeName == routeName).toList();
    } catch (e) {
      throw Exception('Failed to fetch vehicles for route $routeName: $e');
    }
  }

  /// Fetches bus stops for a specific route, day, and direction
  Future<List<BusStop>> getBusStops({
    required String routeId,
    required String dayOfWeek,
    required int directionId,
  }) async {
    try {
      final url = ApiEndpoints.busStopsByRoute(
        routeId: routeId,
        dayOfWeek: dayOfWeek,
        directionId: directionId,
      );

      final response = await _dio.get(url);

      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => BusStop.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch bus stops: ${e.message}');
    }
  }

  /// Fetches real-time arrival information for a specific bus stop
  Future<List<RealtimeArrival>> getRealtimeArrivals(String stopId) async {
    try {
      final url = ApiEndpoints.realtimeArrivalsByStop(stopId);
      final response = await _dio.get(url);

      final List<dynamic> data = response.data as List<dynamic>;
      return data
          .map((json) => RealtimeArrival.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception('Failed to fetch realtime arrivals: ${e.message}');
    }
  }
}

/// Provider for VehicleRemoteDataSource
@riverpod
VehicleRemoteDataSource vehicleRemoteDataSource(Ref ref) {
  final dio = ref.watch(dioProvider);
  return VehicleRemoteDataSource(dio);
}
