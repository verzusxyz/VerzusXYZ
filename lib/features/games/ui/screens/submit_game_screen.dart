import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:verzus/features/games/data/models/game_model.dart';
import 'package:verzus/services/app_detection_service.dart';
import 'package:verzus/services/games_service.dart';
import 'package:verzus/features/games/providers/game_launcher_provider.dart';
import 'package:verzus/utils/responsive.dart';
import 'package:verzus/widgets/shimmers.dart';
import 'package:verzus/widgets/verzus_button.dart';
import 'package:verzus/widgets/verzus_text_field.dart';

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
    if (!mounted) return;
    setState(() => _isMobile = mobile);
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
    final platform = (app.packageId?.isNotEmpty ?? false)
        ? 'android'
        : (app.bundleId?.isNotEmpty ?? false)
            ? 'ios'
            : (defaultTargetPlatform == TargetPlatform.iOS)
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
    await ref.read(gameLauncherProvider).launchGame(context, game);
  }

  Future<void> _submit() async {
    final service = ref.read(gamesServiceProvider);
    setState(() => _isSaving = true);
    try {
      if (_selectedDetected.isNotEmpty) {
        final now = DateTime.now();
        for (final app in _selectedDetected) {
          final platform = (app.packageId?.isNotEmpty ?? false)
              ? 'android'
              : (app.bundleId?.isNotEmpty ?? false)
                  ? 'ios'
                  : (defaultTargetPlatform == TargetPlatform.iOS)
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
            createdAt: now,
            approvedBy: null,
          );
          await service.upsertGameByCanonicalKey(game);
        }
      } else {
        final name = _gameNameCtrl.text.trim();
        if (name.isEmpty) {
          _showError('Enter game name');
          return;
        }
        String? webUrl, packageId, bundleId;
        if (_manualPlatform == 'web') {
          webUrl = _webUrlCtrl.text.trim();
          if (webUrl.isEmpty) {
            _showError('Enter game link for web');
            return;
          }
        } else if (_manualPlatform == 'android') {
          packageId = _packageIdCtrl.text.trim();
          if (packageId.isEmpty) {
            _showError('Enter package ID for Android');
            return;
          }
        } else if (_manualPlatform == 'ios') {
          bundleId = _bundleIdCtrl.text.trim();
          if (bundleId.isEmpty) {
            _showError('Enter bundle ID for iOS');
            return;
          }
        }
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
          createdAt: DateTime.now(),
          approvedBy: null,
        );
        await service.upsertGameByCanonicalKey(game);
      }
      if (!mounted) return;
      context.pop();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Game(s) saved')));
    } catch (e) {
      if (mounted) _showError('Failed to save game(s): $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(String message) {
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Theme.of(context).colorScheme.error,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final theme = Theme.of(context);

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
        child: SingleChildScrollView(
          padding: EdgeInsets.all(responsive.widthPercent(0.04)),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 840),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Add Games',
                      style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: responsive.diagonalPercent(0.025))),
                  SizedBox(height: responsive.heightPercent(0.01)),
                  Text(
                    _isMobile
                        ? 'Select installed games (Android/iOS), or add manually.'
                        : 'Add a game manually (web/desktop).',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(fontSize: responsive.diagonalPercent(0.016)),
                  ),
                  SizedBox(height: responsive.heightPercent(0.02)),
                  if (_isMobile) ...[
                    _buildSectionHeader(context, responsive, 'Auto-detected'),
                    SizedBox(height: responsive.heightPercent(0.01)),
                    _buildDetectedAppsList(context, responsive),
                    SizedBox(height: responsive.heightPercent(0.025)),
                    _buildDivider(context, responsive),
                    SizedBox(height: responsive.heightPercent(0.015)),
                  ],
                  _buildSectionHeader(context, responsive, 'Manual Entry'),
                  SizedBox(height: responsive.heightPercent(0.01)),
                  _buildManualEntryForm(context, responsive),
                  SizedBox(height: responsive.heightPercent(0.03)),
                  Align(
                    alignment: Alignment.center,
                    child: VerzusButton(
                      onPressed: _isSaving ? null : _submit,
                      isLoading: _isSaving,
                      width: responsive.widthPercent(0.6),
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, Responsive responsive, String title) {
    return Text(title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: responsive.diagonalPercent(0.02)));
  }

  Widget _buildDivider(BuildContext context, Responsive responsive) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding:
              EdgeInsets.symmetric(horizontal: responsive.widthPercent(0.02)),
          child: Text('or', style: Theme.of(context).textTheme.bodySmall),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildDetectedAppsList(BuildContext context, Responsive responsive) {
    if (_detecting) {
      return Column(
        children: List.generate(
            3,
            (index) => Padding(
                  padding:
                      EdgeInsets.only(bottom: responsive.heightPercent(0.015)),
                  child: VerzusShimmers.listTile(),
                )),
      );
    }
    if (_detectedApps.isEmpty) {
      return Container(
        padding: EdgeInsets.all(responsive.diagonalPercent(0.015)),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius:
              BorderRadius.circular(responsive.diagonalPercent(0.015)),
        ),
        child:
            const Text('No supported games detected. Use manual entry below.'),
      );
    }
    return Column(
      children: [
        ..._detectedApps
            .map((app) => _buildAppListItem(context, responsive, app)),
        if (_selectedDetected.isNotEmpty) ...[
          SizedBox(height: responsive.heightPercent(0.01)),
          VerzusButton.outline(
            onPressed: () async {
              for (final app in _selectedDetected) {
                await _launchSelected(app);
              }
            },
            child: const Text('Launch Selected'),
          ),
        ],
      ],
    );
  }

  Widget _buildAppListItem(
      BuildContext context, Responsive responsive, DetectedAppInfo app) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.only(bottom: responsive.heightPercent(0.015)),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(responsive.diagonalPercent(0.015)),
      ),
      child: ListTile(
        leading: app.icon != null
            ? CircleAvatar(backgroundImage: MemoryImage(app.icon!))
            : CircleAvatar(
                // ignore: deprecated_member_use
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                child: Icon(Icons.videogame_asset,
                    color: theme.colorScheme.primary),
              ),
        title: Text(app.name,
            style: TextStyle(fontSize: responsive.diagonalPercent(0.018))),
        subtitle: Text(app.packageId ?? app.bundleId ?? '',
            style: TextStyle(fontSize: responsive.diagonalPercent(0.014))),
        trailing: Checkbox(
          value: _selectedDetected.contains(app),
          onChanged: (value) => _toggleAppSelection(app),
        ),
        onTap: () => _toggleAppSelection(app),
        onLongPress: () => _launchSelected(app),
      ),
    );
  }

  void _toggleAppSelection(DetectedAppInfo app) {
    setState(() {
      if (_selectedDetected.contains(app)) {
        _selectedDetected.remove(app);
      } else {
        _selectedDetected.add(app);
      }
    });
  }

  Widget _buildManualEntryForm(BuildContext context, Responsive responsive) {
    final theme = Theme.of(context);
    return Column(
      children: [
        DropdownButtonFormField<String>(
          value: _manualPlatform,
          decoration: InputDecoration(
            labelText: 'Platform',
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(responsive.diagonalPercent(0.015)),
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
          ),
          items: ['web', 'android', 'ios']
              .map((p) =>
                  DropdownMenuItem(value: p, child: Text(p.toUpperCase())))
              .toList(),
          onChanged: (value) {
            if (value != null) setState(() => _manualPlatform = value);
          },
        ),
        SizedBox(height: responsive.heightPercent(0.015)),
        VerzusTextField(controller: _gameNameCtrl, label: 'Game Name'),
        SizedBox(height: responsive.heightPercent(0.015)),
        if (_manualPlatform == 'web')
          VerzusTextField(
              controller: _webUrlCtrl,
              label: 'Game Link (e.g., https://chess.com/...)'),
        if (_manualPlatform == 'android')
          VerzusTextField(
              controller: _packageIdCtrl,
              label: 'Android Package ID (e.g., com.example.game)'),
        if (_manualPlatform == 'ios')
          VerzusTextField(
              controller: _bundleIdCtrl,
              label: 'iOS Bundle ID (e.g., com.example.game)'),
      ],
    );
  }
}
