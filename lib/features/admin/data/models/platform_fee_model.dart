import 'package:freezed_annotation/freezed_annotation.dart';

part 'platform_fee_model.freezed.dart';
part 'platform_fee_model.g.dart';

@freezed
class PlatformFeeModel with _$PlatformFeeModel {
  const factory PlatformFeeModel({
    required String id,
    required double matches,
    required double tournaments,
    required double autoTournaments,
    required double topics,
  }) = _PlatformFeeModel;

  factory PlatformFeeModel.fromJson(Map<String, dynamic> json) =>
      _$PlatformFeeModelFromJson(json);
}
