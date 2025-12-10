import 'package:hive/hive.dart';
import 'package:latlong2/latlong.dart';

/// Wrapper for LatLng to make it Hive-compatible
/// TypeId: 1
class LatLngCache extends HiveObject {
  final double latitude;
  final double longitude;

  LatLngCache({
    required this.latitude,
    required this.longitude,
  });

  factory LatLngCache.fromLatLng(LatLng latLng) {
    return LatLngCache(
      latitude: latLng.latitude,
      longitude: latLng.longitude,
    );
  }

  LatLng toLatLng() {
    return LatLng(latitude, longitude);
  }
}

/// TypeAdapter for LatLngCache
class LatLngCacheAdapter extends TypeAdapter<LatLngCache> {
  @override
  final int typeId = 1;

  @override
  LatLngCache read(BinaryReader reader) {
    return LatLngCache(
      latitude: reader.readDouble(),
      longitude: reader.readDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, LatLngCache obj) {
    writer.writeDouble(obj.latitude);
    writer.writeDouble(obj.longitude);
  }
}

/// Cached route geometry from OSRM with metadata
/// TypeId: 0
class RouteGeometry extends HiveObject {
  final String routeId;
  final int directionId;
  final List<LatLngCache> points;
  final DateTime cachedAt;
  final double? distance;
  final double? duration;

  RouteGeometry({
    required this.routeId,
    required this.directionId,
    required this.points,
    required this.cachedAt,
    this.distance,
    this.duration,
  });

  /// Check if cache is expired (30 days)
  bool get isExpired {
    final now = DateTime.now();
    return now.difference(cachedAt).inDays > 30;
  }

  /// Get cache key for storage
  String get cacheKey => 'route_${routeId}_dir$directionId';

  /// Convert to LatLng list for polyline
  List<LatLng> toLatLngList() {
    return points.map((p) => p.toLatLng()).toList();
  }
}

/// TypeAdapter for RouteGeometry
class RouteGeometryAdapter extends TypeAdapter<RouteGeometry> {
  @override
  final int typeId = 0;

  @override
  RouteGeometry read(BinaryReader reader) {
    final routeId = reader.readString();
    final directionId = reader.readInt();
    final pointsLength = reader.readInt();
    final points = <LatLngCache>[];

    for (int i = 0; i < pointsLength; i++) {
      points.add(LatLngCache(
        latitude: reader.readDouble(),
        longitude: reader.readDouble(),
      ));
    }

    final cachedAtMillis = reader.readInt();
    final cachedAt = DateTime.fromMillisecondsSinceEpoch(cachedAtMillis);

    // Read optional fields
    final hasDistance = reader.readBool();
    final distance = hasDistance ? reader.readDouble() : null;

    final hasDuration = reader.readBool();
    final duration = hasDuration ? reader.readDouble() : null;

    return RouteGeometry(
      routeId: routeId,
      directionId: directionId,
      points: points,
      cachedAt: cachedAt,
      distance: distance,
      duration: duration,
    );
  }

  @override
  void write(BinaryWriter writer, RouteGeometry obj) {
    writer.writeString(obj.routeId);
    writer.writeInt(obj.directionId);
    writer.writeInt(obj.points.length);

    for (final point in obj.points) {
      writer.writeDouble(point.latitude);
      writer.writeDouble(point.longitude);
    }

    writer.writeInt(obj.cachedAt.millisecondsSinceEpoch);

    // Write optional fields
    writer.writeBool(obj.distance != null);
    if (obj.distance != null) {
      writer.writeDouble(obj.distance!);
    }

    writer.writeBool(obj.duration != null);
    if (obj.duration != null) {
      writer.writeDouble(obj.duration!);
    }
  }
}
