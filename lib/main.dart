import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:verzus/theme.dart';
import 'package:verzus/utils/app_router.dart';
import 'package:verzus/firebase_options.dart';
import 'package:verzus/providers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  runApp(const ProviderScope(child: VerzusApp()));
}

class VerzusApp extends ConsumerWidget {
  const VerzusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
