import 'package:hive/hive.dart';

/// Metadata about a cached route
/// TypeId: 3
class RouteMetadata extends HiveObject {
  final String routeId;
  final String routeName;
  final bool hasCachedGeometry;
  final bool hasCachedStops;
  final DateTime lastUpdated;

  RouteMetadata({
    required this.routeId,
    required this.routeName,
    required this.hasCachedGeometry,
    required this.hasCachedStops,
    required this.lastUpdated,
  });

  /// Check if route is fully cached
  bool get isFullyCached => hasCachedGeometry && hasCachedStops;

  /// Create a copy with updated fields
  RouteMetadata copyWith({
    String? routeId,
    String? routeName,
    bool? hasCachedGeometry,
    bool? hasCachedStops,
    DateTime? lastUpdated,
  }) {
    return RouteMetadata(
      routeId: routeId ?? this.routeId,
      routeName: routeName ?? this.routeName,
      hasCachedGeometry: hasCachedGeometry ?? this.hasCachedGeometry,
      hasCachedStops: hasCachedStops ?? this.hasCachedStops,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// TypeAdapter for RouteMetadata
class RouteMetadataAdapter extends TypeAdapter<RouteMetadata> {
  @override
  final int typeId = 3;

  @override
  RouteMetadata read(BinaryReader reader) {
    final routeId = reader.readString();
    final routeName = reader.readString();
    final hasCachedGeometry = reader.readBool();
    final hasCachedStops = reader.readBool();
    final lastUpdatedMillis = reader.readInt();
    final lastUpdated = DateTime.fromMillisecondsSinceEpoch(lastUpdatedMillis);

    return RouteMetadata(
      routeId: routeId,
      routeName: routeName,
      hasCachedGeometry: hasCachedGeometry,
      hasCachedStops: hasCachedStops,
      lastUpdated: lastUpdated,
    );
  }

  @override
  void write(BinaryWriter writer, RouteMetadata obj) {
    writer.writeString(obj.routeId);
    writer.writeString(obj.routeName);
    writer.writeBool(obj.hasCachedGeometry);
    writer.writeBool(obj.hasCachedStops);
    writer.writeInt(obj.lastUpdated.millisecondsSinceEpoch);
  }
}
