import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package.shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

final walkthroughServiceProvider = Provider<WalkthroughService>((ref) {
  return WalkthroughService();
});

class WalkthroughService {
  static const String _walkthroughCompletedKey = 'walkthroughCompleted';
  static const String _walkthroughCurrentStepKey = 'walkthroughCurrentStep';

  Future<bool> shouldShowWalkthrough() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_walkthroughCompletedKey) ?? true;
  }

  Future<void> completeWalkthrough() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_walkthroughCompletedKey, false);
  }

  Future<void> restartWalkthrough() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_walkthroughCompletedKey, true);
    await prefs.setInt(_walkthroughCurrentStepKey, 0);
  }

  Future<int> getCurrentStep() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_walkthroughCurrentStepKey) ?? 0;
  }

  Future<void> setCurrentStep(int step) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_walkthroughCurrentStepKey, step);
  }

  void startWalkthrough(BuildContext context, List<GlobalKey> keys) {
    ShowCaseWidget.of(context).startShowCase(keys);
  }
}
