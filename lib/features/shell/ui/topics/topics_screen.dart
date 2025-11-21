import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:verzus/services/topics_service.dart';
import 'package:verzus/services/wallet_service.dart';
import 'package:verzus/models/wallet_model.dart';
import 'package:verzus/services/auth_service.dart';
import 'package:verzus/firestore/firestore_data_schema.dart';
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
                    ref.read(walletModeProvider.notifier).setMode(v),
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
                            await FirebaseFirestore.instance
                                .collection('polls')
                                .add({
                              'question': q,
                              'type': pollType,
                              'options': pollType == 'yes_no'
                                  ? ['Yes', 'No']
                                  : options,
                              'entry_fee': entry,
                              'wallet_kind':
                                  mode == WalletKind.demo ? 'demo' : 'live',
                              'status': 'open',
                              'created_at': FieldValue.serverTimestamp(),
                            });
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
        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('polls')
              .where('status', isEqualTo: 'open')
              .orderBy('created_at', descending: true)
              .limit(50)
              .snapshots(),
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
            final docs = snapshot.data?.docs ?? [];
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
                            child: _PollCard(pollId: d.id, data: d.data()),
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
                  return _PollCard(pollId: d.id, data: d.data());
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
    final topicsAsync = ref.watch(openTopicsProvider);
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

              topicsAsync.when(
                data: (list) {
                  // ignore: unnecessary_null_comparison
                  if (list == null || list.isEmpty) {
                    return _buildEmptyState(
                      icon: Icons.poll_rounded,
                      title: 'No Live Topics Right Now',
                      subtitle:
                          'Ignite the conversation—create the first community topic and let the stakes begin!',
                    );
                  }
                  if (isNarrow) {
                    return Column(
                      children: list.map((t) {
                        // ignore: unnecessary_type_check
                        final title = t is Map<dynamic, dynamic>
                            ? t[SkillTopicDocument.name] as String? ?? 'Topic'
                            : 'Topic';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _TopicCard(title: title),
                        );
                      }).toList(),
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
                        // ignore: unnecessary_type_check
                        final title = t is Map<dynamic, dynamic>
                            ? t[SkillTopicDocument.name] as String? ?? 'Topic'
                            : 'Topic';
                        return _TopicCard(title: title);
                      },
                    );
                  }
                },
                loading: () => Column(
                  children: [
                    for (int i = 0; i < 4; i++) ...[
                      VerzusShimmers.listTile(),
                      const SizedBox(height: 12),
                    ]
                  ],
                ),
                error: (e, _) => _buildErrorNotice(context, e),
              ),
            ],
          ),
        );
      },
    );
  }

  // ignore: unused_element
  Widget _buildMyStakes() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _buildEmptyState(
        icon: Icons.trending_up_rounded,
        title: 'No Active Stakes',
        subtitle: 'Your stakes on topics will appear here once you join in!',
      ),
    );
  }

  // ignore: unused_element
  Widget _buildFeaturesList(List<String> features) {
    return Column(
      children: features
          .map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: VerzusColors.accentGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      feature,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ))
          .toList(),
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
                  await ref.read(topicsServiceProvider).createOpenTopic(
                      title: title, description: desc.isEmpty ? null : desc);
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

  // ignore: unused_element
  Widget _buildTopicTypeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: color,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // ignore: unused_element
  void _showComingSoonMessage(String feature) {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        backgroundColor: VerzusColors.primaryPurple,
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
  final String pollId;
  final Map<String, dynamic> data;
  const _PollCard({required this.pollId, required this.data});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final question = data['question'] ?? 'Poll';
    final entry = (data['entry_fee'] ?? 0.0).toDouble();
    final options = List<String>.from(data['options'] ?? []);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (int i = 0; i < options.length; i++)
                VerzusButton.outline(
                  onPressed: () => _vote(context, ref, i, entry),
                  child: Text(options[i]),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Entry: \$${entry.toStringAsFixed(2)}',
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
    final auth = ref.read(authStateProvider).value;
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
      await FirebaseFirestore.instance.collection('poll_votes').add({
        'poll_id': pollId,
        'user_id': auth.uid,
        'option_index': optionIndex,
        'amount_locked': entry,
        'wallet_kind': mode == WalletKind.demo ? 'demo' : 'live',
        'created_at': FieldValue.serverTimestamp(),
      });
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
