import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/services/game_launcher.dart';
import 'package:verzus/services/screen_record_service.dart';

final gameLauncherProvider = Provider((ref) {
  final screenRecordService = ref.watch(screenRecordServiceProvider);
  return GameLauncherService(screenRecordService);
});
