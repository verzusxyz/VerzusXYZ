import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/services/app_detection_service.dart';

final appDetectionServiceProvider = Provider<AppDetectionService>((ref) {
  return AppDetectionService();
});
