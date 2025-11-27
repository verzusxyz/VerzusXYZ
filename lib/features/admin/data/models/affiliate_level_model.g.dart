// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'affiliate_level_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AffiliateLevelModelImpl _$$AffiliateLevelModelImplFromJson(
        Map<String, dynamic> json) =>
    _$AffiliateLevelModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      commissionRate: (json['commissionRate'] as num).toDouble(),
    );

Map<String, dynamic> _$$AffiliateLevelModelImplToJson(
        _$AffiliateLevelModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'commissionRate': instance.commissionRate,
    };
