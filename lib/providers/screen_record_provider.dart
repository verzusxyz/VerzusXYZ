import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/services/screen_record_service.dart';

final screenRecordServiceProvider = StateNotifierProvider<ScreenRecordService, RecordingState>((ref) {
  return ScreenRecordService();
});
