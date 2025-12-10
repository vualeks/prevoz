// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bus_stop.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BusStopImpl _$$BusStopImplFromJson(Map<String, dynamic> json) =>
    _$BusStopImpl(
      id: (json['id'] as num).toInt(),
      stopId: json['stopId'] as String,
      stopName: json['stopName'] as String,
      arrivalTime: json['arrivalTime'] as String,
      departureTime: json['departureTime'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      stopSequence: (json['stopSequence'] as num).toInt(),
      stopTimeId: (json['stopTimeId'] as num).toInt(),
    );

Map<String, dynamic> _$$BusStopImplToJson(_$BusStopImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'stopId': instance.stopId,
      'stopName': instance.stopName,
      'arrivalTime': instance.arrivalTime,
      'departureTime': instance.departureTime,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'stopSequence': instance.stopSequence,
      'stopTimeId': instance.stopTimeId,
    };
