import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/services/preload_service.dart';
import '../../../../core/services/providers.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/day_of_week.dart';
import '../../../../core/utils/route_constants.dart';
import '../../../../core/utils/vehicle_trail_tracker.dart';
import '../../../../core/models/bus_stop_cache.dart';
import '../../data/models/bus_stop.dart';
import '../../data/models/realtime_arrival.dart';
import '../providers/vehicles_provider.dart';
import '../../../settings/presentation/screens/settings_screen.dart';

/// Map view mode - either showing buses or bus stops
enum MapViewMode { buses, busStops }

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();
  double _currentRotation = 0.0;
  bool _isCacheInitialized = false;

  // Route selection state
  String? _selectedRoute;
  List<BusStop> _directionZeroStops = [];
  List<BusStop> _directionOneStops = [];
  bool _isLoadingRoute = false;

  // Route polylines with OSRM geometry
  Polyline? _directionZeroPolyline;
  Polyline? _directionOnePolyline;

  // Auto-refresh timer for vehicle positions
  Timer? _refreshTimer;

  // View mode toggle (buses vs bus stops)
  MapViewMode _viewMode = MapViewMode.buses;

  // Vehicle trail tracking
  final VehicleTrailTracker _trailTracker = VehicleTrailTracker();
  Map<String, VehicleTrail> _vehicleTrails = {};

  // User location tracking
  Position? _userLocation;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _initializeCache();
    _startAutoRefresh();
    _checkAndRefreshTodaysData();
  }

  /// Starts auto-refresh of vehicle positions every 10 seconds
  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      // Invalidate vehicles provider to trigger refresh
      ref.invalidate(vehiclesProvider);
    });
  }

  /// Check if we have today's data cached, and refresh if missing
  Future<void> _checkAndRefreshTodaysData() async {
    final hasTodaysData = await PreloadService.hasTodaysData();

    if (!hasTodaysData) {
      debugPrint('📅 Today\'s data not cached, fetching in background...');
      final preloadService = ref.read(preloadServiceProvider);
      await preloadService.refreshTodaysData();
    }
  }

  Future<void> _initializeCache() async {
    try {
      await FMTCObjectBoxBackend().initialise();
      await const FMTCStore('mapStore').manage.create();
      setState(() {
        _isCacheInitialized = true;
      });
    } catch (e) {
      // If cache initialization fails, we'll just use non-cached tiles
      debugPrint('Failed to initialize tile cache: $e');
      setState(() {
        _isCacheInitialized = true; // Allow map to load anyway
      });
    }
  }

  /// Handles bus marker tap - loads route stops and switches to route view
  Future<void> _onBusTapped(String routeName) async {
    // If same route is already selected, do nothing
    if (_selectedRoute == routeName) return;

    setState(() {
      _selectedRoute = routeName;
      _isLoadingRoute = true;
      _directionZeroStops = [];
      _directionOneStops = [];
      _directionZeroPolyline = null;
      _directionOnePolyline = null;
    });

    try {
      final day = SerbianDayOfWeek.today.apiName;

      // Fetch both directions in parallel
      final results = await Future.wait([
        ref.read(
          busStopsProvider(
            routeId: routeName,
            dayOfWeek: day,
            directionId: 0,
          ).future,
        ),
        ref.read(
          busStopsProvider(
            routeId: routeName,
            dayOfWeek: day,
            directionId: 1,
          ).future,
        ),
      ]);

      if (mounted) {
        final uniqueStopsDir0 = _getUniqueStops(results[0]);
        final uniqueStopsDir1 = _getUniqueStops(results[1]);

        // Build polylines with OSRM in parallel
        final polylines = await Future.wait([
          _buildRoutePolylineWithOSRM(
            uniqueStopsDir0,
            Colors.blue,
            routeName,
            0,
          ),
          _buildRoutePolylineWithOSRM(
            uniqueStopsDir1,
            Colors.orange,
            routeName,
            1,
          ),
        ]);

        if (mounted) {
          setState(() {
            _directionZeroStops = uniqueStopsDir0;
            _directionOneStops = uniqueStopsDir1;
            _directionZeroPolyline = polylines[0];
            _directionOnePolyline = polylines[1];
            _isLoadingRoute = false;
          });

          // Show message if no stops found
          if (uniqueStopsDir0.isEmpty && uniqueStopsDir1.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('No stops found for route $routeName'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading route: $e');
      if (mounted) {
        setState(() {
          _isLoadingRoute = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load route information: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () => _onBusTapped(routeName),
            ),
          ),
        );
      }
    }
  }

  /// Filters duplicate stops (same stopId) and returns unique stops
  List<BusStop> _getUniqueStops(List<BusStop> stops) {
    final uniqueStops = <String, BusStop>{};
    for (var stop in stops) {
      if (!uniqueStops.containsKey(stop.stopId)) {
        uniqueStops[stop.stopId] = stop;
      }
    }
    return uniqueStops.values.toList();
  }

  /// Clears route selection and returns to normal map view
  void _clearRouteSelection() {
    setState(() {
      _selectedRoute = null;
      _directionZeroStops = [];
      _directionOneStops = [];
      _directionZeroPolyline = null;
      _directionOnePolyline = null;
    });
  }

  /// Build trail polylines from state (always visible)
  List<Polyline> _buildTrailPolylinesFromState() {
    final polylines = <Polyline>[];

    for (final trail in _vehicleTrails.values) {
      // Need at least 2 points to draw a line
      if (trail.points.length < 2) {
        continue;
      }

      // Filter by selected route if applicable
      if (_selectedRoute != null && trail.routeName != _selectedRoute) {
        continue;
      }

      // Get route color
      final routeColor = RouteColors.getColorForRoute(trail.routeName);
      final trailColor = routeColor.withValues(alpha: 0.6); // 60% opacity

      // Create points list (reversed so oldest is first, newest is last)
      final points = trail.points.reversed.map((p) => p.position).toList();

      // Create polyline
      polylines.add(
        Polyline(points: points, strokeWidth: 4.0, color: trailColor),
      );
    }

    // Only log if we're rendering trails
    if (polylines.isNotEmpty) {
      debugPrint('🚌 Rendering ${polylines.length} trail(s)');
    }

    return polylines;
  }

  /// Builds a polyline using OSRM for road-following routes
  /// Falls back to straight lines (dotted) if OSRM fails
  Future<Polyline?> _buildRoutePolylineWithOSRM(
    List<BusStop> stops,
    Color color,
    String routeId,
    int directionId,
  ) async {
    if (stops.isEmpty) return null;

    // Sort by stopSequence to ensure correct order
    final sortedStops = List<BusStop>.from(stops)
      ..sort((a, b) => a.stopSequence.compareTo(b.stopSequence));

    // Extract waypoints (stop coordinates)
    final waypoints = sortedStops
        .map((stop) => LatLng(stop.latitude, stop.longitude))
        .toList();

    try {
      // Get route geometry from cache or OSRM
      final cacheService = ref.read(routeCacheServiceProvider);
      final routePoints = await cacheService.getRouteGeometry(
        routeId: routeId,
        directionId: directionId,
        waypoints: waypoints,
      );

      return Polyline(points: routePoints, strokeWidth: 4.0, color: color);
    } catch (e) {
      debugPrint(
        'Failed to get OSRM route for $routeId dir$directionId, '
        'falling back to straight lines: $e',
      );

      // Fallback to straight lines
      return Polyline(points: waypoints, strokeWidth: 4.0, color: color);
    }
  }

  /// Builds stop markers for a list of bus stops
  List<Marker> _buildStopMarkers(List<BusStop> stops, Color color) {
    return stops.map((stop) {
      return Marker(
        point: LatLng(stop.latitude, stop.longitude),
        width: 30,
        height: 30,
        child: GestureDetector(
          onTap: () => _showStopDetails(stop),
          child: Transform.rotate(
            angle: -_currentRotation * (3.14159 / 180), // Counter-rotate to keep marker upright
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              padding: const EdgeInsets.all(4),
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  color,
                  BlendMode.srcIn,
                ),
                child: Image.asset(
                  'assets/icons/bus_stop_marker.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  /// Shows stop details in a bottom sheet
  void _showStopDetails(BusStop stop) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: scrollController,
            children: [
              // Stop header
              Row(
                children: [
                  const Icon(Icons.place, size: 32, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      stop.stopName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Stop ID info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Stop ID: ${stop.stopId}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),

              const SizedBox(height: 16),
              const Divider(),

              // Real-time arrivals at this stop
              Consumer(
                builder: (context, ref, child) {
                  final arrivalsAsync = ref.watch(realtimeArrivalsProvider(stop.stopId));

                  return arrivalsAsync.when(
                    data: (arrivals) {
                      if (arrivals.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Icon(Icons.schedule, size: 48, color: Colors.grey),
                              SizedBox(height: 8),
                              Text(
                                'No buses arriving soon',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Check back later for real-time arrivals',
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 20, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(
                                'Real-Time Arrivals (${arrivals.length})',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...arrivals.map((arrival) => _buildRealtimeArrivalCard(context, arrival)),
                        ],
                      );
                    },
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 12),
                            Text(
                              'Loading real-time arrivals...',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                    error: (error, stack) => Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 8),
                          Text(
                            'Error loading arrivals',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Check your internet connection',
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build a card for a real-time arrival
  Widget _buildRealtimeArrivalCard(BuildContext context, RealtimeArrival arrival) {
    final routeColor = RouteColors.getColorForRoute(arrival.routeShortName);
    final routeName = getRouteName(arrival.routeShortName);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: routeColor,
          child: Text(
            arrival.routeShortName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        title: Text(
          routeName,
          style: const TextStyle(fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              arrival.destination,
              style: const TextStyle(fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: arrival.remainingMinutes <= 5 ? Colors.red : Colors.blue,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    arrival.formattedArrivalTime,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: arrival.remainingMinutes <= 5 ? Colors.red : Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: arrival.remainingMinutes <= 5
                ? Colors.red.withValues(alpha: 0.1)
                : routeColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${arrival.remainingMinutes} min',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: arrival.remainingMinutes <= 5 ? Colors.red : routeColor,
            ),
          ),
        ),
        onTap: () {
          // Close the bottom sheet
          Navigator.pop(context);

          // Show the selected route on the map
          _onBusTapped(arrival.routeShortName);
        },
      ),
    );
  }

  /// Toggle between buses and bus stops view
  void _toggleViewMode() {
    setState(() {
      _viewMode = _viewMode == MapViewMode.buses
          ? MapViewMode.busStops
          : MapViewMode.buses;
    });
  }

  /// Show stop details by stopId (for bus stop markers)
  void _showStopDetailsByStopId(String stopId, String stopName) async {
    try {
      // Find a stop with this stopId from cache (use first match)
      final stopsBox = Hive.box<BusStopCache>('bus_stops');

      for (final cache in stopsBox.values) {
        for (final stopData in cache.stops) {
          if (stopData.stopId == stopId) {
            // Found it! Convert to BusStop and show details
            final busStop = stopData.toBusStop();
            _showStopDetails(busStop);
            return;
          }
        }
      }

      // If we reach here, stop not found (shouldn't happen)
      debugPrint('Warning: Stop $stopId not found in cache');
    } catch (e) {
      debugPrint('Error showing stop details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehiclesAsync = ref.watch(vehiclesProvider);

    // Update trails immediately when new vehicle data arrives (before rendering)
    // This ensures trails and markers are always in sync
    vehiclesAsync.whenData((vehicles) {
      _vehicleTrails = _trailTracker.updateTrails(vehicles);
    });

    if (!_isCacheInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prevoz - Podgorica'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(
                AppConstants.podgoricaLat,
                AppConstants.podgoricaLng,
              ),
              initialZoom: AppConstants.defaultMapZoom,
              minZoom: AppConstants.minMapZoom,
              maxZoom: AppConstants.maxMapZoom,
              onMapEvent: (event) {
                if (event is MapEventRotate) {
                  setState(() {
                    _currentRotation = event.camera.rotation;
                  });
                }
              },
            ),
            children: [
              // CartoDB Tiles with caching (faster than OSM)
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.example.prevoz',
                maxZoom: 19,
                tileProvider: FMTCTileProvider(stores: {'mapStore': null}),
              ),

              // Route Polylines with OSRM geometry (shown when route is selected)
              if (_selectedRoute != null) ...[
                PolylineLayer(
                  polylines: [
                    if (_directionZeroPolyline != null) _directionZeroPolyline!,
                    if (_directionOnePolyline != null) _directionOnePolyline!,
                  ].whereType<Polyline>().toList(),
                ),
              ],

              // Bus Stop Markers (shown when route is selected)
              if (_selectedRoute != null) ...[
                // Direction 0 stops (blue)
                MarkerLayer(
                  markers: _buildStopMarkers(_directionZeroStops, Colors.blue),
                ),
                // Direction 1 stops (orange)
                MarkerLayer(
                  markers: _buildStopMarkers(_directionOneStops, Colors.orange),
                ),
              ],

              // Vehicle Movement Trails (only in buses view mode)
              if (_viewMode == MapViewMode.buses)
                PolylineLayer(polylines: _buildTrailPolylinesFromState()),

              // Vehicle Markers
              vehiclesAsync.when(
                data: (vehicles) {
                  // Only show vehicle markers in buses view mode
                  if (_viewMode != MapViewMode.buses) {
                    return const SizedBox.shrink();
                  }

                  // Filter vehicles by selected route
                  final filteredVehicles = vehicles.where((vehicle) {
                    if (_selectedRoute == null) return true;
                    return vehicle.routeName == _selectedRoute;
                  }).toList();

                  if (filteredVehicles.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return MarkerLayer(
                    markers: filteredVehicles.map((vehicle) {
                      final routeColor = RouteColors.getColorForRoute(
                        vehicle.routeName,
                      );
                      final routeName = getRouteName(vehicle.routeName);

                      return Marker(
                        point: LatLng(vehicle.latitude, vehicle.longitude),
                        width: 120,
                        height: 110,
                        alignment: const Alignment(
                          0,
                          0.42,
                        ), // Circle center at GPS point
                        child: GestureDetector(
                          onTap: () => _onBusTapped(vehicle.routeName),
                          child: Transform.rotate(
                            angle: -_currentRotation * (3.14159 / 180), // Counter-rotate to keep marker upright
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                              // Bus icon with route ID overlaid
                              SizedBox(
                                width: 50,
                                height: 50,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Colored circle background with bus icon
                                    Container(
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: routeColor,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.3,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.directions_bus,
                                        color: Colors.white.withValues(
                                          alpha: 0.3,
                                        ),
                                        size: 32,
                                      ),
                                    ),
                                    // Route ID text on top
                                    Text(
                                      vehicle.routeName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            color: Colors.grey.shade700,
                                            blurRadius: 2,
                                            offset: const Offset(0, 0),
                                          ),
                                          Shadow(
                                            color: Colors.grey.shade700,
                                            blurRadius: 2,
                                            offset: const Offset(1, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 0),
                              // Route name (2 lines allowed)
                              Container(
                                constraints: const BoxConstraints(
                                  maxWidth: 110,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  routeName,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: Colors.black87,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (error, stackTrace) => const SizedBox.shrink(),
              ),

              // Bus Stop Markers with Clustering (only in bus stops view mode)
              if (_viewMode == MapViewMode.busStops)
                Consumer(
                  builder: (context, ref, child) {
                    final busStopsAsync = ref.watch(allBusStopsProvider);

                    return busStopsAsync.when(
                      data: (stops) {
                        if (stops.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        // Build markers list
                        final markers = stops.map((stop) {
                          return Marker(
                            point: LatLng(stop.latitude, stop.longitude),
                            width: 32,
                            height: 32,
                            child: GestureDetector(
                              onTap: () => _showStopDetailsByStopId(
                                stop.stopId,
                                stop.stopName,
                              ),
                              child: Transform.rotate(
                                angle: -_currentRotation * (3.14159 / 180), // Counter-rotate to keep marker upright
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.blue,
                                      width: 2,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: ColorFiltered(
                                    colorFilter: const ColorFilter.mode(
                                      Colors.blue,
                                      BlendMode.srcIn,
                                    ),
                                    child: Image.asset(
                                      'assets/icons/bus_stop_marker.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList();

                        // Use clustering for better performance
                        return MarkerClusterLayerWidget(
                          options: MarkerClusterLayerOptions(
                            maxClusterRadius: 100,
                            size: const Size(50, 50),
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(50),
                            maxZoom: 15,
                            markers: markers,
                            polygonOptions: const PolygonOptions(
                              borderColor: Colors.blue,
                              color: Colors.transparent,
                              borderStrokeWidth: 3,
                            ),
                            builder: (context, markers) {
                              return Transform.rotate(
                                angle: -_currentRotation * (3.14159 / 180), // Counter-rotate to keep cluster upright
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.blue,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      markers.length.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black45,
                                            blurRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (error, stackTrace) => const SizedBox.shrink(),
                    );
                  },
                ),

              // User Location Marker (always on top)
              if (_userLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(_userLocation!.latitude, _userLocation!.longitude),
                      width: 50,
                      height: 50,
                      child: Transform.rotate(
                        angle: -_currentRotation * (3.14159 / 180), // Counter-rotate to keep marker upright
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue.withValues(alpha: 0.3),
                            border: Border.all(color: Colors.blue, width: 3),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.my_location,
                              color: Colors.blue,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Loading indicator
          if (vehiclesAsync.isLoading)
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text('Loading vehicles...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Error indicator
          if (vehiclesAsync.hasError)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                color: Colors.red.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Error loading vehicles',
                          style: TextStyle(color: Colors.red.shade900),
                        ),
                      ),
                      TextButton(
                        onPressed: () => ref.refresh(vehiclesProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Route Info Panel (shown when route is selected)
          if (_selectedRoute != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: RouteColors.getColorForRoute(
                          _selectedRoute!,
                        ),
                        child: Text(
                          _selectedRoute!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              getRouteName(_selectedRoute!),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Icon(Icons.place, size: 14, color: Colors.blue),
                                const SizedBox(width: 4),
                                Text(
                                  '${_directionZeroStops.length} stops',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.place,
                                  size: 14,
                                  color: Colors.orange,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${_directionOneStops.length} stops',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (_isLoadingRoute)
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
                  ),
                ),
              ),
            ),

          // View mode toggle (bottom-left)
          Positioned(
            bottom: 24,
            left: 16,
            child: GestureDetector(
              onTap: _toggleViewMode,
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _viewMode == MapViewMode.buses
                                ? Icons.directions_bus
                                : Icons.place,
                            size: 22,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          if (_viewMode == MapViewMode.buses)
                            vehiclesAsync.when(
                              data: (vehicles) => Text(
                                '${vehicles.length} ${vehicles.length == 1 ? 'bus' : 'buses'}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              loading: () => const Text(
                                'Loading...',
                                style: TextStyle(fontSize: 14),
                              ),
                              error: (error, stack) => const Text(
                                '0 buses',
                                style: TextStyle(fontSize: 14),
                              ),
                            )
                          else
                            Consumer(
                              builder: (context, ref, child) {
                                final stopsAsync = ref.watch(allBusStopsProvider);
                                return stopsAsync.when(
                                  data: (stops) => Text(
                                    '${stops.length} ${stops.length == 1 ? 'stop' : 'stops'}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  loading: () => const Text(
                                    'Loading...',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  error: (error, stack) => const Text(
                                    '0 stops',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _viewMode == MapViewMode.buses
                                ? 'Tap for stops'
                                : 'Tap for buses',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.swap_horiz,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Clear Route Selection button (only show when route is selected)
          if (_selectedRoute != null)
            FloatingActionButton.small(
              heroTag: 'clear_route',
              onPressed: _clearRouteSelection,
              tooltip: 'Clear route selection',
              backgroundColor: Colors.red,
              child: const Icon(Icons.close),
            ),
          if (_selectedRoute != null) const SizedBox(height: 8),

          // Compass / Reset North button (only show when rotated)
          if (_currentRotation.abs() > 0.5)
            FloatingActionButton.small(
              heroTag: 'reset_north',
              onPressed: _resetNorth,
              tooltip: 'Reset north',
              child: Transform.rotate(
                angle: -_currentRotation * (3.14159 / 180),
                child: const Icon(Icons.navigation),
              ),
            ),
          if (_currentRotation.abs() > 0.5) const SizedBox(height: 8),

          // Zoom In
          FloatingActionButton.small(
            heroTag: 'zoom_in',
            onPressed: () {
              final zoom = _mapController.camera.zoom + 1;
              _mapController.move(
                _mapController.camera.center,
                zoom.clamp(AppConstants.minMapZoom, AppConstants.maxMapZoom),
              );
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),

          // Zoom Out
          FloatingActionButton.small(
            heroTag: 'zoom_out',
            onPressed: () {
              final zoom = _mapController.camera.zoom - 1;
              _mapController.move(
                _mapController.camera.center,
                zoom.clamp(AppConstants.minMapZoom, AppConstants.maxMapZoom),
              );
            },
            child: const Icon(Icons.remove),
          ),
          const SizedBox(height: 8),

          // Center on user location
          FloatingActionButton(
            heroTag: 'center',
            onPressed: _isLoadingLocation ? null : _moveToUserLocation,
            child: _isLoadingLocation
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.my_location),
          ),
        ],
      ),
    );
  }

  /// Check and request location permission
  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location services are disabled. Please enable them in settings.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
      }
      return false;
    }

    // Check location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission denied. Please grant permission to use this feature.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
        }
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Location permission permanently denied. Please enable in settings.'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Settings',
              onPressed: () => Geolocator.openLocationSettings(),
            ),
          ),
        );
      }
      return false;
    }

    return true;
  }

  /// Get user's current location and move map to it
  Future<void> _moveToUserLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Check permissions
      final hasPermission = await _checkLocationPermission();
      if (!hasPermission) {
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      if (mounted) {
        setState(() {
          _userLocation = position;
          _isLoadingLocation = false;
        });

        // Move map to user location with zoom 16 (more zoomed in than default)
        _mapController.move(
          LatLng(position.latitude, position.longitude),
          16.0,
        );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('Centered on your location'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error getting user location: $e');
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get location: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _resetNorth() async {
    // Animate rotation back to north over 300ms
    const duration = Duration(milliseconds: 300);
    const steps = 20; // 20 steps for smooth animation
    final startRotation = _currentRotation;
    final stepDuration = duration ~/ steps;

    for (int i = 1; i <= steps; i++) {
      final progress = i / steps;
      // Ease-out animation curve
      final easedProgress = 1.0 - (1.0 - progress) * (1.0 - progress);
      final newRotation = startRotation * (1.0 - easedProgress);

      _mapController.rotate(newRotation);

      if (i < steps) {
        await Future.delayed(stepDuration);
      }
    }

    // Ensure we end exactly at 0
    _mapController.rotate(0.0);
    setState(() {
      _currentRotation = 0.0;
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }
}
