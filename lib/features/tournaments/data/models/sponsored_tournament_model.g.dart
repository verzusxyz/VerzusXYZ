// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sponsored_tournament_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SponsoredTournamentModelImpl _$$SponsoredTournamentModelImplFromJson(
        Map<String, dynamic> json) =>
    _$SponsoredTournamentModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      prizePool: (json['prizePool'] as num).toDouble(),
      prizeDistribution:
          (json['prizeDistribution'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(int.parse(k), (e as num).toDouble()),
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$SponsoredTournamentModelImplToJson(
        _$SponsoredTournamentModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'prizePool': instance.prizePool,
      'prizeDistribution': instance.prizeDistribution
          .map((k, e) => MapEntry(k.toString(), e)),
      'createdAt': instance.createdAt.toIso8601String(),
    };
