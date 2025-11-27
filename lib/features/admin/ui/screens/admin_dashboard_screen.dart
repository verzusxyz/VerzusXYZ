import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/features/admin/providers/admin_providers.dart';
import 'package:verzus/features/games/data/models/game_model.dart';
import 'package:verzus/services/auth_service.dart';
import 'package:verzus/services/games_service.dart';
import 'package:verzus/theme.dart';
import 'package:verzus/widgets/verzus_button.dart';
import 'package:verzus/widgets/shimmers.dart';
import 'package:verzus/features/matches/data/models/match_model.dart';
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

  final _sponsoredTournamentFormKey = GlobalKey<FormState>();
  final _tournamentNameController = TextEditingController();
  final _prizePoolController = TextEditingController();
  final List<Map<String, TextEditingController>> _prizeDistributionControllers =
      [];

  final _affiliateLevelFormKey = GlobalKey<FormState>();
  final _affiliateLevelNameController = TextEditingController();
  final _affiliateCommissionController = TextEditingController();

  final _platformFeesFormKey = GlobalKey<FormState>();
  final _matchesFeeController = TextEditingController();
  final _tournamentsFeeController = TextEditingController();
  final _autoTournamentsFeeController = TextEditingController();
  final _topicsFeeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _addPrizeDistributionRow();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _tournamentNameController.dispose();
    _prizePoolController.dispose();
    for (var controllers in _prizeDistributionControllers) {
      controllers['rank']!.dispose();
      controllers['percentage']!.dispose();
    }
    _affiliateLevelNameController.dispose();
    _affiliateCommissionController.dispose();
    _matchesFeeController.dispose();
    _tournamentsFeeController.dispose();
    _autoTournamentsFeeController.dispose();
    _topicsFeeController.dispose();
    super.dispose();
  }

  void _addPrizeDistributionRow() {
    setState(() {
      _prizeDistributionControllers.add({
        'rank': TextEditingController(),
        'percentage': TextEditingController(),
      });
    });
  }

  void _removePrizeDistributionRow(int index) {
    setState(() {
      _prizeDistributionControllers[index]['rank']!.dispose();
      _prizeDistributionControllers[index]['percentage']!.dispose();
      _prizeDistributionControllers.removeAt(index);
    });
  }

  Future<void> _createSponsoredTournament() async {
    if (_sponsoredTournamentFormKey.currentState!.validate()) {
      final name = _tournamentNameController.text;
      final prizePool = double.tryParse(_prizePoolController.text) ?? 0.0;
      final prizeDistribution = <int, double>{};
      for (var controllers in _prizeDistributionControllers) {
        final rank = int.tryParse(controllers['rank']!.text) ?? 0;
        final percentage =
            double.tryParse(controllers['percentage']!.text) ?? 0.0;
        if (rank > 0 && percentage > 0) {
          prizeDistribution[rank] = percentage;
        }
      }

      try {
        await ref
            .read(sponsoredTournamentRepositoryProvider)
            .createSponsoredTournament(
              name: name,
              prizePool: prizePool,
              prizeDistribution: prizeDistribution,
            );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sponsored tournament created!')),
        );
        _sponsoredTournamentFormKey.currentState!.reset();
        _tournamentNameController.clear();
        _prizePoolController.clear();
        setState(() {
          _prizeDistributionControllers.clear();
          _addPrizeDistributionRow();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating tournament: $e')),
        );
      }
    }
  }

  Future<void> _addAffiliateLevel() async {
    if (_affiliateLevelFormKey.currentState!.validate()) {
      final name = _affiliateLevelNameController.text;
      final commissionRate =
          double.tryParse(_affiliateCommissionController.text) ?? 0.0;

      try {
        await ref.read(adminRepositoryProvider).addAffiliateLevel(
              name: name,
              commissionRate: commissionRate,
            );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Affiliate level added!')),
        );
        _affiliateLevelFormKey.currentState!.reset();
        _affiliateLevelNameController.clear();
        _affiliateCommissionController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding level: $e')),
        );
      }
    }
  }

  Future<void> _savePlatformFees() async {
    if (_platformFeesFormKey.currentState!.validate()) {
      final matches = double.tryParse(_matchesFeeController.text) ?? 0.0;
      final tournaments =
          double.tryParse(_tournamentsFeeController.text) ?? 0.0;
      final autoTournaments =
          double.tryParse(_autoTournamentsFeeController.text) ?? 0.0;
      final topics = double.tryParse(_topicsFeeController.text) ?? 0.0;

      try {
        await ref.read(adminRepositoryProvider).savePlatformFees(
              matches: matches,
              tournaments: tournaments,
              autoTournaments: autoTournaments,
              topics: topics,
            );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Platform fees saved!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving fees: $e')),
        );
      }
    }
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
    final theme = Theme.of(context);
    if (!_isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin')),
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: theme.colorScheme.error.withOpacity(0.3)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_rounded, color: theme.colorScheme.error),
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
            Tab(text: 'Sponsored'),
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
          // Sponsored
          _buildSponsoredTournaments(context),
        ],
      ),
    );
  }

  Widget _buildGamesTab(BuildContext context, List<GameModel> list) {
    final theme = Theme.of(context);
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, i) {
        final g = list[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.sports_esports_rounded,
                  color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      g.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(g.platform.toUpperCase(),
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
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
    final theme = Theme.of(context);
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
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.gavel_rounded, color: theme.colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dispute: ${m.id}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Creator vs Opponent • Wager: ${m.wagerAmount.toStringAsFixed(2)} • Mode: ${m.gameMode}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      m.status.displayName,
                      style: TextStyle(
                          color: theme.colorScheme.tertiary,
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAffiliateLevels(context),
          const SizedBox(height: 32),
          _buildPlatformFees(context),
        ],
      ),
    );
  }

  Widget _buildAffiliateLevels(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: _affiliateLevelFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Affiliate Levels',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _affiliateLevelNameController,
                  decoration: const InputDecoration(
                    labelText: 'Level Name',
                    hintText: 'e.g. "Bronze"',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _affiliateCommissionController,
                  decoration: const InputDecoration(
                    labelText: 'Commission %',
                    hintText: 'e.g. "5"',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a commission rate';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                VerzusButton(
                  onPressed: _addAffiliateLevel,
                  child: const Text('Add Level'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformFees(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: _platformFeesFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Platform Fees',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _matchesFeeController,
                  decoration: const InputDecoration(
                    labelText: 'Matches %',
                    hintText: 'e.g. "10"',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a fee';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _tournamentsFeeController,
                  decoration: const InputDecoration(
                    labelText: 'Tournaments %',
                    hintText: 'e.g. "15"',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a fee';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _autoTournamentsFeeController,
                  decoration: const InputDecoration(
                    labelText: 'Auto-Tournaments %',
                    hintText: 'e.g. "20"',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a fee';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _topicsFeeController,
                  decoration: const InputDecoration(
                    labelText: 'Topics %',
                    hintText: 'e.g. "5"',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a fee';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                VerzusButton(
                  onPressed: _savePlatformFees,
                  child: const Text('Save Fees'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSponsoredTournaments(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _sponsoredTournamentFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sponsored Tournaments',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _tournamentNameController,
                    decoration: const InputDecoration(
                      labelText: 'Tournament Name',
                      hintText: 'e.g. "Summer Open"',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _prizePoolController,
                    decoration: const InputDecoration(
                      labelText: 'Prize Pool',
                      hintText: 'e.g. "1000"',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a prize pool';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildPrizeDistribution(context),
                  const SizedBox(height: 16),
                  VerzusButton(
                    onPressed: _createSponsoredTournament,
                    child: const Text('Create Tournament'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrizeDistribution(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Prize Distribution',
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        for (int i = 0; i < _prizeDistributionControllers.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _prizeDistributionControllers[i]['rank'],
                    decoration: const InputDecoration(
                      labelText: 'Rank',
                      hintText: 'e.g. "1"',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _prizeDistributionControllers[i]['percentage'],
                    decoration: const InputDecoration(
                      labelText: 'Percentage',
                      hintText: 'e.g. "50"',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () => _removePrizeDistributionRow(i),
                ),
              ],
            ),
          ),
        TextButton.icon(
          icon: const Icon(Icons.add),
          label: const Text('Add Rank'),
          onPressed: _addPrizeDistributionRow,
        ),
      ],
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
    final theme = Theme.of(context);
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
                  color: theme.colorScheme.secondary.withOpacity(0.35),
                  label: 'Score'),
              _RectOverlay(
                  rect: crop!.usernameRect,
                  color: theme.colorScheme.primary.withOpacity(0.35),
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
    final theme = Theme.of(context);
    return Positioned(
      left: rect.x,
      top: rect.y,
      width: rect.width,
      height: rect.height,
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 2),
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Align(
            alignment: Alignment.topLeft,
            child: Container(
              margin: const EdgeInsets.all(4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(label,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.colorScheme.surface)),
            ),
          ),
        ),
      ),
    );
  }
}
