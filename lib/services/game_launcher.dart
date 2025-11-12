import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:verzus/models/game_model.dart';
import 'package.verzus/providers/active_match_provider.dart';
import 'package.verzus/providers/app_detection_provider.dart';
import 'package.verzus/providers/screen_record_provider.dart';
import 'package:verzus/services/app_detection_service.dart';
import 'package:installed_apps/installed_apps.dart';

class GameLauncherService {
  final Ref _ref;

  const GameLauncherService(this._ref);

  Future<void> launchGame(BuildContext context, GameModel game, String matchId) async {
    final screenRecordService = _ref.read(screenRecordServiceProvider.notifier);
    await screenRecordService.startRecording(game, matchId);
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
            final appDetectionService = _ref.read(appDetectionServiceProvider);
            final installedApps = await appDetectionService.scanInstalledApps();
            final isInstalled = installedApps.any((app) => app.packageId == pkg);
            if (isInstalled) {
              InstalledApps.startApp(pkg);
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

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
