import 'dart:async';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:verzus/models/game_model.dart';
import 'package:verzus/providers/active_match_provider.dart';
import 'package:verzus/providers/screen_record_provider.dart';

class GameLauncherService {
  final Ref _ref;

  const GameLauncherService(this._ref);

  Future<void> launchGame(BuildContext context, GameModel game, String matchId) async {
    final screenRecordService = _ref.read(screenRecordServiceProvider.notifier);
    await screenRecordService.startRecording(game.gameId);
    _ref.read(activeMatchProvider.notifier).state = ActiveMatch(game: game, matchId: matchId);

    try {
      switch (game.platform) {
        case 'web':
          final url = game.webUrl;
          if (url != null && url.isNotEmpty) {
            final ok = await launchUrlString(url, mode: LaunchMode.externalApplication);
            if (!ok) _toast(context, 'Could not open ${game.title}');
          } else {
            _toast(context, 'No URL available for this game');
          }
          break;
        case 'android':
          final pkg = game.packageId;
          if (pkg != null && pkg.isNotEmpty) {
            final isInstalled = await DeviceApps.isAppInstalled(pkg);
            if (isInstalled) {
              DeviceApps.openApp(pkg);
              _monitorAppClosure(game);
            } else {
              final playUrl = 'https://play.google.com/store/apps/details?id=$pkg';
              final ok = await launchUrlString(playUrl, mode: LaunchMode.externalApplication);
              if (!ok) _toast(context, 'Could not open Play Store for ${game.title}');
            }
          } else {
            _toast(context, 'Android package id missing');
          }
          break;
        case 'ios':
          // On iOS, we can't launch the app directly.
          // The user has to open it manually.
          _toast(context, 'On iOS, launch the game from your home screen. ReplayKit will handle capture.');
          break;
        default:
          _toast(context, 'Unsupported platform: ${game.platform}');
      }
    } catch (e) {
      _toast(context, 'Launch failed: $e');
    }
  }

  void _monitorAppClosure(GameModel game) {
    // This is a simplified implementation. A more robust solution would
    // involve a background service that monitors running apps.
    // Timer.periodic(const Duration(seconds: 5), (timer) async {
    //   final isRunning = await DeviceApps.isAppInstalled(game.packageId!);
    //   if (!isRunning) {
    //     final screenRecordService = _ref.read(screenRecordServiceProvider.notifier);
    //     screenRecordService.stopRecordingAndProcess(game, _ref.read(activeMatchProvider)!.matchId);
    //     timer.cancel();
    //   }
    // });
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
