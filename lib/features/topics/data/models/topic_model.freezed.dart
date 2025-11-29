// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'topic_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

TopicModel _$TopicModelFromJson(Map<String, dynamic> json) {
  return _TopicModel.fromJson(json);
}

/// @nodoc
mixin _$TopicModel {
  String get id => throw _privateConstructorUsedError;
  String get question => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  List<String> get options => throw _privateConstructorUsedError;
  double get entryFee => throw _privateConstructorUsedError;
  String get walletKind => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TopicModelCopyWith<TopicModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TopicModelCopyWith<$Res> {
  factory $TopicModelCopyWith(
          TopicModel value, $Res Function(TopicModel) then) =
      _$TopicModelCopyWithImpl<$Res, TopicModel>;
  @useResult
  $Res call(
      {String id,
      String question,
      String type,
      List<String> options,
      double entryFee,
      String walletKind,
      String status});
}

/// @nodoc
class _$TopicModelCopyWithImpl<$Res, $Val extends TopicModel>
    implements $TopicModelCopyWith<$Res> {
  _$TopicModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? question = null,
    Object? type = null,
    Object? options = null,
    Object? entryFee = null,
    Object? walletKind = null,
    Object? status = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      question: null == question
          ? _value.question
          : question // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      options: null == options
          ? _value.options
          : options // ignore: cast_nullable_to_non_nullable
              as List<String>,
      entryFee: null == entryFee
          ? _value.entryFee
          : entryFee // ignore: cast_nullable_to_non_nullable
              as double,
      walletKind: null == walletKind
          ? _value.walletKind
          : walletKind // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TopicModelImplCopyWith<$Res>
    implements $TopicModelCopyWith<$Res> {
  factory _$$TopicModelImplCopyWith(
          _$TopicModelImpl value, $Res Function(_$TopicModelImpl) then) =
      __$$TopicModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String question,
      String type,
      List<String> options,
      double entryFee,
      String walletKind,
      String status});
}

/// @nodoc
class __$$TopicModelImplCopyWithImpl<$Res>
    extends _$TopicModelCopyWithImpl<$Res, _$TopicModelImpl>
    implements _$$TopicModelImplCopyWith<$Res> {
  __$$TopicModelImplCopyWithImpl(
      _$TopicModelImpl _value, $Res Function(_$TopicModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? question = null,
    Object? type = null,
    Object? options = null,
    Object? entryFee = null,
    Object? walletKind = null,
    Object? status = null,
  }) {
    return _then(_$TopicModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      question: null == question
          ? _value.question
          : question // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      options: null == options
          ? _value._options
          : options // ignore: cast_nullable_to_non_nullable
              as List<String>,
      entryFee: null == entryFee
          ? _value.entryFee
          : entryFee // ignore: cast_nullable_to_non_nullable
              as double,
      walletKind: null == walletKind
          ? _value.walletKind
          : walletKind // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TopicModelImpl implements _TopicModel {
  const _$TopicModelImpl(
      {required this.id,
      required this.question,
      required this.type,
      required final List<String> options,
      required this.entryFee,
      required this.walletKind,
      required this.status})
      : _options = options;

  factory _$TopicModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TopicModelImplFromJson(json);

  @override
  final String id;
  @override
  final String question;
  @override
  final String type;
  final List<String> _options;
  @override
  List<String> get options {
    if (_options is EqualUnmodifiableListView) return _options;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_options);
  }

  @override
  final double entryFee;
  @override
  final String walletKind;
  @override
  final String status;

  @override
  String toString() {
    return 'TopicModel(id: $id, question: $question, type: $type, options: $options, entryFee: $entryFee, walletKind: $walletKind, status: $status)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TopicModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.question, question) ||
                other.question == question) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality().equals(other._options, _options) &&
            (identical(other.entryFee, entryFee) ||
                other.entryFee == entryFee) &&
            (identical(other.walletKind, walletKind) ||
                other.walletKind == walletKind) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      question,
      type,
      const DeepCollectionEquality().hash(_options),
      entryFee,
      walletKind,
      status);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TopicModelImplCopyWith<_$TopicModelImpl> get copyWith =>
      __$$TopicModelImplCopyWithImpl<_$TopicModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TopicModelImplToJson(
      this,
    );
  }
}

abstract class _TopicModel implements TopicModel {
  const factory _TopicModel(
      {required final String id,
      required final String question,
      required final String type,
      required final List<String> options,
      required final double entryFee,
      required final String walletKind,
      required final String status}) = _$TopicModelImpl;

  factory _TopicModel.fromJson(Map<String, dynamic> json) =
      _$TopicModelImpl.fromJson;

  @override
  String get id;
  @override
  String get question;
  @override
  String get type;
  @override
  List<String> get options;
  @override
  double get entryFee;
  @override
  String get walletKind;
  @override
  String get status;
  @override
  @JsonKey(ignore: true)
  _$$TopicModelImplCopyWith<_$TopicModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
