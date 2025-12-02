// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'platform_fee_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

PlatformFeeModel _$PlatformFeeModelFromJson(Map<String, dynamic> json) {
  return _PlatformFeeModel.fromJson(json);
}

/// @nodoc
mixin _$PlatformFeeModel {
  String get id => throw _privateConstructorUsedError;
  double get matches => throw _privateConstructorUsedError;
  double get tournaments => throw _privateConstructorUsedError;
  double get autoTournaments => throw _privateConstructorUsedError;
  double get topics => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PlatformFeeModelCopyWith<PlatformFeeModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PlatformFeeModelCopyWith<$Res> {
  factory $PlatformFeeModelCopyWith(
          PlatformFeeModel value, $Res Function(PlatformFeeModel) then) =
      _$PlatformFeeModelCopyWithImpl<$Res, PlatformFeeModel>;
  @useResult
  $Res call(
      {String id,
      double matches,
      double tournaments,
      double autoTournaments,
      double topics});
}

/// @nodoc
class _$PlatformFeeModelCopyWithImpl<$Res, $Val extends PlatformFeeModel>
    implements $PlatformFeeModelCopyWith<$Res> {
  _$PlatformFeeModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? matches = null,
    Object? tournaments = null,
    Object? autoTournaments = null,
    Object? topics = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      matches: null == matches
          ? _value.matches
          : matches // ignore: cast_nullable_to_non_nullable
              as double,
      tournaments: null == tournaments
          ? _value.tournaments
          : tournaments // ignore: cast_nullable_to_non_nullable
              as double,
      autoTournaments: null == autoTournaments
          ? _value.autoTournaments
          : autoTournaments // ignore: cast_nullable_to_non_nullable
              as double,
      topics: null == topics
          ? _value.topics
          : topics // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PlatformFeeModelImplCopyWith<$Res>
    implements $PlatformFeeModelCopyWith<$Res> {
  factory _$$PlatformFeeModelImplCopyWith(_$PlatformFeeModelImpl value,
          $Res Function(_$PlatformFeeModelImpl) then) =
      __$$PlatformFeeModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      double matches,
      double tournaments,
      double autoTournaments,
      double topics});
}

/// @nodoc
class __$$PlatformFeeModelImplCopyWithImpl<$Res>
    extends _$PlatformFeeModelCopyWithImpl<$Res, _$PlatformFeeModelImpl>
    implements _$$PlatformFeeModelImplCopyWith<$Res> {
  __$$PlatformFeeModelImplCopyWithImpl(_$PlatformFeeModelImpl _value,
      $Res Function(_$PlatformFeeModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? matches = null,
    Object? tournaments = null,
    Object? autoTournaments = null,
    Object? topics = null,
  }) {
    return _then(_$PlatformFeeModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      matches: null == matches
          ? _value.matches
          : matches // ignore: cast_nullable_to_non_nullable
              as double,
      tournaments: null == tournaments
          ? _value.tournaments
          : tournaments // ignore: cast_nullable_to_non_nullable
              as double,
      autoTournaments: null == autoTournaments
          ? _value.autoTournaments
          : autoTournaments // ignore: cast_nullable_to_non_nullable
              as double,
      topics: null == topics
          ? _value.topics
          : topics // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PlatformFeeModelImpl implements _PlatformFeeModel {
  const _$PlatformFeeModelImpl(
      {required this.id,
      required this.matches,
      required this.tournaments,
      required this.autoTournaments,
      required this.topics});

  factory _$PlatformFeeModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PlatformFeeModelImplFromJson(json);

  @override
  final String id;
  @override
  final double matches;
  @override
  final double tournaments;
  @override
  final double autoTournaments;
  @override
  final double topics;

  @override
  String toString() {
    return 'PlatformFeeModel(id: $id, matches: $matches, tournaments: $tournaments, autoTournaments: $autoTournaments, topics: $topics)';
  }

  @override
  // ignore: non_nullable_equals_parameter
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PlatformFeeModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.matches, matches) || other.matches == matches) &&
            (identical(other.tournaments, tournaments) ||
                other.tournaments == tournaments) &&
            (identical(other.autoTournaments, autoTournaments) ||
                other.autoTournaments == autoTournaments) &&
            (identical(other.topics, topics) || other.topics == topics));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, matches, tournaments, autoTournaments, topics);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PlatformFeeModelImplCopyWith<_$PlatformFeeModelImpl> get copyWith =>
      __$$PlatformFeeModelImplCopyWithImpl<_$PlatformFeeModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PlatformFeeModelImplToJson(
      this,
    );
  }
}

abstract class _PlatformFeeModel implements PlatformFeeModel {
  const factory _PlatformFeeModel(
      {required final String id,
      required final double matches,
      required final double tournaments,
      required final double autoTournaments,
      required final double topics}) = _$PlatformFeeModelImpl;

  factory _PlatformFeeModel.fromJson(Map<String, dynamic> json) =
      _$PlatformFeeModelImpl.fromJson;

  @override
  String get id;
  @override
  double get matches;
  @override
  double get tournaments;
  @override
  double get autoTournaments;
  @override
  double get topics;
  @override
  @JsonKey(ignore: true)
  _$$PlatformFeeModelImplCopyWith<_$PlatformFeeModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
