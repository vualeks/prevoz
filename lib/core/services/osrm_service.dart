import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

/// Service for interacting with OSRM (Open Source Routing Machine) API
/// Provides road-following route geometry between waypoints
class OsrmService {
  final Dio _dio;
  static const String _baseUrl = 'https://router.project-osrm.org';

  OsrmService(this._dio);

  /// Fetch route geometry from OSRM
  ///
  /// Takes a list of waypoints (lat/lng coordinates) and returns
  /// a list of points that follow actual roads between those waypoints.
  ///
  /// Uses the OSRM public API with simplified geometry for performance.
  ///
  /// Throws [Exception] if the API request fails or returns invalid data.
  Future<List<LatLng>> getRouteGeometry(List<LatLng> waypoints) async {
    if (waypoints.length < 2) {
      throw ArgumentError('Need at least 2 waypoints for routing');
    }

    try {
      // Build coordinates string: lon,lat;lon,lat;...
      // OSRM uses lon,lat order (opposite of LatLng)
      final coordinates = waypoints
          .map((point) => '${point.longitude},${point.latitude}')
          .join(';');

      final url = '$_baseUrl/route/v1/driving/$coordinates';

      debugPrint('OSRM Request: $url');

      final response = await _dio.get(
        url,
        queryParameters: {
          'overview': 'simplified', // Simplified geometry (fewer points)
          'geometries': 'geojson', // GeoJSON format
        },
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Check if OSRM returned success
        if (data['code'] != 'Ok') {
          throw Exception('OSRM error: ${data['code']}');
        }

        final routes = data['routes'] as List;
        if (routes.isEmpty) {
          throw Exception('No routes found');
        }

        final geometry = routes[0]['geometry'];
        final coordinates = geometry['coordinates'] as List;

        // Convert to LatLng (OSRM returns [lon, lat] format)
        final points = coordinates
            .map((coord) => LatLng(
                  coord[1] as double, // latitude
                  coord[0] as double, // longitude
                ))
            .toList();

        debugPrint('OSRM Success: ${points.length} points received');
        return points;
      } else {
        throw Exception('OSRM request failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('OSRM API error: $e');
      rethrow;
    }
  }
}
