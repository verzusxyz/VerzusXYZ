// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'topic_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TopicModelImpl _$$TopicModelImplFromJson(Map<String, dynamic> json) =>
    _$TopicModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
    );

Map<String, dynamic> _$$TopicModelImplToJson(_$TopicModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'category': instance.category,
    };
