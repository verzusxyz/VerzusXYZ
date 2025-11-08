import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/services/screen_record_service.dart';

final screenRecordServiceProvider = StateNotifierProvider<ScreenRecordService, bool>((ref) {
  return ScreenRecordService();
});
