// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'realtime_arrival.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RealtimeArrival _$RealtimeArrivalFromJson(Map<String, dynamic> json) {
  return _RealtimeArrival.fromJson(json);
}

/// @nodoc
mixin _$RealtimeArrival {
  String get routeShortName => throw _privateConstructorUsedError;
  String get destination => throw _privateConstructorUsedError;
  int get remainingMinutes => throw _privateConstructorUsedError;
  String get formattedArrivalTime => throw _privateConstructorUsedError;

  /// Serializes this RealtimeArrival to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RealtimeArrival
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RealtimeArrivalCopyWith<RealtimeArrival> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RealtimeArrivalCopyWith<$Res> {
  factory $RealtimeArrivalCopyWith(
    RealtimeArrival value,
    $Res Function(RealtimeArrival) then,
  ) = _$RealtimeArrivalCopyWithImpl<$Res, RealtimeArrival>;
  @useResult
  $Res call({
    String routeShortName,
    String destination,
    int remainingMinutes,
    String formattedArrivalTime,
  });
}

/// @nodoc
class _$RealtimeArrivalCopyWithImpl<$Res, $Val extends RealtimeArrival>
    implements $RealtimeArrivalCopyWith<$Res> {
  _$RealtimeArrivalCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RealtimeArrival
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? routeShortName = null,
    Object? destination = null,
    Object? remainingMinutes = null,
    Object? formattedArrivalTime = null,
  }) {
    return _then(
      _value.copyWith(
            routeShortName: null == routeShortName
                ? _value.routeShortName
                : routeShortName // ignore: cast_nullable_to_non_nullable
                      as String,
            destination: null == destination
                ? _value.destination
                : destination // ignore: cast_nullable_to_non_nullable
                      as String,
            remainingMinutes: null == remainingMinutes
                ? _value.remainingMinutes
                : remainingMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            formattedArrivalTime: null == formattedArrivalTime
                ? _value.formattedArrivalTime
                : formattedArrivalTime // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RealtimeArrivalImplCopyWith<$Res>
    implements $RealtimeArrivalCopyWith<$Res> {
  factory _$$RealtimeArrivalImplCopyWith(
    _$RealtimeArrivalImpl value,
    $Res Function(_$RealtimeArrivalImpl) then,
  ) = __$$RealtimeArrivalImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String routeShortName,
    String destination,
    int remainingMinutes,
    String formattedArrivalTime,
  });
}

/// @nodoc
class __$$RealtimeArrivalImplCopyWithImpl<$Res>
    extends _$RealtimeArrivalCopyWithImpl<$Res, _$RealtimeArrivalImpl>
    implements _$$RealtimeArrivalImplCopyWith<$Res> {
  __$$RealtimeArrivalImplCopyWithImpl(
    _$RealtimeArrivalImpl _value,
    $Res Function(_$RealtimeArrivalImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RealtimeArrival
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? routeShortName = null,
    Object? destination = null,
    Object? remainingMinutes = null,
    Object? formattedArrivalTime = null,
  }) {
    return _then(
      _$RealtimeArrivalImpl(
        routeShortName: null == routeShortName
            ? _value.routeShortName
            : routeShortName // ignore: cast_nullable_to_non_nullable
                  as String,
        destination: null == destination
            ? _value.destination
            : destination // ignore: cast_nullable_to_non_nullable
                  as String,
        remainingMinutes: null == remainingMinutes
            ? _value.remainingMinutes
            : remainingMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        formattedArrivalTime: null == formattedArrivalTime
            ? _value.formattedArrivalTime
            : formattedArrivalTime // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RealtimeArrivalImpl implements _RealtimeArrival {
  const _$RealtimeArrivalImpl({
    required this.routeShortName,
    required this.destination,
    required this.remainingMinutes,
    required this.formattedArrivalTime,
  });

  factory _$RealtimeArrivalImpl.fromJson(Map<String, dynamic> json) =>
      _$$RealtimeArrivalImplFromJson(json);

  @override
  final String routeShortName;
  @override
  final String destination;
  @override
  final int remainingMinutes;
  @override
  final String formattedArrivalTime;

  @override
  String toString() {
    return 'RealtimeArrival(routeShortName: $routeShortName, destination: $destination, remainingMinutes: $remainingMinutes, formattedArrivalTime: $formattedArrivalTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RealtimeArrivalImpl &&
            (identical(other.routeShortName, routeShortName) ||
                other.routeShortName == routeShortName) &&
            (identical(other.destination, destination) ||
                other.destination == destination) &&
            (identical(other.remainingMinutes, remainingMinutes) ||
                other.remainingMinutes == remainingMinutes) &&
            (identical(other.formattedArrivalTime, formattedArrivalTime) ||
                other.formattedArrivalTime == formattedArrivalTime));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    routeShortName,
    destination,
    remainingMinutes,
    formattedArrivalTime,
  );

  /// Create a copy of RealtimeArrival
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RealtimeArrivalImplCopyWith<_$RealtimeArrivalImpl> get copyWith =>
      __$$RealtimeArrivalImplCopyWithImpl<_$RealtimeArrivalImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$RealtimeArrivalImplToJson(this);
  }
}

abstract class _RealtimeArrival implements RealtimeArrival {
  const factory _RealtimeArrival({
    required final String routeShortName,
    required final String destination,
    required final int remainingMinutes,
    required final String formattedArrivalTime,
  }) = _$RealtimeArrivalImpl;

  factory _RealtimeArrival.fromJson(Map<String, dynamic> json) =
      _$RealtimeArrivalImpl.fromJson;

  @override
  String get routeShortName;
  @override
  String get destination;
  @override
  int get remainingMinutes;
  @override
  String get formattedArrivalTime;

  /// Create a copy of RealtimeArrival
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RealtimeArrivalImplCopyWith<_$RealtimeArrivalImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
