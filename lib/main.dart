import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:verzus/core/providers/theme_provider.dart';
import 'package:verzus/core/services/firebase_service.dart';
import 'package:verzus/theme.dart';
import 'package:verzus/utils/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.instance.initialize();
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
      builder: (context, child) {
        return ShowCaseWidget(
          builder: Builder(builder: (context) => child!),
        );
      },
    );
  }
}
