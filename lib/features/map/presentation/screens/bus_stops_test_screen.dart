import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/day_of_week.dart';
import '../providers/vehicles_provider.dart';

/// Test screen to verify bus stops API integration works
class BusStopsTestScreen extends ConsumerWidget {
  const BusStopsTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Test with route 10, today's day, direction 0
    final busStopsAsync = ref.watch(
      busStopsProvider(
        routeId: '10',
        dayOfWeek: SerbianDayOfWeek.today.apiName,
        directionId: 0,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bus Stops Test - Route 10'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(busStopsProvider),
          ),
        ],
      ),
      body: busStopsAsync.when(
        data: (stops) {
          if (stops.isEmpty) {
            return const Center(
              child: Text('No bus stops found for this route'),
            );
          }

          return ListView.builder(
            itemCount: stops.length,
            itemBuilder: (context, index) {
              final stop = stops[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text('${stop.stopSequence}'),
                  ),
                  title: Text(stop.stopName),
                  subtitle: Text(
                    'Arrival: ${stop.arrivalTime}\n'
                    'Lat: ${stop.latitude.toStringAsFixed(4)}, '
                    'Lng: ${stop.longitude.toStringAsFixed(4)}',
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Stop ID: ${stop.stopId}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        'Seq: ${stop.stopSequence}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading bus stops',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(busStopsProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
