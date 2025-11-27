import 'package:freezed_annotation/freezed_annotation.dart';

part 'affiliate_level_model.freezed.dart';
part 'affiliate_level_model.g.dart';

@freezed
class AffiliateLevelModel with _$AffiliateLevelModel {
  const factory AffiliateLevelModel({
    required String id,
    required String name,
    required double commissionRate,
  }) = _AffiliateLevelModel;

  factory AffiliateLevelModel.fromJson(Map<String, dynamic> json) =>
      _$AffiliateLevelModelFromJson(json);
}
