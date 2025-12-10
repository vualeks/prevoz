// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$osrmServiceHash() => r'331fcb01e73f7b93507aab2dd926457c3f87fac0';

/// Provides OSRM service for route geometry fetching
///
/// Copied from [osrmService].
@ProviderFor(osrmService)
final osrmServiceProvider = AutoDisposeProvider<OsrmService>.internal(
  osrmService,
  name: r'osrmServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$osrmServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef OsrmServiceRef = AutoDisposeProviderRef<OsrmService>;
String _$routeCacheServiceHash() => r'810fa1acd784d12d10dc14dfd634da5395eee22b';

/// Provides route cache service for managing OSRM route geometries
///
/// Copied from [routeCacheService].
@ProviderFor(routeCacheService)
final routeCacheServiceProvider =
    AutoDisposeProvider<RouteCacheService>.internal(
      routeCacheService,
      name: r'routeCacheServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$routeCacheServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RouteCacheServiceRef = AutoDisposeProviderRef<RouteCacheService>;
String _$preloadServiceHash() => r'bb99bb783c138ec9874a415520eb47dd44d9e800';

/// Provides preload service for first-launch data caching
///
/// Copied from [preloadService].
@ProviderFor(preloadService)
final preloadServiceProvider = AutoDisposeProvider<PreloadService>.internal(
  preloadService,
  name: r'preloadServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$preloadServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PreloadServiceRef = AutoDisposeProviderRef<PreloadService>;
String _$isPreloadCompleteHash() => r'51d5b73e80e3c656f94077a203ecd3c11ca269b6';

/// Checks if preload is complete
///
/// Copied from [isPreloadComplete].
@ProviderFor(isPreloadComplete)
final isPreloadCompleteProvider = AutoDisposeFutureProvider<bool>.internal(
  isPreloadComplete,
  name: r'isPreloadCompleteProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$isPreloadCompleteHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef IsPreloadCompleteRef = AutoDisposeFutureProviderRef<bool>;
String _$busStopQueryServiceHash() =>
    r'5d51acf5a5f406c22ad566dde47e7f62278ef91d';

/// Provides bus stop query service for finding routes at stops
///
/// Copied from [busStopQueryService].
@ProviderFor(busStopQueryService)
final busStopQueryServiceProvider =
    AutoDisposeProvider<BusStopQueryService>.internal(
      busStopQueryService,
      name: r'busStopQueryServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$busStopQueryServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BusStopQueryServiceRef = AutoDisposeProviderRef<BusStopQueryService>;
String _$routesAtStopHash() => r'4f518da4a4bd464480862ed2860929a93e3860cd';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Finds all routes that go through a specific bus stop
///
/// Copied from [routesAtStop].
@ProviderFor(routesAtStop)
const routesAtStopProvider = RoutesAtStopFamily();

/// Finds all routes that go through a specific bus stop
///
/// Copied from [routesAtStop].
class RoutesAtStopFamily extends Family<AsyncValue<List<RouteAtStop>>> {
  /// Finds all routes that go through a specific bus stop
  ///
  /// Copied from [routesAtStop].
  const RoutesAtStopFamily();

  /// Finds all routes that go through a specific bus stop
  ///
  /// Copied from [routesAtStop].
  RoutesAtStopProvider call(String stopId) {
    return RoutesAtStopProvider(stopId);
  }

  @override
  RoutesAtStopProvider getProviderOverride(
    covariant RoutesAtStopProvider provider,
  ) {
    return call(provider.stopId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'routesAtStopProvider';
}

/// Finds all routes that go through a specific bus stop
///
/// Copied from [routesAtStop].
class RoutesAtStopProvider
    extends AutoDisposeFutureProvider<List<RouteAtStop>> {
  /// Finds all routes that go through a specific bus stop
  ///
  /// Copied from [routesAtStop].
  RoutesAtStopProvider(String stopId)
    : this._internal(
        (ref) => routesAtStop(ref as RoutesAtStopRef, stopId),
        from: routesAtStopProvider,
        name: r'routesAtStopProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$routesAtStopHash,
        dependencies: RoutesAtStopFamily._dependencies,
        allTransitiveDependencies:
            RoutesAtStopFamily._allTransitiveDependencies,
        stopId: stopId,
      );

  RoutesAtStopProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.stopId,
  }) : super.internal();

  final String stopId;

  @override
  Override overrideWith(
    FutureOr<List<RouteAtStop>> Function(RoutesAtStopRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: RoutesAtStopProvider._internal(
        (ref) => create(ref as RoutesAtStopRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        stopId: stopId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<RouteAtStop>> createElement() {
    return _RoutesAtStopProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is RoutesAtStopProvider && other.stopId == stopId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, stopId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin RoutesAtStopRef on AutoDisposeFutureProviderRef<List<RouteAtStop>> {
  /// The parameter `stopId` of this provider.
  String get stopId;
}

class _RoutesAtStopProviderElement
    extends AutoDisposeFutureProviderElement<List<RouteAtStop>>
    with RoutesAtStopRef {
  _RoutesAtStopProviderElement(super.provider);

  @override
  String get stopId => (origin as RoutesAtStopProvider).stopId;
}

String _$allBusStopsHash() => r'e0324a029a1fc3be463bbe1ba2c8a3b974b7e1a7';

/// Gets all unique bus stops from cached data
///
/// Copied from [allBusStops].
@ProviderFor(allBusStops)
final allBusStopsProvider =
    AutoDisposeFutureProvider<List<UniqueBusStop>>.internal(
      allBusStops,
      name: r'allBusStopsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$allBusStopsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AllBusStopsRef = AutoDisposeFutureProviderRef<List<UniqueBusStop>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
