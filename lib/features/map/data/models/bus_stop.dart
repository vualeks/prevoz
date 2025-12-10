import 'package:freezed_annotation/freezed_annotation.dart';

part 'bus_stop.freezed.dart';
part 'bus_stop.g.dart';

@freezed
class BusStop with _$BusStop {
  const factory BusStop({
    required int id,
    required String stopId,
    required String stopName,
    required String arrivalTime,
    required String departureTime,
    required double latitude,
    required double longitude,
    required int stopSequence,
    required int stopTimeId,
  }) = _BusStop;

  factory BusStop.fromJson(Map<String, dynamic> json) =>
      _$BusStopFromJson(json);
}
