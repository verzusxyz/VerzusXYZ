// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sponsored_tournament_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

SponsoredTournamentModel _$SponsoredTournamentModelFromJson(
    Map<String, dynamic> json) {
  return _SponsoredTournamentModel.fromJson(json);
}

/// @nodoc
mixin _$SponsoredTournamentModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  double get prizePool => throw _privateConstructorUsedError;
  Map<int, double> get prizeDistribution => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SponsoredTournamentModelCopyWith<SponsoredTournamentModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SponsoredTournamentModelCopyWith<$Res> {
  factory $SponsoredTournamentModelCopyWith(SponsoredTournamentModel value,
          $Res Function(SponsoredTournamentModel) then) =
      _$SponsoredTournamentModelCopyWithImpl<$Res, SponsoredTournamentModel>;
  @useResult
  $Res call(
      {String id,
      String name,
      double prizePool,
      Map<int, double> prizeDistribution,
      DateTime createdAt});
}

/// @nodoc
class _$SponsoredTournamentModelCopyWithImpl<$Res,
        $Val extends SponsoredTournamentModel>
    implements $SponsoredTournamentModelCopyWith<$Res> {
  _$SponsoredTournamentModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? prizePool = null,
    Object? prizeDistribution = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      prizePool: null == prizePool
          ? _value.prizePool
          : prizePool // ignore: cast_nullable_to_non_nullable
              as double,
      prizeDistribution: null == prizeDistribution
          ? _value.prizeDistribution
          : prizeDistribution // ignore: cast_nullable_to_non_nullable
              as Map<int, double>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SponsoredTournamentModelImplCopyWith<$Res>
    implements $SponsoredTournamentModelCopyWith<$Res> {
  factory _$$SponsoredTournamentModelImplCopyWith(
          _$SponsoredTournamentModelImpl value,
          $Res Function(_$SponsoredTournamentModelImpl) then) =
      __$$SponsoredTournamentModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      double prizePool,
      Map<int, double> prizeDistribution,
      DateTime createdAt});
}

/// @nodoc
class __$$SponsoredTournamentModelImplCopyWithImpl<$Res>
    extends _$SponsoredTournamentModelCopyWithImpl<$Res,
        _$SponsoredTournamentModelImpl>
    implements _$$SponsoredTournamentModelImplCopyWith<$Res> {
  __$$SponsoredTournamentModelImplCopyWithImpl(
      _$SponsoredTournamentModelImpl _value,
      $Res Function(_$SponsoredTournamentModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? prizePool = null,
    Object? prizeDistribution = null,
    Object? createdAt = null,
  }) {
    return _then(_$SponsoredTournamentModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      prizePool: null == prizePool
          ? _value.prizePool
          : prizePool // ignore: cast_nullable_to_non_nullable
              as double,
      prizeDistribution: null == prizeDistribution
          ? _value._prizeDistribution
          : prizeDistribution // ignore: cast_nullable_to_non_nullable
              as Map<int, double>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SponsoredTournamentModelImpl implements _SponsoredTournamentModel {
  const _$SponsoredTournamentModelImpl(
      {required this.id,
      required this.name,
      required this.prizePool,
      required final Map<int, double> prizeDistribution,
      required this.createdAt})
      : _prizeDistribution = prizeDistribution;

  factory _$SponsoredTournamentModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SponsoredTournamentModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final double prizePool;
  final Map<int, double> _prizeDistribution;
  @override
  Map<int, double> get prizeDistribution {
    if (_prizeDistribution is EqualUnmodifiableMapView)
      return _prizeDistribution;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_prizeDistribution);
  }

  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'SponsoredTournamentModel(id: $id, name: $name, prizePool: $prizePool, prizeDistribution: $prizeDistribution, createdAt: $createdAt)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SponsoredTournamentModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.prizePool, prizePool) ||
                other.prizePool == prizePool) &&
            const DeepCollectionEquality()
                .equals(other._prizeDistribution, _prizeDistribution) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, prizePool,
      const DeepCollectionEquality().hash(_prizeDistribution), createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SponsoredTournamentModelImplCopyWith<_$SponsoredTournamentModelImpl>
      get copyWith => __$$SponsoredTournamentModelImplCopyWithImpl<
          _$SponsoredTournamentModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SponsoredTournamentModelImplToJson(
      this,
    );
  }
}

abstract class _SponsoredTournamentModel implements SponsoredTournamentModel {
  const factory _SponsoredTournamentModel(
      {required final String id,
      required final String name,
      required final double prizePool,
      required final Map<int, double> prizeDistribution,
      required final DateTime createdAt}) = _$SponsoredTournamentModelImpl;

  factory _SponsoredTournamentModel.fromJson(Map<String, dynamic> json) =
      _$SponsoredTournamentModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  double get prizePool;
  @override
  Map<int, double> get prizeDistribution;
  @override
  DateTime get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$SponsoredTournamentModelImplCopyWith<_$SponsoredTournamentModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
