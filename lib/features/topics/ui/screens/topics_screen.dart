import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/features/topics/data/models/topic_model.dart';
import 'package:verzus/features/topics/data/models/vote_model.dart';
import 'package:verzus/features/topics/data/repositories/topic_repository.dart';
import 'package:verzus/features/topics/data/repositories/vote_repository.dart';
import 'package:verzus/features/wallet/data/models/wallet_model.dart';
import 'package:verzus/services/wallet_service.dart';
import 'package:verzus/services/auth_service.dart';
import 'package:verzus/theme.dart';
import 'package:verzus/widgets/verzus_button.dart';
import 'package:verzus/widgets/shimmers.dart';
import 'package:verzus/widgets/wallet_toggle.dart';

class TopicsScreen extends ConsumerStatefulWidget {
  const TopicsScreen({super.key});

  @override
  ConsumerState<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends ConsumerState<TopicsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController questionCtrl;
  late TextEditingController entryCtrl;
  late List<TextEditingController> optionCtrls;
  String pollType = 'yes_no';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    questionCtrl = TextEditingController();
    entryCtrl = TextEditingController(text: '1.00');
    optionCtrls = [TextEditingController(), TextEditingController()];
  }

  @override
  void dispose() {
    _tabController.dispose();
    questionCtrl.dispose();
    entryCtrl.dispose();
    for (var c in optionCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  Widget _buildErrorNotice(BuildContext context, Object error,
      {bool compact = false}) {
    final theme = Theme.of(context);
    final description = error.toString().trim().isEmpty
        ? 'Unable to load data. Please try again.'
        : error.toString();
    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? 8 : 16),
        child: Text(
          description,
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
        title: const Text('Topics'),
        actions: [
          Consumer(builder: (context, ref, _) {
            final mode = ref.watch(walletModeProvider);
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: WalletToggle(
                groupValue: mode,
                onSelectionChanged: (v) =>
                    ref.read(walletModeProvider.notifier).state = v,
              ),
            );
          }),
        ],
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
                Tab(text: 'Create Topic/Poll'),
                Tab(text: 'Join Poll'),
                Tab(text: 'Live Topics'),
              ],
              labelColor: VerzusColors.primaryPurple,
              unselectedLabelColor:
                  Theme.of(context).colorScheme.onSurfaceVariant,
              indicator: BoxDecoration(
                color: VerzusColors.primaryPurple.withOpacity(0.1),
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
                _buildCreatePoll(),
                _buildJoinPolls(),
                _buildLiveTopics(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreatePoll() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 500; // Responsive check

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Text(
                'Create Topic / Poll',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: questionCtrl,
                      decoration: InputDecoration(
                        labelText: 'Question',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Responsive poll type + entry fee
                    if (isNarrow)
                      Column(
                        children: [
                          DropdownButtonFormField<String>(
                            value: pollType,
                            items: const [
                              DropdownMenuItem(
                                  value: 'yes_no', child: Text('Yes / No')),
                              DropdownMenuItem(
                                  value: 'multiple_choice',
                                  child: Text('Multiple Choice')),
                              DropdownMenuItem(
                                  value: 'vs', child: Text('Option vs Option')),
                            ],
                            onChanged: (v) {
                              setState(() {
                                pollType = v ?? 'yes_no';
                              });
                            },
                            decoration: InputDecoration(
                              labelText: 'Poll Type',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: entryCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: InputDecoration(
                              labelText: 'Entry Fee (USD)',
                              prefixText: '\$',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: pollType,
                              items: const [
                                DropdownMenuItem(
                                    value: 'yes_no', child: Text('Yes / No')),
                                DropdownMenuItem(
                                    value: 'multiple_choice',
                                    child: Text('Multiple Choice')),
                                DropdownMenuItem(
                                    value: 'vs',
                                    child: Text('Option vs Option')),
                              ],
                              onChanged: (v) {
                                setState(() {
                                  pollType = v ?? 'yes_no';
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Poll Type',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: entryCtrl,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: InputDecoration(
                                labelText: 'Entry Fee (USD)',
                                prefixText: '\$',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 12),

                    if (pollType != 'yes_no')
                      Column(
                        children: [
                          for (int i = 0; i < optionCtrls.length; i++) ...[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: TextField(
                                controller: optionCtrls[i],
                                decoration: InputDecoration(
                                  labelText: 'Option ${i + 1}',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                          Align(
                            alignment: Alignment.centerLeft,
                            child: VerzusButton.outline(
                              onPressed: () {
                                setState(() {
                                  optionCtrls.add(TextEditingController());
                                });
                              },
                              child: const Text('Add Option'),
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        'Options: Yes / No',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),

                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: VerzusButton(
                        onPressed: () async {
                          final q = questionCtrl.text.trim();
                          final entry = double.tryParse(entryCtrl.text) ?? 0.0;
                          if (q.isEmpty || entry < 0) return;
                          final options = optionCtrls
                              .map((c) => c.text.trim())
                              .where((t) => t.isNotEmpty)
                              .toList();
                          if (pollType != 'yes_no' && options.length < 2) {
                            return;
                          }

                          try {
                            final mode = ref.read(walletModeProvider);
                            final topic = TopicModel(
                              id: '',
                              question: q,
                              pollType: pollType,
                              options: pollType == 'yes_no'
                                  ? ['Yes', 'No']
                                  : options,
                              entryFee: entry,
                              walletKind: mode,
                              status: 'open',
                              createdAt: DateTime.now(),
                              updatedAt: DateTime.now(),
                            );
                            await ref
                                .read(topicRepositoryProvider)
                                .createTopic(topic);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Topic created')),
                              );
                              questionCtrl.clear();
                              entryCtrl.text = '1.00';
                              for (final c in optionCtrls) {
                                c.clear();
                              }
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
                        child: const Text('Create Topic'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildJoinPolls() {
    final topicsAsync = ref.watch(closedTopicsProvider);
    return topicsAsync.when(
      data: (docs) {
        if (docs.isEmpty) {
          return _buildEmptyState(
            icon: Icons.how_to_vote_rounded,
            title: 'No Polls to Join!',
            subtitle:
                'There are no invited or closed polls for you at the moment.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: docs.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _TopicResultCard(topic: docs[index]),
          ),
        );
      },
      loading: () => VerzusShimmers.listTile(),
      error: (e, _) => _buildErrorNotice(context, e),
    );
  }

  Widget _buildLiveTopics() {
    final topicsAsync = ref.watch(openTopicsProvider);
    return topicsAsync.when(
      data: (docs) {
        if (docs.isEmpty) {
          return _buildEmptyState(
            icon: Icons.poll_rounded,
            title: 'No Live Topics Right Now',
            subtitle:
                'Ignite the conversation—create the first community topic and let the stakes begin!',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: docs.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _TopicResultCard(topic: docs[index]),
          ),
        );
      },
      loading: () => VerzusShimmers.listTile(),
      error: (e, _) => _buildErrorNotice(context, e),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withOpacity(0.7),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicResultCard extends ConsumerWidget {
  final TopicModel topic;
  const _TopicResultCard({required this.topic});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final votesAsync = ref.watch(topicVotesProvider(topic.id));
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(topic.question,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          votesAsync.when(
            data: (votes) {
              final totalVotes = votes.length;
              return Column(
                children: List.generate(topic.options.length, (index) {
                  final optionVotes = votes
                      .where((v) => v.optionIndex == index.toString())
                      .length;
                  final percentage = totalVotes > 0 ? optionVotes / totalVotes : 0.0;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(topic.options[index]),
                            Text('${(percentage * 100).toStringAsFixed(0)}%'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: percentage,
                          backgroundColor: cs.surfaceContainer,
                          color: VerzusColors.primaryPurple,
                        ),
                        if (topic.status == 'open')
                          Align(
                            alignment: Alignment.centerRight,
                            child: VerzusButton.text(
                              onPressed: () => _vote(context, ref, index),
                              child: const Text('Vote'),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error loading votes: $e'),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.bottomRight,
            child: Text('Entry: \$${topic.entryFee.toStringAsFixed(2)}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: cs.onSurfaceVariant)),
          ),
        ],
      ),
    );
  }

  Future<void> _vote(
      BuildContext context, WidgetRef ref, int optionIndex) async {
    final auth = ref.read(authStateProvider).value;
    if (auth == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please sign in')));
      return;
    }
    final mode = ref.read(walletModeProvider);
    try {
      if (topic.entryFee > 0) {
        await ref
            .read(walletServiceProvider)
            .lockFunds(auth.uid, topic.entryFee, kind: mode);
      }

      final vote = VoteModel(
        voteId: '', // Firestore will generate
        topicId: topic.id,
        userId: auth.uid,
        optionIndex: optionIndex.toString(),
        entryFee: topic.entryFee,
        walletKind: mode,
        createdAt: DateTime.now(),
      );

      await ref.read(voteRepositoryProvider).createVote(topic.id, vote);

      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Vote recorded')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: VerzusColors.dangerRed));
      }
    }
  }
}

final topicVotesProvider = StreamProvider.family<List<VoteModel>, String>((ref, topicId) {
  return ref.watch(voteRepositoryProvider).getVotes(topicId);
});

final openTopicsProvider = StreamProvider<List<TopicModel>>((ref) {
  return ref.watch(topicRepositoryProvider).getOpenTopics();
});

final closedTopicsProvider = StreamProvider<List<TopicModel>>((ref) {
  return ref.watch(topicRepositoryProvider).getClosedTopics();
});
