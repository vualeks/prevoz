import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/models/bus_stop_cache.dart';
import '../../../../core/models/route_geometry.dart';
import '../../../../core/models/route_metadata.dart';
import '../../../../core/services/preload_service.dart';
import '../../../../core/services/providers.dart';
import '../../../preload/presentation/screens/preload_screen.dart';

/// Settings screen with cache management and debug options
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Map<String, dynamic>? _cacheStats;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadCacheStats();
  }

  Future<void> _loadCacheStats() async {
    setState(() => _isLoadingStats = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final preloadComplete = prefs.getBool('preload_completed') ?? false;

      final routeGeometriesCount = Hive.box<RouteGeometry>('route_geometries').length;
      final busStopsCount = Hive.box<BusStopCache>('bus_stops').length;
      final routeMetadataCount = Hive.box<RouteMetadata>('route_metadata').length;

      setState(() {
        _cacheStats = {
          'preload_complete': preloadComplete,
          'route_geometries': routeGeometriesCount,
          'bus_stops': busStopsCount,
          'route_metadata': routeMetadataCount,
        };
        _isLoadingStats = false;
      });
    } catch (e) {
      debugPrint('Error loading cache stats: $e');
      setState(() => _isLoadingStats = false);
    }
  }

  Future<void> _clearAllCacheAndReload() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Cache?'),
        content: const Text(
          'This will delete all cached data (routes, stops, map tiles) and require a full reload.\n\nAre you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear & Reload'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await PreloadService.resetPreloadStatus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cache cleared! Restarting preload...'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to preload screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const PreloadScreen(),
          ),
        );
      }
    }
  }

  Future<void> _refreshTodaysData() async {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Refreshing today\'s data...'),
        duration: Duration(seconds: 2),
      ),
    );

    try {
      final preloadService = ref.read(preloadServiceProvider);
      await preloadService.refreshTodaysData();

      if (mounted) {
        await _loadCacheStats();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Today\'s data refreshed successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error refreshing data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: _isLoadingStats
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                // Cache Info Section
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Cache Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildCacheInfoCard(),

                const Divider(height: 32),

                // Actions Section
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Cache Management',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Refresh Today's Data Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton.icon(
                    onPressed: _refreshTodaysData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh Today\'s Data'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Clear All Cache Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton.icon(
                    onPressed: _clearAllCacheAndReload,
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('Clear All Cache & Reload'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
    );
  }

  Widget _buildCacheInfoCard() {
    if (_cacheStats == null) {
      return const Card(
        margin: EdgeInsets.all(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Unable to load cache stats'),
        ),
      );
    }

    final preloadComplete = _cacheStats!['preload_complete'] as bool;
    final routeGeometries = _cacheStats!['route_geometries'] as int;
    final busStops = _cacheStats!['bus_stops'] as int;
    final routeMetadata = _cacheStats!['route_metadata'] as int;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  preloadComplete ? Icons.check_circle : Icons.warning,
                  color: preloadComplete ? Colors.green : Colors.orange,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  preloadComplete ? 'Preload Complete' : 'Preload Incomplete',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildStatRow('Route Geometries', routeGeometries),
            _buildStatRow('Bus Stops', busStops),
            _buildStatRow('Route Metadata', routeMetadata),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            '$count',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
