import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';
import '../../features/map/data/models/vehicle.dart';

/// Represents a single point in a vehicle's movement trail
class TrailPoint {
  final LatLng position;
  final DateTime timestamp;
  final double speed;

  TrailPoint({
    required this.position,
    required this.timestamp,
    required this.speed,
  });

  @override
  String toString() =>
      'TrailPoint(${position.latitude.toStringAsFixed(5)}, '
      '${position.longitude.toStringAsFixed(5)}, $speed km/h)';
}

/// Represents a vehicle's movement trail
class VehicleTrail {
  final String routeName;
  final List<TrailPoint> points;
  final DateTime lastSeen;

  VehicleTrail({
    required this.routeName,
    required this.points,
    required this.lastSeen,
  });

  /// Get the most recent position
  LatLng get currentPosition => points.first.position;

  /// Get the oldest position
  LatLng get oldestPosition => points.last.position;

  /// Check if the vehicle has moved significantly
  /// Returns true if ANY two consecutive points show movement
  bool get hasMoved {
    if (points.length < 2) return false;

    // Check each consecutive pair of points for movement
    for (int i = 0; i < points.length - 1; i++) {
      final distance = const Distance().distance(
        points[i].position,
        points[i + 1].position,
      );
      if (distance > 5) { // If any segment shows > 5m movement
        return true;
      }
    }

    return false;
  }

  /// Get bearing (direction) of movement in degrees (0-360)
  /// 0 = North, 90 = East, 180 = South, 270 = West
  double? get movementBearing {
    if (points.length < 2) return null;
    // Calculate bearing from second-to-last to last position
    // (most recent movement direction)
    final p1 = points[1].position;
    final p2 = points[0].position;

    final lat1 = p1.latitude * (3.14159 / 180);
    final lat2 = p2.latitude * (3.14159 / 180);
    final dLon = (p2.longitude - p1.longitude) * (3.14159 / 180);

    final y = sin(dLon) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    final bearing = atan2(y, x) * (180 / 3.14159);

    return (bearing + 360) % 360; // Normalize to 0-360
  }

  /// Create a copy with a new point added (keeps last 7 points)
  VehicleTrail addPoint(TrailPoint point) {
    final newPoints = [point, ...points];
    if (newPoints.length > 7) {
      newPoints.removeLast();
    }
    return VehicleTrail(
      routeName: routeName,
      points: newPoints,
      lastSeen: point.timestamp,
    );
  }

  /// Update only the lastSeen timestamp without adding a new point
  /// Used when vehicle hasn't moved significantly
  VehicleTrail updateTimestamp(DateTime timestamp) {
    return VehicleTrail(
      routeName: routeName,
      points: points,
      lastSeen: timestamp,
    );
  }

  @override
  String toString() =>
      'VehicleTrail(route: $routeName, points: ${points.length}, '
      'bearing: ${movementBearing?.toStringAsFixed(0)}°)';
}

/// Manages vehicle trails and matches new positions to existing trails
class VehicleTrailTracker {
  final Map<String, VehicleTrail> _trails = {};
  final Distance _distance = const Distance();

  /// Maximum age for a trail before it's considered stale (30 seconds)
  static const _maxTrailAge = Duration(seconds: 30);

  /// Maximum number of trails to keep in memory
  static const _maxTrails = 100;

  /// Get all active trails
  Map<String, VehicleTrail> get trails => Map.unmodifiable(_trails);

  /// Update trails with new vehicle positions
  /// Returns the updated trails map
  Map<String, VehicleTrail> updateTrails(List<Vehicle> vehicles) {
    final now = DateTime.now();

    // Clean up stale trails first
    _cleanupStaleTrails(now);

    int created = 0;

    // Process each vehicle
    for (final vehicle in vehicles) {
      final newPoint = TrailPoint(
        position: LatLng(vehicle.latitude, vehicle.longitude),
        timestamp: now,
        speed: vehicle.speed,
      );

      // Try to match to existing trail
      final matchedKey = _findMatchingTrail(vehicle, newPoint);

      if (matchedKey != null) {
        // Update existing trail
        final existingTrail = _trails[matchedKey]!;

        // Check if vehicle has moved significantly (>5m)
        final lastPosition = existingTrail.currentPosition;
        final distance = _distance.distance(lastPosition, newPoint.position);

        if (distance > 5) {
          // Vehicle moved - add new point to trail
          _trails[matchedKey] = existingTrail.addPoint(newPoint);
        } else {
          // Vehicle stationary - just update timestamp to prevent stale cleanup
          _trails[matchedKey] = existingTrail.updateTimestamp(now);
        }
      } else {
        // Create new trail
        final newKey = _generateTrailKey(vehicle, newPoint);
        _trails[newKey] = VehicleTrail(
          routeName: vehicle.routeName,
          points: [newPoint],
          lastSeen: now,
        );
        created++;
      }
    }

    // Enforce max trails limit
    _enforceMaxTrails();

    // Only log if there were new trails created (interesting event)
    if (created > 0) {
      debugPrint('Trails: ${_trails.length} total ($created new)');
    }

    return trails;
  }

  /// Find a matching trail for a vehicle based on proximity
  String? _findMatchingTrail(Vehicle vehicle, TrailPoint newPoint) {
    // Find all trails for this route
    final candidates = _trails.entries
        .where((e) => e.value.routeName == vehicle.routeName)
        .toList();

    if (candidates.isEmpty) return null;

    // Calculate distances and find closest
    String? closestKey;
    double closestDistance = double.infinity;

    for (final candidate in candidates) {
      final trail = candidate.value;
      final distance = _distance.distance(
        trail.currentPosition,
        newPoint.position,
      );

      // Calculate max expected distance based on speeds
      // Max distance = max(old speed, new speed) * 10 seconds + 50m buffer
      final maxSpeed =
          vehicle.speed > trail.points.first.speed
              ? vehicle.speed
              : trail.points.first.speed;
      final maxExpectedDistance =
          (maxSpeed / 3.6) * 10 + 50; // Convert km/h to m/s

      // Only consider if within expected range
      if (distance < maxExpectedDistance && distance < closestDistance) {
        closestDistance = distance;
        closestKey = candidate.key;
      }
    }

    return closestKey;
  }

  /// Generate a unique key for a new trail
  String _generateTrailKey(Vehicle vehicle, TrailPoint point) {
    // Use route + timestamp + position to create unique key
    final lat = point.position.latitude.toStringAsFixed(5);
    final lng = point.position.longitude.toStringAsFixed(5);
    return '${vehicle.routeName}_${point.timestamp.millisecondsSinceEpoch}_${lat}_$lng';
  }

  /// Remove trails that haven't been seen recently
  void _cleanupStaleTrails(DateTime now) {
    _trails.removeWhere((key, trail) {
      final age = now.difference(trail.lastSeen);
      final isStale = age > _maxTrailAge;
      if (isStale) {
        debugPrint('Removing stale trail: $key (age: ${age.inSeconds}s)');
      }
      return isStale;
    });
  }

  /// Enforce maximum number of trails
  void _enforceMaxTrails() {
    if (_trails.length <= _maxTrails) return;

    // Remove oldest trails
    final sortedEntries = _trails.entries.toList()
      ..sort((a, b) => a.value.lastSeen.compareTo(b.value.lastSeen));

    final toRemove = sortedEntries.take(_trails.length - _maxTrails);
    for (final entry in toRemove) {
      _trails.remove(entry.key);
    }

    debugPrint('Enforced max trails limit, removed ${toRemove.length} old trails');
  }

  /// Clear all trails
  void clear() {
    _trails.clear();
  }
}
