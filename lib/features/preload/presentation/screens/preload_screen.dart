import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/providers.dart';
import '../../../map/presentation/screens/map_screen.dart';
import '../../domain/models/preload_progress.dart';

/// Provider for preload progress stream
final preloadProgressProvider =
    StreamProvider.autoDispose<PreloadProgress>((ref) {
  final preloadService = ref.watch(preloadServiceProvider);

  // Start preload when provider is created
  Future.microtask(() => preloadService.executePreload());

  return preloadService.progressStream;
});

/// Screen shown on first launch to preload all app data
class PreloadScreen extends ConsumerWidget {
  const PreloadScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(preloadProgressProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Icon
              Icon(
                Icons.directions_bus,
                size: 80,
                color: Colors.blue[700],
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'Setting up your app...',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Progress content
              progressAsync.when(
                data: (progress) {
                  // Check if completed
                  if (progress.currentStep == PreloadStep.completed) {
                    // Navigate to map screen after short delay
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (context.mounted) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const MapScreen(),
                          ),
                        );
                      }
                    });
                  }

                  return Column(
                    children: [
                      // Progress bar
                      _buildProgressBar(context, progress),
                      const SizedBox(height: 48),

                      // Step list
                      _buildStepList(context, progress),
                    ],
                  );
                },
                loading: () => const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Initializing...'),
                  ],
                ),
                error: (error, stackTrace) => _buildErrorState(
                  context,
                  error,
                  () {
                    // Retry by invalidating the provider
                    ref.invalidate(preloadProgressProvider);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build progress bar with percentage
  Widget _buildProgressBar(BuildContext context, PreloadProgress progress) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress.totalProgress,
            minHeight: 12,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.blue[700]!,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '${progress.percentageComplete}%',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
        ),
      ],
    );
  }

  /// Build list of preload steps
  Widget _buildStepList(BuildContext context, PreloadProgress progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepItem(
          context: context,
          icon: Icons.map,
          label: 'Downloading map tiles',
          step: PreloadStep.downloadingTiles,
          currentProgress: progress,
        ),
        const SizedBox(height: 16),
        _buildStepItem(
          context: context,
          icon: Icons.directions_bus,
          label: 'Loading routes',
          step: PreloadStep.cachingRoutes,
          currentProgress: progress,
        ),
        const SizedBox(height: 16),
        _buildStepItem(
          context: context,
          icon: Icons.place,
          label: 'Loading bus stops',
          step: PreloadStep.cachingStops,
          currentProgress: progress,
        ),
        const SizedBox(height: 16),
        _buildStepItem(
          context: context,
          icon: Icons.route,
          label: 'Mapping routes',
          step: PreloadStep.cachingGeometries,
          currentProgress: progress,
        ),
      ],
    );
  }

  /// Build individual step item
  Widget _buildStepItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required PreloadStep step,
    required PreloadProgress currentProgress,
  }) {
    final status = _getStepStatus(step, currentProgress);
    final isActive = status == StepStatus.inProgress;
    final isComplete = status == StepStatus.completed;

    Color iconColor;
    Widget leadingWidget;

    if (isComplete) {
      iconColor = Colors.green;
      leadingWidget = const Icon(
        Icons.check_circle,
        color: Colors.green,
        size: 28,
      );
    } else if (isActive) {
      iconColor = Colors.blue[700]!;
      leadingWidget = SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(iconColor),
        ),
      );
    } else {
      iconColor = Colors.grey[400]!;
      leadingWidget = Icon(
        Icons.hourglass_empty,
        color: iconColor,
        size: 28,
      );
    }

    return Row(
      children: [
        leadingWidget,
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      color: isComplete
                          ? Colors.green[700]
                          : isActive
                              ? Colors.blue[700]
                              : Colors.grey[600],
                    ),
              ),
              if (isActive && currentProgress.hasItemCounts)
                Text(
                  currentProgress.itemCountString!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Get step status based on current progress
  StepStatus _getStepStatus(PreloadStep step, PreloadProgress progress) {
    final currentIndex = PreloadStep.values.indexOf(progress.currentStep);
    final stepIndex = PreloadStep.values.indexOf(step);

    if (stepIndex < currentIndex) {
      return StepStatus.completed;
    } else if (stepIndex == currentIndex) {
      return StepStatus.inProgress;
    } else {
      return StepStatus.pending;
    }
  }

  /// Build error state with retry option
  Widget _buildErrorState(
    BuildContext context,
    Object error,
    VoidCallback onRetry,
  ) {
    return Column(
      children: [
        Icon(
          Icons.error_outline,
          size: 64,
          color: Theme.of(context).colorScheme.error,
        ),
        const SizedBox(height: 16),
        Text(
          'Setup Failed',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'An error occurred while setting up the app.',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          error.toString(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Retry'),
        ),
      ],
    );
  }
}

/// Step status enum
enum StepStatus {
  completed,
  inProgress,
  pending,
}
