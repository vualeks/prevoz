/// Represents a unique bus stop location with aggregated data
class UniqueBusStop {
  final String stopId;
  final String stopName;
  final double latitude;
  final double longitude;
  final int routeCount; // Number of routes that service this stop

  UniqueBusStop({
    required this.stopId,
    required this.stopName,
    required this.latitude,
    required this.longitude,
    required this.routeCount,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UniqueBusStop &&
          runtimeType == other.runtimeType &&
          stopId == other.stopId;

  @override
  int get hashCode => stopId.hashCode;

  @override
  String toString() {
    return 'UniqueBusStop(id: $stopId, name: $stopName, routes: $routeCount)';
  }
}
