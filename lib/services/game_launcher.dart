// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:verzus/models/game_model.dart';

class GameLauncherService {
  const GameLauncherService();

  Future<void> launchGame(BuildContext context, GameModel game) async {
    try {
      switch (game.platform) {
        case 'web':
          final url = game.webUrl;
          if (url != null && url.isNotEmpty) {
            final ok = await launchUrlString(url,
                mode: LaunchMode.externalApplication);
            // ignore: use_build_context_synchronously
            if (!ok) _toast(context, 'Could not open ${game.title}');
          } else {
            _toast(context, 'No URL available for this game');
          }
          break;
        case 'android':
          // Without platform channels, fall back to Play Store listing
          final pkg = game.packageId;
          if (pkg != null && pkg.isNotEmpty) {
            final playUrl =
                'https://play.google.com/store/apps/details?id=$pkg';
            final ok = await launchUrlString(playUrl,
                mode: LaunchMode.externalApplication);
            if (!ok) {
              // ignore: use_build_context_synchronously
              _toast(context, 'Could not open Play Store for ${game.title}');
            }
          } else {
            _toast(context, 'Android package id missing');
          }
          break;
        case 'ios':
          // Opening by bundleId requires App Store numeric id; show guidance.
          _toast(context,
              'On iOS, launch the game from your home screen. ReplayKit will handle capture.');
          break;
        default:
          _toast(context, 'Unsupported platform: ${game.platform}');
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      _toast(context, 'Launch failed: $e');
    }
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
