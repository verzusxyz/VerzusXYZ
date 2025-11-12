import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/services/game_launcher.dart';

final gameLauncherServiceProvider = Provider<GameLauncherService>((ref) {
  return GameLauncherService(ref);
});
