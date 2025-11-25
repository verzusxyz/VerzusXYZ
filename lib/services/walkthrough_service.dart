import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

class WalkthroughService {
  final SharedPreferences _prefs;

  WalkthroughService(this._prefs);

  // Define keys for each walkthrough step
  final GlobalKey gamesTabKey = GlobalKey();
  final GlobalKey createMatchKey = GlobalKey();
  final GlobalKey wagerFieldKey = GlobalKey();
  final GlobalKey walletBalanceKey = GlobalKey();
  final GlobalKey notificationsTabKey = GlobalKey();

  // Define flags to track completion
  static const String mainWalkthroughCompleteFlag = 'mainWalkthroughComplete';

  bool isMainWalkthroughComplete() {
    return _prefs.getBool(mainWalkthroughCompleteFlag) ?? false;
  }

  Future<void> completeMainWalkthrough() async {
    await _prefs.setBool(mainWalkthroughCompleteFlag, true);
  }

  void startMainWalkthrough(BuildContext context) {
    if (isMainWalkthroughComplete()) return;

    // This needs to be called after the build method is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ShowCaseWidget.of(context).startShowCase([
        gamesTabKey,
        createMatchKey,
        wagerFieldKey,
        walletBalanceKey,
        notificationsTabKey,
      ]);
    });
  }
}

// Provider for SharedPreferences
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

// Provider for WalkthroughService
final walkthroughServiceProvider = Provider<WalkthroughService?>((ref) {
  final prefsAsync = ref.watch(sharedPreferencesProvider);
  return prefsAsync.when(
    data: (prefs) => WalkthroughService(prefs),
    loading: () => null,
    error: (_, __) => null,
  );
});
