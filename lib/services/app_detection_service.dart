// import 'package:flutter/foundation.dart';
// import 'package:flutter/services.dart';

// class DetectedAppInfo {
//   final String name;
//   final String? packageId; // Android
//   final String? bundleId; // iOS

//   const DetectedAppInfo({required this.name, this.packageId, this.bundleId});
// }

// /// Cross-platform app detection facade.
// /// Web/Desktop: returns empty list.
// /// Android/iOS: uses platform channel 'com.verzusxyz.apps' if available.
// class AppDetectionService {
//   static const MethodChannel _channel = MethodChannel('com.verzusxyz.apps');

//   Future<List<DetectedAppInfo>> scanInstalledApps() async {
//     if (kIsWeb) return const [];
//     final platform = defaultTargetPlatform;
//     if (platform != TargetPlatform.android && platform != TargetPlatform.iOS) {
//       return const [];
//     }
//     try {
//       final dynamic result = await _channel.invokeMethod('scanInstalledApps');
//       if (result is List) {
//         return result.map((e) {
//           final map = Map<String, dynamic>.from(e as Map);
//           return DetectedAppInfo(
//             name: (map['name'] ?? '').toString(),
//             packageId: (map['packageId'] as String?)?.trim(),
//             bundleId: (map['bundleId'] as String?)?.trim(),
//           );
//         }).toList();
//       }
//       return const [];
//     } catch (_) {
//       // Channel not implemented yet or permission denied; fall back silently
//       return const [];
//     }
//   }
// }


import 'dart:typed_data';

import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:verzus/services/platform_channel_service.dart';

class DetectedAppInfo {
  final String name;
  final String? packageId;
  final String? bundleId;
  final Uint8List? icon;

  DetectedAppInfo({
    required this.name,
    this.packageId,
    this.bundleId,
    this.icon,
  });
}

class AppDetectionService {
  Future<List<DetectedAppInfo>> scanInstalledApps() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      try {
        List<AppInfo> apps = await InstalledApps.getInstalledApps(
          excludeSystemApps: true,
          excludeNonLaunchableApps: true,
          withIcon: true,  // Fetch icons for better UI
        );
        // Sort by name for better UX
        apps.sort((a, b) => a.name.compareTo(b.name));
        return apps.map((app) => DetectedAppInfo(
              name: app.name,
              packageId: app.packageName,
              icon: app.icon,
            )).toList();
      } catch (e) {
        debugPrint('Error scanning apps: $e');
        return [];
      }
    } else {
      // iOS/web/desktop: Not supported
      return [];
    }
  }

  // New method to monitor if the game is still running
  Stream<bool> isAppRunning(String packageId) {
    final platformChannelService = PlatformChannelService();
    return Stream.periodic(const Duration(seconds: 5), (_) {
      return platformChannelService.isAppRunning(packageId);
    }).asyncMap((event) async => await event).takeWhile((isRunning) => isRunning);
  }
}