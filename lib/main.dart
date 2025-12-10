import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'app/app.dart';
import 'core/models/route_geometry.dart';
import 'core/models/bus_stop_cache.dart';
import 'core/models/route_metadata.dart';

void main() async {
  // Ensure Flutter is initialized before Hive
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize FMTC with ObjectBox backend
  await FMTCObjectBoxBackend().initialise();

  // Initialize Hive for Flutter
  await Hive.initFlutter();

  // Register TypeAdapters
  Hive.registerAdapter(RouteGeometryAdapter()); // TypeId 0
  Hive.registerAdapter(LatLngCacheAdapter()); // TypeId 1
  Hive.registerAdapter(BusStopCacheAdapter()); // TypeId 2
  Hive.registerAdapter(RouteMetadataAdapter()); // TypeId 3

  // Open Hive boxes
  await Hive.openBox<RouteGeometry>('route_geometries');
  await Hive.openBox<BusStopCache>('bus_stops');
  await Hive.openBox<RouteMetadata>('route_metadata');

  runApp(
    const ProviderScope(
      child: PrevozApp(),
    ),
  );
}
