/// API endpoint constants
class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://adminapi.prevoz.podgorica.me';

  // Endpoints
  static const String vehicles = '/api/dispatcher/vehicles/public';
  static const String busStops = '/api/gtfs/stops/by-route-day-direction';
  static const String realtimeArrivals = '/api/gtfs/display/realtime';

  // Helper methods
  static String vehicleByRoute(String routeName) => '$vehicles?route=$routeName';

  static String busStopsByRoute({
    required String routeId,
    required String dayOfWeek,
    required int directionId,
  }) =>
      '$busStops?routeId=$routeId&dayOfWeek=$dayOfWeek&directionId=$directionId';

  static String realtimeArrivalsByStop(String stopId) =>
      '$realtimeArrivals/$stopId';
}
