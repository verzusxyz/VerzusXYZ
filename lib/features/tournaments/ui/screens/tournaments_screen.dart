import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/core/theme.dart';
import 'package:verzus/features/auth/data/repositories/auth_repository.dart';
import 'package:verzus/features/games/data/repositories/game_repository.dart';
import 'package:verzus/features/tournaments/data/repositories/tournament_repository.dart';
import 'package:verzus/models/wallet_model.dart';
import 'package:verzus/widgets/app_loading.dart';
import 'package:verzus/widgets/verzus_button.dart';

// A simple provider to manage the wallet mode (Live/Demo)
final walletModeProvider = StateProvider<WalletKind>((ref) => WalletKind.live);

class TournamentsScreen extends ConsumerStatefulWidget {
  const TournamentsScreen({super.key});

  @override
  ConsumerState<TournamentsScreen> createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends ConsumerState<TournamentsScreen>
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tournaments'),
        actions: [
          Consumer(builder: (context, ref, _) {
            final mode = ref.watch(walletModeProvider);
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _ModeToggleChip(
                mode: mode,
                onChanged: (v) =>
                    ref.read(walletModeProvider.notifier).state = v,
              ),
            );
          })
        ],
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
                Tab(text: 'Join'),
                Tab(text: 'Create'),
                Tab(text: 'Live'),
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
                _buildJoinTournament(),
                _buildCreateTournament(),
                _buildLiveTournaments(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinTournament() {
    final tournamentsStream =
        ref.watch(tournamentRepositoryProvider).getTournaments(status: 'open');
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: tournamentsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: AppLoading(label: 'Loading tournaments...'));
        }
        if (snapshot.hasError) {
          return _buildErrorNotice(context, snapshot.error!);
        }
        final tournaments = snapshot.data ?? [];
        if (tournaments.isEmpty) {
          return _buildEmptyState(
            icon: Icons.how_to_reg_rounded,
            title: 'No Open Tournaments',
            subtitle: 'Create a tournament or check back soon!',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: tournaments.length,
          itemBuilder: (context, index) {
            final t = tournaments[index];
            return _TournamentCard(
              tournament: t,
              onJoin: () => _joinTournament(t['id']),
            );
          },
        );
      },
    );
  }

  Widget _buildCreateTournament() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _CreateTournamentForm(
        onSubmit: (newTournament) async {
          final auth = ref.read(authRepositoryProvider).currentUser;
          if (auth == null) return;

          try {
            await ref
                .read(tournamentRepositoryProvider)
                .createTournament(newTournament);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Tournament created")),
              );
              _tabController.animateTo(0); // Switch to Join tab
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed: $e'),
                  backgroundColor: VerzusColors.dangerRed,
                ),
              );
            }
          }
        },
      ),
    );
  }

  Widget _buildLiveTournaments() {
    return _buildEmptyState(
      icon: Icons.live_tv_rounded,
      title: 'Live Tournaments',
      subtitle: 'Ongoing tournaments will appear here.',
    );
  }

  Future<void> _joinTournament(String tournamentId) async {
    final auth = ref.read(authRepositoryProvider).currentUser;
    if (auth == null) return;
    try {
      await ref
          .read(tournamentRepositoryProvider)
          .joinTournament(tournamentId, auth.uid);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Joined tournament!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to join: $e'),
            backgroundColor: VerzusColors.dangerRed,
          ),
        );
      }
    }
  }

  Widget _buildErrorNotice(BuildContext context, Object error,
      {bool compact = false}) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? 8 : 16),
        child: Text(
          error.toString(),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.error),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _TournamentCard extends StatelessWidget {
  final Map<String, dynamic> tournament;
  final VoidCallback onJoin;

  const _TournamentCard({required this.tournament, required this.onJoin});

  @override
  Widget build(BuildContext context) {
    final title = tournament['title'] as String? ?? 'Tournament';
    final entryFee = (tournament['entryFee'] as num?)?.toDouble() ?? 0.0;
    final current = tournament['currentParticipants'] as int? ?? 0;
    final max = tournament['maxParticipants'] as int? ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  'Entry: \$${entryFee.toStringAsFixed(2)} • $current/$max players',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          VerzusButton(onPressed: onJoin, child: const Text('Join')),
        ],
      ),
    );
  }
}

class _CreateTournamentForm extends ConsumerStatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;
  const _CreateTournamentForm({required this.onSubmit});

  @override
  ConsumerState<_CreateTournamentForm> createState() =>
      __CreateTournamentFormState();
}

class __CreateTournamentFormState extends ConsumerState<_CreateTournamentForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _entryCtrl = TextEditingController(text: '5.00');
  final _maxPlayersCtrl = TextEditingController(text: '12');
  String? _selectedGameId;

  @override
  Widget build(BuildContext context) {
    final gamesStream = ref.watch(gameRepositoryProvider).getGames();
    final mode = ref.watch(walletModeProvider);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Create Tournament (${mode == WalletKind.live ? 'Live' : 'Demo'})',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          StreamBuilder(
            stream: gamesStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              return DropdownButtonFormField<String>(
                value: _selectedGameId,
                items: snapshot.data!
                    .map((g) => DropdownMenuItem(
                          value: g.gameId,
                          child: Text(g.title),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedGameId = v),
                decoration: InputDecoration(
                  labelText: 'Game',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v == null ? 'Please select a game' : null,
              );
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _titleCtrl,
            decoration: InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (v) =>
                v == null || v.isEmpty ? 'Please enter a title' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _entryCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Entry Fee (USD)',
              prefixText: '\$',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please enter an entry fee';
              if (double.tryParse(v) == null) return 'Invalid amount';
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _maxPlayersCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Max Players',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Please enter max players';
              if (int.tryParse(v) == null) return 'Invalid number';
              return null;
            },
          ),
          const SizedBox(height: 24),
          VerzusButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                widget.onSubmit({
                  'title': _titleCtrl.text,
                  'entryFee': double.parse(_entryCtrl.text),
                  'maxParticipants': int.parse(_maxPlayersCtrl.text),
                  'gameId': _selectedGameId,
                  'walletKind': mode == WalletKind.live ? 'live' : 'demo',
                  'status': 'open',
                });
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class _ModeToggleChip extends StatelessWidget {
  final WalletKind mode;
  final ValueChanged<WalletKind> onChanged;
  const _ModeToggleChip({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _pill(context,
              label: 'Live',
              selected: mode == WalletKind.live,
              onTap: () => onChanged(WalletKind.live)),
          _pill(context,
              label: 'Demo',
              selected: mode == WalletKind.demo,
              onTap: () => onChanged(WalletKind.demo)),
        ],
      ),
    );
  }

  Widget _pill(BuildContext context,
      {required String label,
      required bool selected,
      required VoidCallback onTap}) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? VerzusColors.primaryPurple.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: selected
                    ? VerzusColors.primaryPurple
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
        ),
      ),
    );
  }
}
