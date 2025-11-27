import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:verzus/features/auth/data/repositories/auth_repository.dart';
import 'package:verzus/features/games/data/models/game_model.dart';
import 'package:verzus/features/games/data/repositories/game_repository.dart';
import 'package:verzus/features/matches/data/models/match_model.dart';
import 'package:verzus/features/matches/data/repositories/match_repository.dart';
import 'package:verzus/features/wallet/data/models/wallet_model.dart';
import 'package:verzus/features/wallet/providers/wallet_provider.dart';
import 'package:verzus/services/walkthrough_service.dart';
import 'package:verzus/utils/responsive.dart';
import 'package:verzus/widgets/shimmers.dart';
import 'package:verzus/widgets/verzus_button.dart';
import 'package:verzus/widgets/verzus_text_field.dart';
import 'package:verzus/widgets/wallet_toggle.dart';

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
  GameModel? _selectedGame;
  bool _isPrivate = false;

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
    final responsive = Responsive(context);
    final theme = Theme.of(context);
    final walkthroughService = ref.watch(walkthroughServiceProvider);
    final walletMode = ref.watch(walletModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matches'),
        actions: [
          WalletToggle(
            groupValue: walletMode,
            onSelectionChanged: (value) {
              ref.read(walletModeProvider.notifier).state = value;
            },
          ),
          Showcase(
            key: walkthroughService!.leaderboardKey,
            description: 'Check the leaderboards to see who is on top!',
            child: IconButton(
              icon: const Icon(Icons.leaderboard),
              onPressed: () => context.go('/leaderboards'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin:
                EdgeInsets.symmetric(horizontal: responsive.widthPercent(0.04)),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius:
                  BorderRadius.circular(responsive.diagonalPercent(0.015)),
            ),
            child: TabBar(
              controller: _tabController,
              tabs: [
                const Tab(text: 'Join Match'),
                Tab(
                  child: Showcase(
                    key: walkthroughService.createMatchKey,
                    description: 'Tap here to create your own match!',
                    child: const Text('Create Match'),
                  ),
                ),
                const Tab(text: 'Live Matches'),
              ],
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
              indicator: BoxDecoration(
                // ignore: deprecated_member_use
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(responsive.diagonalPercent(0.012)),
              ),
              dividerColor: Colors.transparent,
            ),
          ),
          SizedBox(height: responsive.heightPercent(0.025)),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildJoinMatches(responsive),
                _buildCreateMatchTab(responsive),
                _buildLiveMatches(responsive),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinMatches(Responsive responsive) {
    final walletMode = ref.watch(walletModeProvider);
    final matchesStream = ref
        .watch(matchRepositoryProvider)
        .getAvailableMatches(WalletKind: walletMode);
    return StreamBuilder<List<MatchModel>>(
      stream: matchesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingShimmer(responsive);
        }
        if (snapshot.hasError) return _buildErrorNotice(snapshot.error!);
        final matches = snapshot.data ?? [];
        if (matches.isEmpty) {
          return _buildEmptyState(responsive,
              icon: Icons.search,
              title: 'No Open Matches',
              subtitle:
                  'Be the first to create a match and challenge other players!');
        }
        return ListView.builder(
          padding:
              EdgeInsets.symmetric(horizontal: responsive.widthPercent(0.04)),
          itemCount: matches.length,
          itemBuilder: (context, index) {
            final match = matches[index];
            return _MatchCard(match: match, onJoin: () => _joinMatch(match.id));
          },
        );
      },
    );
  }

  Widget _buildCreateMatchTab(Responsive responsive) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: responsive.widthPercent(0.04)),
      child: Padding(
        padding: EdgeInsets.only(
            top: responsive.heightPercent(0.015),
            bottom: responsive.heightPercent(0.05)),
        child: _buildCreateMatchForm(responsive),
      ),
    );
  }

  Widget _buildLiveMatches(Responsive responsive) {
    return _buildEmptyState(responsive,
        icon: Icons.live_tv_rounded,
        title: 'No Live Matches',
        subtitle:
            'Live matches will appear here. You can place stakes on outcomes.');
  }

  Widget _buildCreateMatchForm(Responsive responsive) {
    final gamesStream = ref.watch(gameRepositoryProvider).getGames();
    final theme = Theme.of(context);
    final walkthroughService = ref.watch(walkthroughServiceProvider);
    final walletMode = ref.watch(walletModeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(responsive.diagonalPercent(0.02)),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius:
                BorderRadius.circular(responsive.diagonalPercent(0.015)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create Match',
                  style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: responsive.diagonalPercent(0.022))),
              SizedBox(height: responsive.heightPercent(0.015)),
              StreamBuilder<List<GameModel>>(
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
                              child: Text(g.title,
                                  overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: (val) => setState(() {
                      _selectedGameId = val;
                      _selectedGame = games.firstWhere((g) => g.gameId == val);
                    }),
                    decoration: InputDecoration(
                      labelText: 'Select Game',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              responsive.diagonalPercent(0.015))),
                    ),
                  );
                },
              ),
              SizedBox(height: responsive.heightPercent(0.015)),
              Row(
                children: [
                  Expanded(
                    child: Showcase(
                      key: walkthroughService!.wagerFieldKey,
                      description: 'Set your wager amount here.',
                      child: VerzusTextField(
                        controller: _wagerController,
                        label: 'Entry Fee (USD)',
                        prefixIcon: Text('\$'),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: responsive.heightPercent(0.01)),
              SwitchListTile(
                title: Text('Private Match',
                    style:
                        TextStyle(fontSize: responsive.diagonalPercent(0.018))),
                value: _isPrivate,
                onChanged: (value) => setState(() => _isPrivate = value),
                activeColor: theme.colorScheme.primary,
              ),
              SizedBox(height: responsive.heightPercent(0.015)),
              SizedBox(
                width: double.infinity,
                child: VerzusButton(
                  onPressed: () => _createMatch(walletMode),
                  child: const Text('Create'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _createMatch(WalletKind walletKind) async {
    final authUser = ref.read(authRepositoryProvider).currentUser;
    if (authUser == null) {
      _showError('Please sign in');
      return;
    }
    final wager = double.tryParse(_wagerController.text) ?? 0.0;
    if (_selectedGame == null) {
      _showError('Select a game');
      return;
    }
    try {
      final match = MatchModel(
        id: '', // Firestore will generate this
        creatorId: authUser.uid,
        skillTopic: _selectedGame!.title,
        wagerAmount: wager,
        walletKind: walletKind,
        matchFormat: MatchFormat.oneVOne,
        status: MatchStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        gameData: {
          'game_id': _selectedGameId,
          'private': _isPrivate,
        },
      );
      await ref.read(matchRepositoryProvider).createMatch(match);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Match created')));
      }
    } catch (e) {
      if (mounted) _showError('Failed: $e');
    }
  }

  Future<void> _joinMatch(String matchId) async {
    final authUser = ref.read(authRepositoryProvider).currentUser;
    if (authUser == null) return;
    try {
      await ref.read(matchRepositoryProvider).joinMatch(matchId, authUser.uid);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Joined match!')));
      }
    } catch (e) {
      if (mounted) _showError('Failed to join: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Theme.of(context).colorScheme.error,
    ));
  }

  Widget _buildLoadingShimmer(Responsive responsive) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: responsive.widthPercent(0.04)),
      itemCount: 5,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.only(bottom: responsive.heightPercent(0.015)),
        child: VerzusShimmers.listTile(),
      ),
    );
  }

  Widget _buildErrorNotice(Object error, {bool compact = false}) {
    final responsive = Responsive(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact
            ? responsive.diagonalPercent(0.01)
            : responsive.diagonalPercent(0.02)),
        child: Text(
          error.toString(),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
                fontSize: responsive.diagonalPercent(0.018),
              ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(Responsive responsive,
      {required IconData icon,
      required String title,
      required String subtitle}) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
            vertical: responsive.heightPercent(0.05),
            horizontal: responsive.widthPercent(0.06)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: responsive.diagonalPercent(0.08),
                // ignore: deprecated_member_use
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5)),
            SizedBox(height: responsive.heightPercent(0.02)),
            Text(title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: responsive.diagonalPercent(0.022),
                )),
            SizedBox(height: responsive.heightPercent(0.01)),
            Text(subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: responsive.diagonalPercent(0.018),
                ),
                textAlign: TextAlign.center),
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
    final responsive = Responsive(context);
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.only(bottom: responsive.heightPercent(0.015)),
      padding: EdgeInsets.all(responsive.diagonalPercent(0.018)),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(responsive.diagonalPercent(0.015)),
      ),
      child: Row(
        children: [
          Icon(Icons.sports_esports_rounded, color: theme.colorScheme.primary),
          SizedBox(width: responsive.widthPercent(0.03)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  match.skillTopic,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: responsive.diagonalPercent(0.019),
                  ),
                ),
                SizedBox(height: responsive.heightPercent(0.005)),
                Text('Wager: \$${match.wagerAmount.toStringAsFixed(2)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: responsive.diagonalPercent(0.016),
                    )),
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
