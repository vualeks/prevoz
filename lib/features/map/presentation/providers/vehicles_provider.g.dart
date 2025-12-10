// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicles_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$vehiclesHash() => r'534405e75eeaca45f011b2fb2656972256083738';

/// Provider that fetches all vehicles
/// Automatically refreshes and handles loading/error states
///
/// Copied from [vehicles].
@ProviderFor(vehicles)
final vehiclesProvider = AutoDisposeFutureProvider<List<Vehicle>>.internal(
  vehicles,
  name: r'vehiclesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$vehiclesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef VehiclesRef = AutoDisposeFutureProviderRef<List<Vehicle>>;
String _$vehiclesByRouteHash() => r'0274ea6c934cc638b40cd98c6e6f11956d0ea992';

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

/// Provider that fetches vehicles for a specific route
///
/// Copied from [vehiclesByRoute].
@ProviderFor(vehiclesByRoute)
const vehiclesByRouteProvider = VehiclesByRouteFamily();

/// Provider that fetches vehicles for a specific route
///
/// Copied from [vehiclesByRoute].
class VehiclesByRouteFamily extends Family<AsyncValue<List<Vehicle>>> {
  /// Provider that fetches vehicles for a specific route
  ///
  /// Copied from [vehiclesByRoute].
  const VehiclesByRouteFamily();

  /// Provider that fetches vehicles for a specific route
  ///
  /// Copied from [vehiclesByRoute].
  VehiclesByRouteProvider call(String routeName) {
    return VehiclesByRouteProvider(routeName);
  }

  @override
  VehiclesByRouteProvider getProviderOverride(
    covariant VehiclesByRouteProvider provider,
  ) {
    return call(provider.routeName);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'vehiclesByRouteProvider';
}

/// Provider that fetches vehicles for a specific route
///
/// Copied from [vehiclesByRoute].
class VehiclesByRouteProvider extends AutoDisposeFutureProvider<List<Vehicle>> {
  /// Provider that fetches vehicles for a specific route
  ///
  /// Copied from [vehiclesByRoute].
  VehiclesByRouteProvider(String routeName)
    : this._internal(
        (ref) => vehiclesByRoute(ref as VehiclesByRouteRef, routeName),
        from: vehiclesByRouteProvider,
        name: r'vehiclesByRouteProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$vehiclesByRouteHash,
        dependencies: VehiclesByRouteFamily._dependencies,
        allTransitiveDependencies:
            VehiclesByRouteFamily._allTransitiveDependencies,
        routeName: routeName,
      );

  VehiclesByRouteProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.routeName,
  }) : super.internal();

  final String routeName;

  @override
  Override overrideWith(
    FutureOr<List<Vehicle>> Function(VehiclesByRouteRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: VehiclesByRouteProvider._internal(
        (ref) => create(ref as VehiclesByRouteRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        routeName: routeName,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Vehicle>> createElement() {
    return _VehiclesByRouteProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is VehiclesByRouteProvider && other.routeName == routeName;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, routeName.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin VehiclesByRouteRef on AutoDisposeFutureProviderRef<List<Vehicle>> {
  /// The parameter `routeName` of this provider.
  String get routeName;
}

class _VehiclesByRouteProviderElement
    extends AutoDisposeFutureProviderElement<List<Vehicle>>
    with VehiclesByRouteRef {
  _VehiclesByRouteProviderElement(super.provider);

  @override
  String get routeName => (origin as VehiclesByRouteProvider).routeName;
}

String _$busStopsHash() => r'04cfd05ad1f4184715c2b9e1b7569c34d0480571';

/// Provider that fetches bus stops for a specific route, day, and direction
///
/// Copied from [busStops].
@ProviderFor(busStops)
const busStopsProvider = BusStopsFamily();

/// Provider that fetches bus stops for a specific route, day, and direction
///
/// Copied from [busStops].
class BusStopsFamily extends Family<AsyncValue<List<BusStop>>> {
  /// Provider that fetches bus stops for a specific route, day, and direction
  ///
  /// Copied from [busStops].
  const BusStopsFamily();

  /// Provider that fetches bus stops for a specific route, day, and direction
  ///
  /// Copied from [busStops].
  BusStopsProvider call({
    required String routeId,
    required String dayOfWeek,
    required int directionId,
  }) {
    return BusStopsProvider(
      routeId: routeId,
      dayOfWeek: dayOfWeek,
      directionId: directionId,
    );
  }

  @override
  BusStopsProvider getProviderOverride(covariant BusStopsProvider provider) {
    return call(
      routeId: provider.routeId,
      dayOfWeek: provider.dayOfWeek,
      directionId: provider.directionId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'busStopsProvider';
}

/// Provider that fetches bus stops for a specific route, day, and direction
///
/// Copied from [busStops].
class BusStopsProvider extends AutoDisposeFutureProvider<List<BusStop>> {
  /// Provider that fetches bus stops for a specific route, day, and direction
  ///
  /// Copied from [busStops].
  BusStopsProvider({
    required String routeId,
    required String dayOfWeek,
    required int directionId,
  }) : this._internal(
         (ref) => busStops(
           ref as BusStopsRef,
           routeId: routeId,
           dayOfWeek: dayOfWeek,
           directionId: directionId,
         ),
         from: busStopsProvider,
         name: r'busStopsProvider',
         debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
             ? null
             : _$busStopsHash,
         dependencies: BusStopsFamily._dependencies,
         allTransitiveDependencies: BusStopsFamily._allTransitiveDependencies,
         routeId: routeId,
         dayOfWeek: dayOfWeek,
         directionId: directionId,
       );

  BusStopsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.routeId,
    required this.dayOfWeek,
    required this.directionId,
  }) : super.internal();

  final String routeId;
  final String dayOfWeek;
  final int directionId;

  @override
  Override overrideWith(
    FutureOr<List<BusStop>> Function(BusStopsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: BusStopsProvider._internal(
        (ref) => create(ref as BusStopsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        routeId: routeId,
        dayOfWeek: dayOfWeek,
        directionId: directionId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<BusStop>> createElement() {
    return _BusStopsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BusStopsProvider &&
        other.routeId == routeId &&
        other.dayOfWeek == dayOfWeek &&
        other.directionId == directionId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, routeId.hashCode);
    hash = _SystemHash.combine(hash, dayOfWeek.hashCode);
    hash = _SystemHash.combine(hash, directionId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin BusStopsRef on AutoDisposeFutureProviderRef<List<BusStop>> {
  /// The parameter `routeId` of this provider.
  String get routeId;

  /// The parameter `dayOfWeek` of this provider.
  String get dayOfWeek;

  /// The parameter `directionId` of this provider.
  int get directionId;
}

class _BusStopsProviderElement
    extends AutoDisposeFutureProviderElement<List<BusStop>>
    with BusStopsRef {
  _BusStopsProviderElement(super.provider);

  @override
  String get routeId => (origin as BusStopsProvider).routeId;
  @override
  String get dayOfWeek => (origin as BusStopsProvider).dayOfWeek;
  @override
  int get directionId => (origin as BusStopsProvider).directionId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
