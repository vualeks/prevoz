import 'package:flutter/material.dart';
import '../utils/route_constants.dart';

/// Represents a route that services a specific bus stop
class RouteAtStop {
  final String routeId;
  final String routeName;
  final int directionId;
  final String arrivalTime;
  final String departureTime;
  final Color color;

  RouteAtStop({
    required this.routeId,
    required this.routeName,
    required this.directionId,
    required this.arrivalTime,
    required this.departureTime,
    required this.color,
  });

  /// Get direction label (0 → "Direction 1", 1 → "Direction 2")
  String get directionLabel => 'Direction ${directionId + 1}';

  /// Get formatted time string
  String get timeRange => '$arrivalTime - $departureTime';

  /// Factory constructor for easy creation
  factory RouteAtStop.fromStopData({
    required String routeId,
    required int directionId,
    required String arrivalTime,
    required String departureTime,
  }) {
    return RouteAtStop(
      routeId: routeId,
      routeName: getRouteName(routeId),
      directionId: directionId,
      arrivalTime: arrivalTime,
      departureTime: departureTime,
      color: RouteColors.getColorForRoute(routeId),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RouteAtStop &&
          runtimeType == other.runtimeType &&
          routeId == other.routeId &&
          directionId == other.directionId;

  @override
  int get hashCode => routeId.hashCode ^ directionId.hashCode;
}
