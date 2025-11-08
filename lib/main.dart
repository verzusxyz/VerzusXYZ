import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:verzus/theme.dart';
import 'package:verzus/utils/app_router.dart';
import 'package:verzus/firebase_options.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:verzus/providers/active_match_provider.dart';
import 'package:verzus/providers/firebase_providers.dart';
import 'package:verzus/providers/screen_record_provider.dart';
import 'package:verzus/services/firebase_initialization_service.dart';
import 'package:verzus/providers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelGroupKey: 'basic_channel_group',
        channelKey: 'basic_channel',
        channelName: 'Basic notifications',
        channelDescription: 'Notification channel for basic tests',
        defaultColor: const Color(0xFF9D50DD),
        ledColor: Colors.white,
      )
    ],
    channelGroups: [
      NotificationChannelGroup(
        channelGroupKey: 'basic_channel_group',
        channelGroupName: 'Basic group',
      )
    ],
    debug: true,
  );
  
  // Initialize Firebase with platform options (required on Web)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Log but continue to run to avoid crashing the app in preview
    // Most features will require Firebase to be configured
    // Ensure your Firebase connection is complete in Dreamflow Firebase panel
    // before testing auth and Firestore-dependent flows.
    // ignore: avoid_print
    print('Firebase initialization failed: $e');
  }
  
  runApp(const ProviderScope(child: VerzusApp()))
;}

class VerzusApp extends ConsumerStatefulWidget {
  const VerzusApp({super.key});

  @override
  ConsumerState<VerzusApp> createState() => _VerzusAppState();
}

class _VerzusAppState extends ConsumerState<VerzusApp> {
  @override
  void initState() {
    super.initState();
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: (receivedAction) async {
        if (receivedAction.buttonKeyPressed == 'STOP_RECORDING') {
          final activeMatch = ref.read(activeMatchProvider);
          if (activeMatch != null) {
            ref.read(screenRecordServiceProvider.notifier).stopRecordingAndProcess(activeMatch.game, activeMatch.matchId);
            ref.read(activeMatchProvider.notifier).state = null;
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'VerzusXYZ - Skill Competition Arena',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
