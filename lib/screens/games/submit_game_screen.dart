// ignore: unused_import
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:verzus/models/game_model.dart';
import 'package:verzus/services/app_detection_service.dart';
import 'package:verzus/services/games_service.dart';
import 'package:verzus/services/game_launcher.dart';
import 'package:verzus/theme.dart';
import 'package:verzus/widgets/shimmers.dart';
import 'package:verzus/widgets/verzus_button.dart';

class SubmitGameScreen extends ConsumerStatefulWidget {
  const SubmitGameScreen({super.key});

  @override
  ConsumerState<SubmitGameScreen> createState() => _SubmitGameScreenState();
}

class _SubmitGameScreenState extends ConsumerState<SubmitGameScreen> {
  bool _isSaving = false;
  bool _isMobile = false;
  bool _detecting = false;
  List<DetectedAppInfo> _detectedApps = [];
  final Set<DetectedAppInfo> _selectedDetected = {};

  String _manualPlatform = 'web'; // Default for manual
  final _gameNameCtrl = TextEditingController();
  final _webUrlCtrl = TextEditingController();
  final _packageIdCtrl = TextEditingController();
  final _bundleIdCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final mobile = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    setState(() {
      _isMobile = mobile;
    });
    if (mobile) {
      setState(() => _detecting = true);
      final apps = await AppDetectionService().scanInstalledApps();
      if (!mounted) return;
      setState(() {
        _detectedApps = apps;
        _detecting = false;
      });
    }
  }

  @override
  void dispose() {
    _gameNameCtrl.dispose();
    _webUrlCtrl.dispose();
    _packageIdCtrl.dispose();
    _bundleIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _launchSelected(DetectedAppInfo app) async {
    final platform = (app.packageId != null && app.packageId!.isNotEmpty)
        ? 'android'
        : (app.bundleId != null && app.bundleId!.isNotEmpty)
            ? 'ios'
            : (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS)
                ? 'ios'
                : 'android';

    final game = GameModel(
      gameId: 'temp',
      title: app.name,
      platform: platform,
      packageId: app.packageId,
      bundleId: app.bundleId,
      webUrl: null,
      iconUrl: null,
      defaultCropData: null,
      autoGenEnabled: true,
      popularityScore: 0,
      supportsRoomUrl: false,
      supportsRoomCode: false,
      supportsBoardState: false,
      roomIdPatterns: const [],
      createdAt: DateTime.now(),
      approvedBy: null,
    );

    await const GameLauncherService().launchGame(context, game);
  }

  Future<void> _submit() async {
    final service = ref.read(gamesServiceProvider);
    setState(() => _isSaving = true);

    try {
      if (_selectedDetected.isNotEmpty) {
        // Submit all selected detected apps
        final now = DateTime.now();
        for (final app in _selectedDetected) {
          final platform = (app.packageId != null && app.packageId!.isNotEmpty)
              ? 'android'
              : (app.bundleId != null && app.bundleId!.isNotEmpty)
                  ? 'ios'
                  : (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS)
                      ? 'ios'
                      : 'android';
          final game = GameModel(
            gameId: 'temp', // Replaced by canonical key
            title: app.name,
            platform: platform,
            packageId: app.packageId,
            bundleId: app.bundleId,
            webUrl: null,
            iconUrl: null,
            defaultCropData: null,
            autoGenEnabled: true,
            popularityScore: 0,
            supportsRoomUrl: false,
            supportsRoomCode: false,
            supportsBoardState: false,
            roomIdPatterns: const [],
            createdAt: now,
            approvedBy: null,
          );
          await service.upsertGameByCanonicalKey(game);
        }
      } else {
        // Manual entry
        final name = _gameNameCtrl.text.trim();
        if (name.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Enter game name')),
          );
          setState(() => _isSaving = false);
          return;
        }

        String? webUrl;
        String? packageId;
        String? bundleId;

        if (_manualPlatform == 'web') {
          webUrl = _webUrlCtrl.text.trim();
          if (webUrl.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Enter game link for web')),
            );
            setState(() => _isSaving = false);
            return;
          }
        } else if (_manualPlatform == 'android') {
          packageId = _packageIdCtrl.text.trim();
          if (packageId.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Enter package ID for Android')),
            );
            setState(() => _isSaving = false);
            return;
          }
        } else if (_manualPlatform == 'ios') {
          bundleId = _bundleIdCtrl.text.trim();
          if (bundleId.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Enter bundle ID for iOS')),
            );
            setState(() => _isSaving = false);
            return;
          }
        }

        final now = DateTime.now();
        final game = GameModel(
          gameId: 'temp',
          title: name,
          platform: _manualPlatform,
          packageId: packageId,
          bundleId: bundleId,
          webUrl: webUrl,
          iconUrl: null,
          defaultCropData: null,
          autoGenEnabled: true,
          popularityScore: 0,
          supportsRoomUrl: _manualPlatform == 'web',
          supportsRoomCode: false,
          supportsBoardState: false,
          roomIdPatterns: const [],
          createdAt: now,
          approvedBy: null,
        );
        await service.upsertGameByCanonicalKey(game);
      }

      if (!mounted) return;
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Game(s) saved')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save game(s): $e'),
          backgroundColor: VerzusColors.dangerRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
          tooltip: 'Back',
        ),
        title: const Text('Add Games'),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 720;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isWide ? 840 : 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Add Games',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _isMobile
                            ? 'Select installed games (Android/iOS), or add manually.'
                            : 'Add a game manually (web/desktop).',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 16),
                      if (_isMobile) ...[
                        Text(
                          'Auto-detected',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        _detecting
                            ? Column(
                                children: [
                                  VerzusShimmers.listTile(),
                                  const SizedBox(height: 12),
                                  VerzusShimmers.listTile(),
                                  const SizedBox(height: 12),
                                  VerzusShimmers.listTile(),
                                ],
                              )
                            : _detectedApps.isEmpty
                                ? Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                        'No supported games detected. Use manual entry below.'),
                                  )
                                : Column(
                                    children: [
                                      for (final app in _detectedApps)
                                        Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 12),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHighest,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: ListTile(
                                            leading: app.icon != null
                                                ? CircleAvatar(
                                                    backgroundImage:
                                                        MemoryImage(app.icon!),
                                                  )
                                                : CircleAvatar(
                                                    backgroundColor: Colors.blue
                                                        .withValues(
                                                            alpha: 0.15),
                                                    child: const Icon(
                                                        Icons.videogame_asset,
                                                        color: Colors.blue),
                                                  ),
                                            title: Text(app.name),
                                            subtitle: Text(app.packageId ??
                                                app.bundleId ??
                                                ''),
                                            trailing: Checkbox(
                                              value: _selectedDetected
                                                  .contains(app),
                                              onChanged: (bool? value) {
                                                setState(() {
                                                  if (value == true) {
                                                    _selectedDetected.add(app);
                                                  } else {
                                                    _selectedDetected
                                                        .remove(app);
                                                  }
                                                });
                                              },
                                            ),
                                            onTap: () => setState(() {
                                              if (_selectedDetected
                                                  .contains(app)) {
                                                _selectedDetected.remove(app);
                                              } else {
                                                _selectedDetected.add(app);
                                              }
                                            }),
                                            onLongPress: () =>
                                                _launchSelected(app),
                                          ),
                                        ),
                                      if (_selectedDetected.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        SizedBox(
                                          width: 220,
                                          child: VerzusButton.outline(
                                            onPressed: () async {
                                              for (final app
                                                  in _selectedDetected) {
                                                await _launchSelected(app);
                                              }
                                            },
                                            child:
                                                const Text('Launch Selected'),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                        const SizedBox(height: 20),
                        Row(
                          children: const [
                            Expanded(child: Divider()),
                            SizedBox(width: 8),
                            Text('or'),
                            SizedBox(width: 8),
                            Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                      Text(
                        'Manual Entry',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      DropdownButton<String>(
                        value: _manualPlatform,
                        onChanged: (String? value) {
                          if (value != null) {
                            setState(() => _manualPlatform = value);
                          }
                        },
                        items: ['web', 'android', 'ios']
                            .map<DropdownMenuItem<String>>((String platform) {
                          return DropdownMenuItem<String>(
                            value: platform,
                            child: Text(platform.toUpperCase()),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _gameNameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Game Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_manualPlatform == 'web')
                        TextField(
                          controller: _webUrlCtrl,
                          decoration: const InputDecoration(
                            labelText:
                                'Game Link (e.g., https://chess.com/...)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      if (_manualPlatform == 'android')
                        TextField(
                          controller: _packageIdCtrl,
                          decoration: const InputDecoration(
                            labelText:
                                'Android Package ID (e.g., com.example.game)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      if (_manualPlatform == 'ios')
                        TextField(
                          controller: _bundleIdCtrl,
                          decoration: const InputDecoration(
                            labelText: 'iOS Bundle ID (e.g., com.example.game)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: 260,
                        child: VerzusButton(
                          onPressed: _isSaving ? null : _submit,
                          isLoading: _isSaving,
                          child: const Text('Submit'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
