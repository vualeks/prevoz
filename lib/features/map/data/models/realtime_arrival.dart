import 'package:freezed_annotation/freezed_annotation.dart';

part 'realtime_arrival.freezed.dart';
part 'realtime_arrival.g.dart';

/// Represents real-time arrival information for a bus at a specific stop
@freezed
class RealtimeArrival with _$RealtimeArrival {
  const factory RealtimeArrival({
    required String routeShortName,
    required String destination,
    required int remainingMinutes,
    required String formattedArrivalTime,
  }) = _RealtimeArrival;

  factory RealtimeArrival.fromJson(Map<String, dynamic> json) =>
      _$RealtimeArrivalFromJson(json);
}
