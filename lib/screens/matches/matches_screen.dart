import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:verzus/services/auth_service.dart';
import 'package:verzus/models/user_model.dart';
import 'package:verzus/models/match_model.dart';
import 'package:verzus/services/match_service.dart';
import 'package:verzus/models/wallet_model.dart';
import 'package:verzus/services/games_service.dart';
import 'package:verzus/services/wallet_service.dart';
import 'package:verzus/theme.dart';
import 'package:verzus/widgets/verzus_button.dart';
import 'package:verzus/widgets/shimmers.dart';

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

  Widget _buildErrorNotice(Object error, {bool compact = false}) {
    final message = error.toString().trim().isEmpty
        ? 'Unable to load data. Please try again shortly.'
        : error.toString();
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? 8 : 16),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.error),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matches'),
        // actions: [
        //   IconButton(
        //     onPressed: () => setState(() => _tabController.index = 1),
        //     icon: const Icon(Icons.add_rounded),
        //   ),
        // ],
      ),
      body: Column(
        children: [
          // Tab Bar
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
          // Tab Views
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
    final matchesAsync = ref.watch(openMatchesProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Create Match Card
          // Container(
          //   width: double.infinity,
          //   padding: const EdgeInsets.all(20),
          //   decoration: BoxDecoration(
          //     gradient: LinearGradient(
          //       colors: [
          //         VerzusColors.primaryPurple.withValues(alpha: 0.1),
          //         VerzusColors.primaryPurpleLight.withValues(alpha: 0.05),
          //       ],
          //     ),
          //     borderRadius: BorderRadius.circular(16),
          //     border: Border.all(
          //       color: VerzusColors.primaryPurple.withValues(alpha: 0.2),
          //     ),
          //   ),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Row(
          //         children: [
          //           Icon(
          //             Icons.add_circle_outline_rounded,
          //             color: VerzusColors.primaryPurple,
          //             size: 24,
          //           ),
          //           const SizedBox(width: 12),
          //           Text(
          //             'Create New Match',
          //             style: Theme.of(context).textTheme.titleMedium?.copyWith(
          //               color: VerzusColors.primaryPurple,
          //               fontWeight: FontWeight.bold,
          //             ),
          //           ),
          //         ],
          //       ),
          //       const SizedBox(height: 8),
          //       Text(
          //         'Challenge other players in skill-based competitions',
          //         style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          //           color: Theme.of(context).colorScheme.onSurfaceVariant,
          //         ),
          //       ),
          //       const SizedBox(height: 16),
          //       VerzusButton(
          //         onPressed: () => setState(() => _tabController.index = 1),
          //         size: VerzusButtonSize.medium,
          //         child: const Text('Create Match'),
          //       ),
          //     ],
          //   ),
          // ),
          // const SizedBox(height: 24),
          // Available Matches Section
          Text(
            'Available Matches',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          matchesAsync.when(
            data: (list) {
              if (list.isEmpty) {
                return _buildEmptyState(
                  icon: Icons.search_rounded,
                  title: 'No Open Matches',
                  subtitle:
                      'Be the first to create a match and challenge other players!',
                );
              }
              return Column(
                children: list
                    .map<Widget>((m) =>
                        _MatchCard(match: m, onJoin: () => _joinMatch(m.id)))
                    .toList(),
              );
            },
            loading: () => Column(
              children: [
                const SizedBox(height: 8),
                for (int i = 0; i < 4; i++) ...[
                  VerzusShimmers.listTile(),
                  const SizedBox(height: 12),
                ],
              ],
            ),
            error: (e, _) => _buildErrorNotice(e),
          ),
        ],
      ),
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
    final activeAsync = ref.watch(activeMatchesProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Spectate & Stake',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          activeAsync.when(
            data: (list) {
              if (list.isEmpty) {
                return _buildEmptyState(
                  icon: Icons.live_tv_rounded,
                  title: 'No Live Matches',
                  subtitle:
                      'Live matches will appear here. You can place stakes on outcomes.',
                );
              }
              return Column(
                children: list
                    .map<Widget>((m) => _LiveMatchCard(
                        match: m, onStake: () => _showStakeDialog(m)))
                    .toList(),
              );
            },
            loading: () => Column(
                children: List.generate(
                    4,
                    (_) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: VerzusShimmers.listTile()))),
            error: (e, _) => _buildErrorNotice(e),
          ),
        ],
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
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant
                  .withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withValues(alpha: 0.7),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateMatchForm() {
    final gamesAsync = ref.watch(gamesStreamProvider);
    final authUser = ref.watch(authStateProvider).value;
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
              gamesAsync.when(
                data: (games) {
                  return DropdownButtonFormField<String>(
                    value: _selectedGameId,
                    items: games
                        .map<DropdownMenuItem<String>>(
                            (g) => DropdownMenuItem<String>(
                                  value: g.gameId,
                                  child: Text(g.title,
                                      overflow: TextOverflow.ellipsis),
                                ))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedGameId = val;
                        final g = games.firstWhere((x) => x.gameId == val,
                            orElse: () => games.first);
                        _selectedGameTitle = g.title;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Select Game',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
                loading: () => const LinearProgressIndicator(minHeight: 2),
                error: (e, _) => _buildErrorNotice(e, compact: true),
              ),
              const SizedBox(height: 12),
              // Match Type (required by spec)
              DropdownButtonFormField<MatchFormat>(
                value: _format,
                items: const [
                  DropdownMenuItem(
                      value: MatchFormat.oneVOne, child: Text('1v1')),
                  DropdownMenuItem(
                      value: MatchFormat.freeForAll,
                      child: Text('Free-for-all')),
                  DropdownMenuItem(
                      value: MatchFormat.teamBased, child: Text('Team-based')),
                ],
                onChanged: (v) =>
                    setState(() => _format = v ?? MatchFormat.oneVOne),
                decoration: InputDecoration(
                  labelText: 'Match Type',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
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
                    final u = authUser;
                    if (u == null) {
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
                    // Stake/Entry is optional; allow 0 for demo or free matches
                    try {
                      await ref.read(matchServiceProvider).createMatch(
                        creatorId: u.uid,
                        skillTopic: _selectedGameTitle ?? 'Custom',
                        wagerAmount: wager,
                        walletKind:
                            _mode == 'Live' ? WalletKind.live : WalletKind.demo,
                        matchFormat: _format,
                        gameData: {
                          'game_id': _selectedGameId,
                          'private': _isPrivate,
                          'mode': _mode == 'Live' ? 'live' : 'demo',
                          'match_type': _format.name,
                        },
                      );
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

  // Optional: bottom-sheet version of the create form (unused by default)
  // ignore: unused_element
  Widget _buildCreateMatchSheet() {
    final wagerController = TextEditingController(text: '5.00');
    String? selectedGameId;
    String? selectedGameTitle;
    bool isPrivate = false;

    return Consumer(builder: (context, ref, _) {
      final gamesAsync = ref.watch(gamesStreamProvider);
      final auth = ref.watch(authStateProvider).value;
      final user = ref.watch(currentUserProvider).value;
      return Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  'Create Match',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Game selector
            gamesAsync.when(
              data: (games) {
                return DropdownButtonFormField<String>(
                  value: selectedGameId,
                  items: games
                      .map<DropdownMenuItem<String>>((g) =>
                          DropdownMenuItem<String>(
                            value: g.gameId,
                            child:
                                Text(g.title, overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  onChanged: (val) {
                    selectedGameId = val;
                    final g = games.firstWhere((x) => x.gameId == val,
                        orElse: () => games.first);
                    selectedGameTitle = g.title;
                    (context as Element).markNeedsBuild();
                  },
                  decoration: InputDecoration(
                    labelText: 'Select Game',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
              loading: () => const LinearProgressIndicator(minHeight: 2),
              error: (e, _) => _buildErrorNotice(e, compact: true),
            ),
            const SizedBox(height: 12),
            // Privacy toggle
            Row(
              children: [
                Checkbox(
                  value: isPrivate,
                  onChanged: (v) {
                    isPrivate = v ?? false;
                    (context as Element).markNeedsBuild();
                  },
                ),
                const Text('Private (invite-only)')
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: wagerController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Wager Amount (USD)',
                prefixText: '\$',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: VerzusButton(
                onPressed: () async {
                  final a = auth;
                  if (a == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please sign in')));
                    return;
                  }
                  final wager = double.tryParse(wagerController.text) ?? 0.0;
                  if (selectedGameId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Select a game')));
                    return;
                  }
                  if (wager <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Enter a valid wager amount')));
                    return;
                  }
                  // KYC check if profile loaded
                  if (user != null && user.kycStatus != KycStatus.verified) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Please complete KYC verification to create matches')),
                    );
                    return;
                  }
                  try {
                    await ref.read(matchServiceProvider).createMatch(
                      creatorId: a.uid,
                      skillTopic: selectedGameTitle ?? 'Custom',
                      wagerAmount: wager,
                      walletKind: WalletKind.live,
                      gameData: {
                        'game_id': selectedGameId,
                        'private': isPrivate,
                        'mode': 'live',
                      },
                    );
                    if (mounted) {
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Match created')),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      // ignore: use_build_context_synchronously
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
      );
    });
  }

  Future<void> _joinMatch(String matchId) async {
    final auth = ref.read(authStateProvider).value;
    if (auth == null) return;
    try {
      await ref
          .read(matchServiceProvider)
          .joinMatch(matchId: matchId, opponentId: auth.uid);
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

  Future<void> _showStakeDialog(MatchModel match) async {
    final amountCtrl = TextEditingController(text: '2.00');
    await showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Place Stake'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Match: ${match.skillTopic}'),
            const SizedBox(height: 12),
            TextField(
              controller: amountCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                  labelText: 'Stake Amount (USD)', prefixText: '\$'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final auth = ref.read(authStateProvider).value;
              if (auth == null) return;
              final amt = double.tryParse(amountCtrl.text) ?? 0.0;
              if (amt <= 0) return;
              try {
                final isDemo = (match.gameMode == 'demo') ||
                    (match.gameData?['mode'] == 'demo');
                await ref.read(walletServiceProvider).lockFunds(auth.uid, amt,
                    kind: isDemo ? WalletKind.demo : WalletKind.live);
                await FirebaseFirestore.instance
                    .collection('match_stakes')
                    .add({
                  'match_id': match.id,
                  'user_id': auth.uid,
                  'amount': amt,
                  'wallet_kind': isDemo ? 'demo' : 'live',
                  'created_at': FieldValue.serverTimestamp(),
                });
                if (context.mounted) {
                  Navigator.of(dialogCtx).pop();
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Stake placed')));
                }
              } catch (e) {
                if (context.mounted) {
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Failed: $e'),
                        backgroundColor: VerzusColors.dangerRed),
                  );
                }
              }
            },
            child: const Text('Stake'),
          ),
        ],
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

class _LiveMatchCard extends StatelessWidget {
  final MatchModel match;
  final VoidCallback onStake;
  const _LiveMatchCard({required this.match, required this.onStake});

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
          Icon(Icons.live_tv_rounded, color: Colors.red),
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
                Text('Started',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          VerzusButton(
            onPressed: onStake,
            size: VerzusButtonSize.medium,
            child: const Text('Stake'),
          ),
        ],
      ),
    );
  }
}
