// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bus_stop.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

BusStop _$BusStopFromJson(Map<String, dynamic> json) {
  return _BusStop.fromJson(json);
}

/// @nodoc
mixin _$BusStop {
  int get id => throw _privateConstructorUsedError;
  String get stopId => throw _privateConstructorUsedError;
  String get stopName => throw _privateConstructorUsedError;
  String get arrivalTime => throw _privateConstructorUsedError;
  String get departureTime => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  int get stopSequence => throw _privateConstructorUsedError;
  int get stopTimeId => throw _privateConstructorUsedError;

  /// Serializes this BusStop to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of BusStop
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BusStopCopyWith<BusStop> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BusStopCopyWith<$Res> {
  factory $BusStopCopyWith(BusStop value, $Res Function(BusStop) then) =
      _$BusStopCopyWithImpl<$Res, BusStop>;
  @useResult
  $Res call({
    int id,
    String stopId,
    String stopName,
    String arrivalTime,
    String departureTime,
    double latitude,
    double longitude,
    int stopSequence,
    int stopTimeId,
  });
}

/// @nodoc
class _$BusStopCopyWithImpl<$Res, $Val extends BusStop>
    implements $BusStopCopyWith<$Res> {
  _$BusStopCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BusStop
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? stopId = null,
    Object? stopName = null,
    Object? arrivalTime = null,
    Object? departureTime = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? stopSequence = null,
    Object? stopTimeId = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            stopId: null == stopId
                ? _value.stopId
                : stopId // ignore: cast_nullable_to_non_nullable
                      as String,
            stopName: null == stopName
                ? _value.stopName
                : stopName // ignore: cast_nullable_to_non_nullable
                      as String,
            arrivalTime: null == arrivalTime
                ? _value.arrivalTime
                : arrivalTime // ignore: cast_nullable_to_non_nullable
                      as String,
            departureTime: null == departureTime
                ? _value.departureTime
                : departureTime // ignore: cast_nullable_to_non_nullable
                      as String,
            latitude: null == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double,
            longitude: null == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double,
            stopSequence: null == stopSequence
                ? _value.stopSequence
                : stopSequence // ignore: cast_nullable_to_non_nullable
                      as int,
            stopTimeId: null == stopTimeId
                ? _value.stopTimeId
                : stopTimeId // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$BusStopImplCopyWith<$Res> implements $BusStopCopyWith<$Res> {
  factory _$$BusStopImplCopyWith(
    _$BusStopImpl value,
    $Res Function(_$BusStopImpl) then,
  ) = __$$BusStopImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String stopId,
    String stopName,
    String arrivalTime,
    String departureTime,
    double latitude,
    double longitude,
    int stopSequence,
    int stopTimeId,
  });
}

/// @nodoc
class __$$BusStopImplCopyWithImpl<$Res>
    extends _$BusStopCopyWithImpl<$Res, _$BusStopImpl>
    implements _$$BusStopImplCopyWith<$Res> {
  __$$BusStopImplCopyWithImpl(
    _$BusStopImpl _value,
    $Res Function(_$BusStopImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of BusStop
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? stopId = null,
    Object? stopName = null,
    Object? arrivalTime = null,
    Object? departureTime = null,
    Object? latitude = null,
    Object? longitude = null,
    Object? stopSequence = null,
    Object? stopTimeId = null,
  }) {
    return _then(
      _$BusStopImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        stopId: null == stopId
            ? _value.stopId
            : stopId // ignore: cast_nullable_to_non_nullable
                  as String,
        stopName: null == stopName
            ? _value.stopName
            : stopName // ignore: cast_nullable_to_non_nullable
                  as String,
        arrivalTime: null == arrivalTime
            ? _value.arrivalTime
            : arrivalTime // ignore: cast_nullable_to_non_nullable
                  as String,
        departureTime: null == departureTime
            ? _value.departureTime
            : departureTime // ignore: cast_nullable_to_non_nullable
                  as String,
        latitude: null == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double,
        longitude: null == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double,
        stopSequence: null == stopSequence
            ? _value.stopSequence
            : stopSequence // ignore: cast_nullable_to_non_nullable
                  as int,
        stopTimeId: null == stopTimeId
            ? _value.stopTimeId
            : stopTimeId // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$BusStopImpl implements _BusStop {
  const _$BusStopImpl({
    required this.id,
    required this.stopId,
    required this.stopName,
    required this.arrivalTime,
    required this.departureTime,
    required this.latitude,
    required this.longitude,
    required this.stopSequence,
    required this.stopTimeId,
  });

  factory _$BusStopImpl.fromJson(Map<String, dynamic> json) =>
      _$$BusStopImplFromJson(json);

  @override
  final int id;
  @override
  final String stopId;
  @override
  final String stopName;
  @override
  final String arrivalTime;
  @override
  final String departureTime;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final int stopSequence;
  @override
  final int stopTimeId;

  @override
  String toString() {
    return 'BusStop(id: $id, stopId: $stopId, stopName: $stopName, arrivalTime: $arrivalTime, departureTime: $departureTime, latitude: $latitude, longitude: $longitude, stopSequence: $stopSequence, stopTimeId: $stopTimeId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BusStopImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.stopId, stopId) || other.stopId == stopId) &&
            (identical(other.stopName, stopName) ||
                other.stopName == stopName) &&
            (identical(other.arrivalTime, arrivalTime) ||
                other.arrivalTime == arrivalTime) &&
            (identical(other.departureTime, departureTime) ||
                other.departureTime == departureTime) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.stopSequence, stopSequence) ||
                other.stopSequence == stopSequence) &&
            (identical(other.stopTimeId, stopTimeId) ||
                other.stopTimeId == stopTimeId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    stopId,
    stopName,
    arrivalTime,
    departureTime,
    latitude,
    longitude,
    stopSequence,
    stopTimeId,
  );

  /// Create a copy of BusStop
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BusStopImplCopyWith<_$BusStopImpl> get copyWith =>
      __$$BusStopImplCopyWithImpl<_$BusStopImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BusStopImplToJson(this);
  }
}

abstract class _BusStop implements BusStop {
  const factory _BusStop({
    required final int id,
    required final String stopId,
    required final String stopName,
    required final String arrivalTime,
    required final String departureTime,
    required final double latitude,
    required final double longitude,
    required final int stopSequence,
    required final int stopTimeId,
  }) = _$BusStopImpl;

  factory _BusStop.fromJson(Map<String, dynamic> json) = _$BusStopImpl.fromJson;

  @override
  int get id;
  @override
  String get stopId;
  @override
  String get stopName;
  @override
  String get arrivalTime;
  @override
  String get departureTime;
  @override
  double get latitude;
  @override
  double get longitude;
  @override
  int get stopSequence;
  @override
  int get stopTimeId;

  /// Create a copy of BusStop
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BusStopImplCopyWith<_$BusStopImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
