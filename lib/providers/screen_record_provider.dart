import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/providers/capture_service_provider.dart';
import 'package:verzus/providers/firestore_storage_service_provider.dart';
import 'package:verzus/providers/notification_service_provider.dart';
import 'package:verzus/providers/ocr_service_provider.dart';
import 'package:verzus/repositories/firebase_repository.dart';
import 'package:verzus/repositories/game_result_repository.dart';
import 'package:verzus/services/screen_record_service.dart';

final screenRecordServiceProvider = StateNotifierProvider<ScreenRecordService, RecordingState>((ref) {
  final matchRepository = ref.watch(matchRepositoryProvider);
  final gameResultRepository = ref.watch(gameResultRepositoryProvider);
  final manualReviewRepository = ref.watch(manualReviewRepositoryProvider);
  final ocrService = ref.watch(ocrServiceProvider);
  final storageService = ref.watch(firestoreStorageServiceProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  final captureService = ref.watch(captureServiceProvider);

  return ScreenRecordService(
    matchRepository: matchRepository,
    gameResultRepository: gameResultRepository,
    manualReviewRepository: manualReviewRepository,
    ocrService: ocrService,
    storageService: storageService,
    notificationService: notificationService,
    captureService: captureService,
  );
});
