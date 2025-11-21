import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/models/game_model.dart';
import 'package:verzus/services/auth_service.dart';
import 'package:verzus/services/games_service.dart';
import 'package:verzus/theme.dart';
import 'package:verzus/widgets/verzus_button.dart';
import 'package:verzus/widgets/shimmers.dart';
import 'package:verzus/models/match_model.dart';
import 'package:verzus/services/match_service.dart';
import 'package:verzus/services/result_tracker.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildErrorNotice(BuildContext context, Object error) {
    final theme = Theme.of(context);
    final message = error.toString().trim().isEmpty
        ? 'Unable to load data. Please try again.'
        : error.toString();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.error),
        ),
      ),
    );
  }

  bool get _isAdmin {
    final auth = ref.read(authStateProvider).value;
    final u = ref.read(currentUserProvider).value;
    // Admin if user role == 'admin' or email domain is verzus.xyz (fallback)
    final email = auth?.email ?? u?.email ?? '';
    return email.endsWith('@verzus.xyz');
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin')),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: VerzusColors.dangerRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: VerzusColors.dangerRed.withValues(alpha: 0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_rounded, color: VerzusColors.dangerRed),
                const SizedBox(height: 12),
                const Text('Not authorized'),
                const SizedBox(height: 4),
                const Text(
                    'Your account is not permitted to access the admin dashboard.'),
              ],
            ),
          ),
        ),
      );
    }

    final gamesAsync = ref.watch(gamesStreamProvider);
    final disputesAsync = ref.watch(disputedMatchesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Games'),
            Tab(text: 'Disputes'),
            Tab(text: 'System'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Games
          gamesAsync.when(
            data: (list) => _buildGamesTab(context, list),
            loading: () => ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (_, __) => VerzusShimmers.listTile(),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: 6,
            ),
            error: (e, _) => _buildErrorNotice(context, e),
          ),
          // Disputes
          disputesAsync.when(
            data: (list) => _buildDisputesTab(context, list),
            loading: () => ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (_, __) => VerzusShimmers.card(height: 160),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: 4,
            ),
            error: (e, _) => _buildErrorNotice(context, e),
          ),
          // System
          _buildSystemTab(context),
        ],
      ),
    );
  }

  Widget _buildGamesTab(BuildContext context, List<GameModel> list) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, i) {
        final g = list[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.sports_esports_rounded,
                  color: VerzusColors.primaryPurple),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      g.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(g.platform.toUpperCase(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant)),
                  ],
                ),
              ),
              VerzusButton.outline(
                onPressed: () =>
                    ref.read(gamesServiceProvider).deleteGame(g.gameId),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDisputesTab(BuildContext context, List<MatchModel> list) {
    if (list.isEmpty) {
      return const Center(child: Text('No disputes'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, i) {
        final m = list[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.gavel_rounded, color: VerzusColors.primaryPurple),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dispute: ${m.id}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Creator vs Opponent • Wager: ${m.wagerAmount.toStringAsFixed(2)} • Mode: ${m.gameMode}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: VerzusColors.warningYellow.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      m.status.displayName,
                      style: TextStyle(
                          color: VerzusColors.warningYellow,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: VerzusButton(
                      onPressed: () async {
                        await ref.read(resultTrackerProvider).resolveDispute(
                              matchId: m.id,
                              winnerUserId: m.creatorId,
                            );
                      },
                      child: const Text('Award Creator'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: VerzusButton(
                      onPressed: m.opponentId == null
                          ? null
                          : () async {
                              await ref
                                  .read(resultTrackerProvider)
                                  .resolveDispute(
                                    matchId: m.id,
                                    winnerUserId: m.opponentId!,
                                  );
                            },
                      child: const Text('Award Opponent'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              VerzusButton.outline(
                onPressed: () async {
                  await ref
                      .read(resultTrackerProvider)
                      .refundDispute(matchId: m.id);
                },
                child: const Text('Refund Both (Tie)'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSystemTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('System Settings',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('• Platform fee: 10% (fixed for demo)'),
                Text('• Min wager: \$1.00'),
                Text('• Max wager: \$1000.00'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: unused_element
class _SamplePreview extends StatelessWidget {
  final String imageUrl;
  final DefaultCropData? crop;
  // ignore: unused_element_parameter
  const _SamplePreview({required this.imageUrl, this.crop});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(imageUrl, fit: BoxFit.cover),
            if (crop != null) ...[
              _RectOverlay(
                  rect: crop!.scoreRect,
                  color: Colors.green.withValues(alpha: 0.35),
                  label: 'Score'),
              _RectOverlay(
                  rect: crop!.usernameRect,
                  color: Colors.blue.withValues(alpha: 0.35),
                  label: 'Username'),
            ]
          ],
        ),
      ),
    );
  }
}

class _RectOverlay extends StatelessWidget {
  final CropRect rect;
  final Color color;
  final String label;
  const _RectOverlay(
      {required this.rect, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: rect.x,
      top: rect.y,
      width: rect.width,
      height: rect.height,
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 2),
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Align(
            alignment: Alignment.topLeft,
            child: Container(
              margin: const EdgeInsets.all(4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(label,
                  style: const TextStyle(color: Colors.white, fontSize: 10)),
            ),
          ),
        ),
      ),
    );
  }
}
