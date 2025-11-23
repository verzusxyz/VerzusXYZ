// ignore: unnecessary_import
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';

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
          withIcon: true, // Fetch icons for better UI
        );
        // Sort by name for better UX
        apps.sort((a, b) => a.name.compareTo(b.name));
        return apps
            .map((app) => DetectedAppInfo(
                  name: app.name,
                  packageId: app.packageName,
                  icon: app.icon,
                ))
            .toList();
      } catch (e) {
        debugPrint('Error scanning apps: $e');
        return [];
      }
    } else {
      // iOS/web/desktop: Not supported
      return [];
    }
  }
}
