/// Represents the current step in the preload process
enum PreloadStep {
  downloadingTiles,
  cachingRoutes,
  cachingStops,
  cachingGeometries,
  completed;

  /// Get user-friendly message for each step
  String get message {
    switch (this) {
      case PreloadStep.downloadingTiles:
        return 'Downloading map tiles...';
      case PreloadStep.cachingRoutes:
        return 'Loading routes...';
      case PreloadStep.cachingStops:
        return 'Loading bus stops...';
      case PreloadStep.cachingGeometries:
        return 'Mapping routes...';
      case PreloadStep.completed:
        return 'Ready to go!';
    }
  }

  /// Get icon name for each step
  String get iconName {
    switch (this) {
      case PreloadStep.downloadingTiles:
        return 'map';
      case PreloadStep.cachingRoutes:
        return 'directions_bus';
      case PreloadStep.cachingStops:
        return 'place';
      case PreloadStep.cachingGeometries:
        return 'route';
      case PreloadStep.completed:
        return 'check_circle';
    }
  }
}

/// Progress information for the preload process
class PreloadProgress {
  final PreloadStep currentStep;
  final double stepProgress;
  final double totalProgress;
  final String message;
  final int? itemsDone;
  final int? itemsTotal;

  const PreloadProgress({
    required this.currentStep,
    required this.stepProgress,
    required this.totalProgress,
    required this.message,
    this.itemsDone,
    this.itemsTotal,
  });

  /// Create initial progress state
  factory PreloadProgress.initial() {
    return const PreloadProgress(
      currentStep: PreloadStep.downloadingTiles,
      stepProgress: 0.0,
      totalProgress: 0.0,
      message: 'Preparing to download map tiles...',
    );
  }

  /// Create completed progress state
  factory PreloadProgress.completed() {
    return const PreloadProgress(
      currentStep: PreloadStep.completed,
      stepProgress: 1.0,
      totalProgress: 1.0,
      message: 'Ready to go!',
    );
  }

  /// Get percentage as integer (0-100)
  int get percentageComplete => (totalProgress * 100).toInt();

  /// Check if progress has item counts
  bool get hasItemCounts => itemsDone != null && itemsTotal != null;

  /// Get formatted item count string (e.g., "123 / 456")
  String? get itemCountString {
    if (!hasItemCounts) return null;
    return '$itemsDone / $itemsTotal';
  }

  /// Create a copy with updated fields
  PreloadProgress copyWith({
    PreloadStep? currentStep,
    double? stepProgress,
    double? totalProgress,
    String? message,
    int? itemsDone,
    int? itemsTotal,
  }) {
    return PreloadProgress(
      currentStep: currentStep ?? this.currentStep,
      stepProgress: stepProgress ?? this.stepProgress,
      totalProgress: totalProgress ?? this.totalProgress,
      message: message ?? this.message,
      itemsDone: itemsDone ?? this.itemsDone,
      itemsTotal: itemsTotal ?? this.itemsTotal,
    );
  }

  @override
  String toString() {
    return 'PreloadProgress('
        'step: $currentStep, '
        'progress: $percentageComplete%, '
        'message: $message'
        '${hasItemCounts ? ', items: $itemCountString' : ''}'
        ')';
  }
}
