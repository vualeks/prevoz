import 'package:freezed_annotation/freezed_annotation.dart';

part 'vehicle.freezed.dart';
part 'vehicle.g.dart';

/// Represents a bus/vehicle in the transit system
@freezed
class Vehicle with _$Vehicle {
  const factory Vehicle({
    required String routeName,
    required double latitude,
    required double longitude,
    required double speed,
  }) = _Vehicle;

  factory Vehicle.fromJson(Map<String, dynamic> json) =>
      _$VehicleFromJson(json);
}
