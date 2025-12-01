import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/features/topics/data/models/topic_model.dart';
import 'package:verzus/features/topics/data/repositories/topic_repository.dart';
import 'package:verzus/utils/responsive.dart';
import 'package:verzus/widgets/shimmers.dart';
import 'package:verzus/widgets/verzus_button.dart';
import 'package:verzus/theme.dart';

final topicsProvider = StreamProvider.autoDispose<List<TopicModel>>((ref) {
  return ref.watch(topicRepositoryProvider).getTopics();
});

class TopicsScreen extends ConsumerWidget {
  const TopicsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive = Responsive(context);
    final topicsAsync = ref.watch(topicsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Topics'),
      ),
      body: topicsAsync.when(
        data: (topics) {
          if (topics.isEmpty) {
            return Center(child: Text(
              'No topics found.',
              style: TextStyle(fontSize: responsive.diagonalPercent(0.018)),
            ));
          }
          return ListView.builder(
            padding: EdgeInsets.all(responsive.widthPercent(0.04)),
            itemCount: topics.length,
            itemBuilder: (context, index) {
              final topic = topics[index];
              return Card(
                margin: EdgeInsets.only(bottom: responsive.heightPercent(0.015)),
                child: ListTile(
                  title: Text(topic.name, style: TextStyle(
                    fontSize: responsive.diagonalPercent(0.019),
                    fontWeight: FontWeight.w500,
                  )),
                  subtitle: Text(topic.description, style: TextStyle(
                    fontSize: responsive.diagonalPercent(0.016),
                  )),
                ),
              );
            },
          );
        },
        loading: () => ListView.builder(
          padding: EdgeInsets.all(responsive.widthPercent(0.04)),
          itemCount: 10,
          itemBuilder: (context, index) => Padding(
            padding: EdgeInsets.only(bottom: responsive.heightPercent(0.015)),
            child: VerzusShimmers.listTile(),
          ),
        ),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateTopicDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateTopicDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleeBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildCreateTopicSheet(context, ref),
    );
  }

  Widget _buildCreateTopicSheet(BuildContext context, WidgetRef ref) {
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
                    id: '',
                    name: title,
                    description: desc,
                    category: '',
                    iconUrl: '',
                    isActive: true,
                    minWager: 0,
                    maxWager: 0,
                    gameConfig: {},
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  await ref.read(topicRepositoryProvider).createTopic(topic);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Topic created')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
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
