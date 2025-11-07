import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:verzus/models/game_model.dart';
import 'package:verzus/services/screen_record_service.dart';
import 'package:verzus/services/app_detection_service.dart';
import 'dart:async';

class GameLauncherService {
  const GameLauncherService();

  Future<void> launchGame(BuildContext context, GameModel game) async {
    final screenRecordService = ScreenRecordService();
    final appDetectionService = AppDetectionService();

    try {
      // Start recording before launching the game
      await screenRecordService.startRecording(game.title);

      switch (game.platform) {
        case 'web':
          final url = game.webUrl;
          if (url != null && url.isNotEmpty) {
            final ok = await launchUrlString(url, mode: LaunchMode.externalApplication);
            if (ok) {
              _monitorGame(game);
            } else {
              _toast(context, 'Could not open ${game.title}');
            }
          } else {
            _toast(context, 'No URL available for this game');
          }
          break;
        case 'android':
          final pkg = game.packageId;
          if (pkg != null && pkg.isNotEmpty) {
            final playUrl = 'https://play.google.com/store/apps/details?id=$pkg';
            final ok = await launchUrlString(playUrl, mode: LaunchMode.externalApplication);
            if (ok) {
              _monitorGame(game);
            } else {
              _toast(context, 'Could not open Play Store for ${game.title}');
            }
          } else {
            _toast(context, 'Android package id missing');
          }
          break;
        case 'ios':
          // For iOS, we can't launch the game directly, but we can start the monitoring.
          _toast(context, 'On iOS, launch the game from your home screen. Recording will stop automatically.');
          _monitorGame(game);
          break;
        default:
          _toast(context, 'Unsupported platform: ${game.platform}');
      }
    } catch (e) {
      _toast(context, 'Launch failed: $e');
    }
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _monitorGame(GameModel game) {
    final screenRecordService = ScreenRecordService();
    final appDetectionService = AppDetectionService();

    if (game.packageId != null) {
      final runningStream = appDetectionService.isAppRunning(game.packageId!);
      runningStream.listen(
        (isRunning) {
          debugPrint('Game is running: $isRunning');
        },
        onDone: () {
          debugPrint('Game has closed. Stopping recording.');
          screenRecordService.stopRecording(game.gameId);
        },
      );
    } else {
      // For web and iOS, we don't have a reliable way to detect game closure.
      // We'll stop the recording after a fixed duration as a fallback.
      Timer(const Duration(minutes: 30), () {
        debugPrint('Stopping recording after 30 minutes for web/iOS game.');
        screenRecordService.stopRecording(game.gameId);
      });
    }
  }
}
