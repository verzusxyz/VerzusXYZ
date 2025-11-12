import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/repositories/firebase_repository.dart';
import 'package:verzus/repositories/game_result_repository.dart';
import 'package:verzus/services/screen_record_service.dart';

final screenRecordServiceProvider = StateNotifierProvider<ScreenRecordService, RecordingState>((ref) {
  final matchRepository = ref.watch(matchRepositoryProvider);
  final gameResultRepository = ref.watch(gameResultRepositoryProvider);
  return ScreenRecordService(matchRepository, gameResultRepository);
});
