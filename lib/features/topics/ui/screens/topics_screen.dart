import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/features/auth/providers/auth_providers.dart';
import 'package:verzus/features/topics/data/models/topic_model.dart';
import 'package:verzus/features/topics/providers/topics_providers.dart';
import 'package:verzus/features/wallet/data/models/wallet_model.dart';
import 'package:verzus/features/wallet/providers/wallet_provider.dart';
import 'package:verzus/services/wallet_service.dart';
import 'package:verzus/theme.dart';
import 'package:verzus/widgets/verzus_button.dart';
import 'package:verzus/widgets/shimmers.dart';

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
              child: _ModeToggleChip(
                mode: mode,
                onChanged: (v) =>
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
                              question: q,
                              type: pollType,
                              options: pollType == 'yes_no'
                                  ? ['Yes', 'No']
                                  : options,
                              entryFee: entry,
                              walletKind:
                                  mode == WalletKind.demo ? 'demo' : 'live',
                              status: 'open',
                              createdAt: DateTime.now(),
                              votes: {},
                            );
                            await ref
                                .read(topicsRepositoryProvider)
                                .addTopic(topic);
                            if (mounted) {
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Poll created')),
                              );
                              questionCtrl.clear();
                              entryCtrl.text = '1.00';
                              for (final c in optionCtrls) {
                                c.clear();
                              }
                            }
                          } catch (e) {
                            if (mounted) {
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed: $e'),
                                  backgroundColor: VerzusColors.dangerRed,
                                ),
                              );
                            }
                          }
                        },
                        child: const Text('Create Poll'),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;
        final topicsStream = ref.watch(topicsRepositoryProvider).getTopics();
        return StreamBuilder<List<TopicModel>>(
          stream: topicsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    for (int i = 0; i < 4; i++) ...[
                      VerzusShimmers.listTile(),
                      const SizedBox(height: 12),
                    ]
                  ],
                ),
              );
            }
            if (snapshot.hasError) {
              return _buildErrorNotice(
                  context, snapshot.error ?? 'Unknown error');
            }
            final docs = snapshot.data ?? [];
            if (docs.isEmpty) {
              return _buildEmptyState(
                icon: Icons.how_to_vote_rounded,
                title: 'No Open Polls Yet!',
                subtitle:
                    'Spark some excitement—create a poll and invite the community to join in!',
              );
            }
            if (isNarrow) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: docs
                      .map((d) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _PollCard(topic: d),
                          ))
                      .toList(),
                ),
              );
            } else {
              return GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final d = docs[index];
                  return _PollCard(topic: d);
                },
              );
            }
          },
        );
      },
    );
  }

  Widget _buildLiveTopics() {
    return _buildOpenTopics();
  }

  Widget _buildOpenTopics() {
    final topicsAsync = ref.watch(topicsRepositoryProvider).getTopics();
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Create Topic Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      VerzusColors.primaryPurple.withValues(alpha: 0.1),
                      VerzusColors.primaryPurpleLight.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: VerzusColors.primaryPurple.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.add_circle_outline_rounded,
                          color: VerzusColors.primaryPurple,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Create Open Topic',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: VerzusColors.primaryPurple,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Community-voted topics where majority stakes determine outcomes',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 16),
                    VerzusButton(
                      onPressed: _showCreateTopicDialog,
                      size: VerzusButtonSize.medium,
                      child: const Text('Create Topic'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Community Topics',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              StreamBuilder<List<TopicModel>>(
                stream: topicsAsync,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Column(
                      children: [
                        for (int i = 0; i < 4; i++) ...[
                          VerzusShimmers.listTile(),
                          const SizedBox(height: 12),
                        ]
                      ],
                    );
                  }
                  if (snapshot.hasError) {
                    return _buildErrorNotice(
                        context, snapshot.error ?? 'Unknown error');
                  }
                  final list = snapshot.data ?? [];
                  if (list.isEmpty) {
                    return _buildEmptyState(
                      icon: Icons.poll_rounded,
                      title: 'No Live Topics Right Now',
                      subtitle:
                          'Ignite the conversation—create the first community topic and let the stakes begin!',
                    );
                  }
                  if (isNarrow) {
                    return Column(
                      children: list
                          .map((t) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _TopicCard(title: t.question),
                              ))
                          .toList(),
                    );
                  } else {
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 3,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final t = list[index];
                        return _TopicCard(title: t.question);
                      },
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
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
    );
  }

  void _showCreateTopicDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildCreateTopicSheet(),
    );
  }

  Widget _buildCreateTopicSheet() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
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
                'Create Topic',
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

          TextField(
            controller: titleController,
            decoration: InputDecoration(
              labelText: 'Topic Title',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: descController,
            decoration: InputDecoration(
              labelText: 'Description (optional)',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            minLines: 2,
            maxLines: 5,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: VerzusButton(
              onPressed: () async {
                final title = titleController.text.trim();
                final desc = descController.text.trim();
                if (title.isEmpty) return;
                try {
                  final topic = TopicModel(
                    question: title,
                    description: desc.isEmpty ? null : desc,
                    type: 'open',
                    options: [],
                    entryFee: 0,
                    walletKind: 'live',
                    status: 'open',
                    createdAt: DateTime.now(),
                    votes: {},
                  );
                  await ref.read(topicsRepositoryProvider).addTopic(topic);
                  if (mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Topic created')),
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
    );
  }
}

class _TopicCard extends StatelessWidget {
  final String title;
  const _TopicCard({required this.title});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.poll_rounded, color: VerzusColors.primaryPurple),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          VerzusButton.outline(onPressed: () {}, child: const Text('Stake')),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: selected
                ? VerzusColors.primaryPurple.withValues(alpha: 0.15)
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
      ),
    );
  }
}

class _PollCard extends ConsumerWidget {
  final TopicModel topic;
  const _PollCard({required this.topic});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (int i = 0; i < topic.options.length; i++)
                VerzusButton.outline(
                  onPressed: () => _vote(context, ref, i, topic.entryFee),
                  child: Text(topic.options[i]),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Entry: \$${topic.entryFee.toStringAsFixed(2)}',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }

  Future<void> _vote(BuildContext context, WidgetRef ref, int optionIndex,
      double entry) async {
    final auth = ref.read(authProvider).value;
    if (auth == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please sign in')));
      return;
    }
    final mode = ref.read(walletModeProvider);
    try {
      if (entry > 0) {
        await ref
            .read(walletServiceProvider)
            .lockFunds(auth.uid, entry, kind: mode);
      }
      await ref
          .read(topicsRepositoryProvider)
          .voteOnTopic(topic.id!, topic.options[optionIndex]);
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
