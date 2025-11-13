import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/services/capture_service.dart';

final captureServiceProvider = Provider<CaptureService>((ref) {
  return CaptureService();
});
