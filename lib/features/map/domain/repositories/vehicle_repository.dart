import '../../data/models/bus_stop.dart';
import '../../data/models/vehicle.dart';

/// Repository interface for vehicle and bus stop operations
abstract class VehicleRepository {
  /// Fetches all vehicles currently in traffic
  Future<List<Vehicle>> getVehicles();

  /// Fetches vehicles for a specific route
  Future<List<Vehicle>> getVehiclesByRoute(String routeName);

  /// Fetches bus stops for a specific route, day, and direction
  Future<List<BusStop>> getBusStops({
    required String routeId,
    required String dayOfWeek,
    required int directionId,
  });
}
