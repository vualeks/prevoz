import 'package:hive/hive.dart';
import '../../features/map/data/models/bus_stop.dart';

/// Embedded bus stop data for caching
class BusStopData {
  final int id;
  final String stopId;
  final String stopName;
  final String arrivalTime;
  final String departureTime;
  final double latitude;
  final double longitude;
  final int stopSequence;
  final int stopTimeId;

  BusStopData({
    required this.id,
    required this.stopId,
    required this.stopName,
    required this.arrivalTime,
    required this.departureTime,
    required this.latitude,
    required this.longitude,
    required this.stopSequence,
    required this.stopTimeId,
  });

  factory BusStopData.fromBusStop(BusStop stop) {
    return BusStopData(
      id: stop.id,
      stopId: stop.stopId,
      stopName: stop.stopName,
      arrivalTime: stop.arrivalTime,
      departureTime: stop.departureTime,
      latitude: stop.latitude,
      longitude: stop.longitude,
      stopSequence: stop.stopSequence,
      stopTimeId: stop.stopTimeId,
    );
  }

  BusStop toBusStop() {
    return BusStop(
      id: id,
      stopId: stopId,
      stopName: stopName,
      arrivalTime: arrivalTime,
      departureTime: departureTime,
      latitude: latitude,
      longitude: longitude,
      stopSequence: stopSequence,
      stopTimeId: stopTimeId,
    );
  }
}

/// Cached bus stops for a specific route, direction, and day
/// TypeId: 2
class BusStopCache extends HiveObject {
  final String routeId;
  final int directionId;
  final String dayOfWeek;
  final List<BusStopData> stops;
  final DateTime cachedAt;

  BusStopCache({
    required this.routeId,
    required this.directionId,
    required this.dayOfWeek,
    required this.stops,
    required this.cachedAt,
  });

  /// Check if cache is expired (30 days)
  bool get isExpired {
    final now = DateTime.now();
    return now.difference(cachedAt).inDays > 30;
  }

  /// Get cache key for storage
  String get cacheKey => 'route_${routeId}_dir${directionId}_$dayOfWeek';

  /// Convert to BusStop list
  List<BusStop> toBusStopList() {
    return stops.map((s) => s.toBusStop()).toList();
  }
}

/// TypeAdapter for BusStopCache
class BusStopCacheAdapter extends TypeAdapter<BusStopCache> {
  @override
  final int typeId = 2;

  @override
  BusStopCache read(BinaryReader reader) {
    final routeId = reader.readString();
    final directionId = reader.readInt();
    final dayOfWeek = reader.readString();
    final cachedAtMillis = reader.readInt();
    final cachedAt = DateTime.fromMillisecondsSinceEpoch(cachedAtMillis);

    final stopsLength = reader.readInt();
    final stops = <BusStopData>[];

    for (int i = 0; i < stopsLength; i++) {
      stops.add(BusStopData(
        id: reader.readInt(),
        stopId: reader.readString(),
        stopName: reader.readString(),
        arrivalTime: reader.readString(),
        departureTime: reader.readString(),
        latitude: reader.readDouble(),
        longitude: reader.readDouble(),
        stopSequence: reader.readInt(),
        stopTimeId: reader.readInt(),
      ));
    }

    return BusStopCache(
      routeId: routeId,
      directionId: directionId,
      dayOfWeek: dayOfWeek,
      stops: stops,
      cachedAt: cachedAt,
    );
  }

  @override
  void write(BinaryWriter writer, BusStopCache obj) {
    writer.writeString(obj.routeId);
    writer.writeInt(obj.directionId);
    writer.writeString(obj.dayOfWeek);
    writer.writeInt(obj.cachedAt.millisecondsSinceEpoch);

    writer.writeInt(obj.stops.length);
    for (final stop in obj.stops) {
      writer.writeInt(stop.id);
      writer.writeString(stop.stopId);
      writer.writeString(stop.stopName);
      writer.writeString(stop.arrivalTime);
      writer.writeString(stop.departureTime);
      writer.writeDouble(stop.latitude);
      writer.writeDouble(stop.longitude);
      writer.writeInt(stop.stopSequence);
      writer.writeInt(stop.stopTimeId);
    }
  }
}
