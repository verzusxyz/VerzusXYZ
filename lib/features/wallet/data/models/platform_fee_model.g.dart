// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_fee_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PlatformFeeModelImpl _$$PlatformFeeModelImplFromJson(
        Map<String, dynamic> json) =>
    _$PlatformFeeModelImpl(
      id: json['id'] as String,
      matches: (json['matches'] as num).toDouble(),
      tournaments: (json['tournaments'] as num).toDouble(),
      autoTournaments: (json['autoTournaments'] as num).toDouble(),
      topics: (json['topics'] as num).toDouble(),
    );

Map<String, dynamic> _$$PlatformFeeModelImplToJson(
        _$PlatformFeeModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'matches': instance.matches,
      'tournaments': instance.tournaments,
      'autoTournaments': instance.autoTournaments,
      'topics': instance.topics,
    };
