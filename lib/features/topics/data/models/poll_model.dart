import 'package:freezed_annotation/freezed_annotation.dart';

part 'poll_model.freezed.dart';
part 'poll_model.g.dart';

@freezed
class PollModel with _$PollModel {
  const factory PollModel({
    required String id,
    required String question,
    required String type,
    required List<String> options,
    @JsonKey(name: 'entry_fee') required double entryFee,
    @JsonKey(name: 'wallet_kind') required String walletKind,
    required String status,
  }) = _PollModel;

  factory PollModel.fromJson(Map<String, dynamic> json) =>
      _$PollModelFromJson(json);
}
