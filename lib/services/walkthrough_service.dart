import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

final walkthroughServiceProvider = Provider<WalkthroughService>((ref) {
  return WalkthroughService();
});

class WalkthroughService {
  static const String _walkthroughCompletedKey = 'walkthroughCompleted';
  static const String _walkthroughCurrentStepKey = 'walkthroughCurrentStep';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _prefsInstance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<bool> shouldShowWalkthrough() async {
    final prefs = await _prefsInstance;
    return prefs.getBool(_walkthroughCompletedKey) ?? true;
  }

  Future<void> completeWalkthrough() async {
    final prefs = await _prefsInstance;
    await prefs.setBool(_walkthroughCompletedKey, false);
  }

  Future<void> restartWalkthrough() async {
    final prefs = await _prefsInstance;
    await prefs.setBool(_walkthroughCompletedKey, true);
    await prefs.setInt(_walkthroughCurrentStepKey, 0);
  }

  Future<int> getCurrentStep() async {
    final prefs = await _prefsInstance;
    return prefs.getInt(_walkthroughCurrentStepKey) ?? 0;
  }

  Future<void> setCurrentStep(int step) async {
    final prefs = await _prefsInstance;
    await prefs.setInt(_walkthroughCurrentStepKey, step);
  }

  void startWalkthrough(BuildContext context, List<GlobalKey> keys) {
    ShowCaseWidget.of(context).startShowCase(keys);
  }
}
