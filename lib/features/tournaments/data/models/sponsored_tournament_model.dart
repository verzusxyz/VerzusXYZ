import 'package:freezed_annotation/freezed_annotation.dart';

part 'sponsored_tournament_model.freezed.dart';
part 'sponsored_tournament_model.g.dart';

@freezed
class SponsoredTournamentModel with _$SponsoredTournamentModel {
  const factory SponsoredTournamentModel({
    required String id,
    required String name,
    required double prizePool,
    required Map<int, double> prizeDistribution,
    required DateTime createdAt,
  }) = _SponsoredTournamentModel;

  factory SponsoredTournamentModel.fromJson(Map<String, dynamic> json) =>
      _$SponsoredTournamentModelFromJson(json);
}
