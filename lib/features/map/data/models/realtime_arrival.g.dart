// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'realtime_arrival.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RealtimeArrivalImpl _$$RealtimeArrivalImplFromJson(
  Map<String, dynamic> json,
) => _$RealtimeArrivalImpl(
  routeShortName: json['routeShortName'] as String,
  destination: json['destination'] as String,
  remainingMinutes: (json['remainingMinutes'] as num).toInt(),
  formattedArrivalTime: json['formattedArrivalTime'] as String,
);

Map<String, dynamic> _$$RealtimeArrivalImplToJson(
  _$RealtimeArrivalImpl instance,
) => <String, dynamic>{
  'routeShortName': instance.routeShortName,
  'destination': instance.destination,
  'remainingMinutes': instance.remainingMinutes,
  'formattedArrivalTime': instance.formattedArrivalTime,
};
