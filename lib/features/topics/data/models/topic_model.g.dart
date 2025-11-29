// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topic_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TopicModelImpl _$$TopicModelImplFromJson(Map<String, dynamic> json) =>
    _$TopicModelImpl(
      id: json['id'] as String,
      question: json['question'] as String,
      type: json['type'] as String,
      options:
          (json['options'] as List<dynamic>).map((e) => e as String).toList(),
      entryFee: (json['entryFee'] as num).toDouble(),
      walletKind: json['walletKind'] as String,
      status: json['status'] as String,
    );

Map<String, dynamic> _$$TopicModelImplToJson(_$TopicModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'question': instance.question,
      'type': instance.type,
      'options': instance.options,
      'entryFee': instance.entryFee,
      'walletKind': instance.walletKind,
      'status': instance.status,
    };
