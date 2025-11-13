import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/providers/capture_service_provider.dart';
import 'package:verzus/providers/service_providers.dart';
import 'package:verzus/providers/notification_service_provider.dart';
import 'package:verzus/providers/ocr_service_provider.dart';
import 'package:verzus/repositories/firebase_repository.dart';
import 'package:verzus/repositories/game_result_repository.dart';
import 'package:verzus/repositories/manual_review_repository.dart';
import 'package:verzus/services/screen_record_service.dart';
import 'package:verzus/models/manual_review_model.dart';
import 'package:verzus/providers/capture_service_provider.dart';
import 'package:verzus/services/screen_record_service.dart';

final screenRecordServiceProvider =
    StateNotifierProvider<ScreenRecordService, RecordingState>((ref) {
  final screenRecordService = ScreenRecordService(
    ref.watch(matchRepositoryProvider),
    ref.watch(gameResultRepositoryProvider),
    ref.watch(manualReviewRepositoryProvider),
    ref.watch(ocrServiceProvider),
    ref.watch(firestoreStorageServiceProvider),
    ref.watch(notificationServiceProvider),
    ref.watch(captureServiceProvider),
  );
  return screenRecordService;
});
