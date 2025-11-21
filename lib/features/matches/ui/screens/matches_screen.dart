import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/core/theme.dart';
import 'package:verzus/features/auth/data/repositories/auth_repository.dart';
import 'package:verzus/features/games/data/repositories/game_repository.dart';
import 'package:verzus/features/matches/data/repositories/match_repository.dart';
import 'package:verzus/models/match_model.dart';
import 'package:verzus/models/wallet_model.dart';
import 'package:verzus/widgets/shimmers.dart';
import 'package:verzus/widgets/verzus_button.dart';

class MatchesScreen extends ConsumerStatefulWidget {
  const MatchesScreen({super.key});

  @override
  ConsumerState<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends ConsumerState<MatchesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _wagerController =
      TextEditingController(text: '5.00');
  String? _selectedGameId;
  String? _selectedGameTitle;
  final bool _isPrivate = false;
  String _mode = 'Live'; // Live or Demo
  MatchFormat _format = MatchFormat.oneVOne; // 1v1, FFA, Team-based

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _wagerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matches'),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Join Match'),
                Tab(text: 'Create Match'),
                Tab(text: 'Live Matches'),
              ],
              labelColor: VerzusColors.primaryPurple,
              unselectedLabelColor:
                  Theme.of(context).colorScheme.onSurfaceVariant,
              indicator: BoxDecoration(
                color: VerzusColors.primaryPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              dividerColor: Colors.transparent,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildJoinMatches(),
                _buildCreateMatchTab(),
                _buildLiveMatches(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinMatches() {
    final matchesStream =
        ref.watch(matchRepositoryProvider).getAvailableMatches();
    return StreamBuilder<List<MatchModel>>(
      stream: matchesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingShimmer();
        }
        if (snapshot.hasError) {
          return _buildErrorNotice(snapshot.error!);
        }
        final matches = snapshot.data ?? [];
        if (matches.isEmpty) {
          return _buildEmptyState(
            icon: Icons.search_rounded,
            title: 'No Open Matches',
            subtitle:
                'Be the first to create a match and challenge other players!',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: matches.length,
          itemBuilder: (context, index) {
            final match = matches[index];
            return _MatchCard(match: match, onJoin: () => _joinMatch(match.id));
          },
        );
      },
    );
  }

  Widget _buildCreateMatchTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 40),
        child: _buildCreateMatchForm(),
      ),
    );
  }

  Widget _buildLiveMatches() {
    // This can be re-implemented once the full feature is scoped.
    return _buildEmptyState(
      icon: Icons.live_tv_rounded,
      title: 'No Live Matches',
      subtitle:
          'Live matches will appear here. You can place stakes on outcomes.',
    );
  }

  Widget _buildCreateMatchForm() {
    final gamesStream = ref.watch(gameRepositoryProvider).getGames();
    final authUser = ref.watch(authRepositoryProvider).currentUser;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create Match',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              StreamBuilder(
                stream: gamesStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const LinearProgressIndicator(minHeight: 2);
                  }
                  final games = snapshot.data!;
                  return DropdownButtonFormField<String>(
                    value: _selectedGameId,
                    items: games
                        .map((g) => DropdownMenuItem<String>(
                              value: g.gameId,
                              child:
                                  Text(g.title, overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedGameId = val;
                        _selectedGameTitle =
                            games.firstWhere((g) => g.gameId == val).title;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Select Game',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _wagerController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Entry Fee (USD)',
                        prefixText: '\$',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    value: _mode,
                    items: const [
                      DropdownMenuItem(value: 'Live', child: Text('Live')),
                      DropdownMenuItem(value: 'Demo', child: Text('Demo')),
                    ],
                    onChanged: (v) => setState(() => _mode = v ?? 'Live'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: VerzusButton(
                  onPressed: () async {
                    if (authUser == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please sign in')));
                      return;
                    }
                    final wager = double.tryParse(_wagerController.text) ?? 0.0;
                    if (_selectedGameId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Select a game')));
                      return;
                    }
                    try {
                      final match = MatchModel(
                        id: '', // Firestore will generate this
                        creatorId: authUser.uid,
                        skillTopic: _selectedGameTitle!,
                        wagerAmount: wager,
                        walletKind: _mode == 'Live'
                            ? WalletKind.live
                            : WalletKind.demo,
                        matchFormat: _format,
                        status: 'pending',
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                        gameData: {
                          'game_id': _selectedGameId,
                          'private': _isPrivate,
                          'mode': _mode.toLowerCase(),
                          'match_type': _format.name,
                        },
                      );
                      await ref.read(matchRepositoryProvider).createMatch(match);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Match created')),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Failed: $e'),
                              backgroundColor: VerzusColors.dangerRed),
                        );
                      }
                    }
                  },
                  child: const Text('Create'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _joinMatch(String matchId) async {
    final authUser = ref.read(authRepositoryProvider).currentUser;
    if (authUser == null) return;
    try {
      await ref
          .read(matchRepositoryProvider)
          .joinMatch(matchId, authUser.uid);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Joined match!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to join: $e'),
              backgroundColor: VerzusColors.dangerRed),
        );
      }
    }
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: VerzusShimmers.listTile(),
        );
      },
    );
  }

  Widget _buildErrorNotice(Object error, {bool compact = false}) {
    final message = error.toString();
    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? 8 : 16),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Theme.of(context).colorScheme.error),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant
                  .withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  final MatchModel match;
  final VoidCallback onJoin;
  const _MatchCard({required this.match, required this.onJoin});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.sports_esports_rounded, color: VerzusColors.primaryPurple),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  match.skillTopic,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text('Wager: \$${match.wagerAmount.toStringAsFixed(2)}',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          VerzusButton(
            onPressed: onJoin,
            size: VerzusButtonSize.medium,
            child: const Text('Join'),
          ),
        ],
      ),
    );
  }
}
