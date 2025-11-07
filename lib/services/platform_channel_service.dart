import 'package:flutter/services.dart';

class PlatformChannelService {
  static const MethodChannel _channel = MethodChannel('com.verzusxyz.game_monitoring');

  Future<bool> isAppRunning(String packageId) async {
    try {
      final bool isRunning = await _channel.invokeMethod('isAppRunning', {'packageId': packageId});
      return isRunning;
    } on PlatformException catch (e) {
      print("Failed to check if app is running: '${e.message}'.");
      return false;
    }
  }
}
