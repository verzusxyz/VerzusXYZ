import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/features/topics/data/models/topic_model.dart';
import 'package:verzus/features/topics/data/repositories/topic_repository.dart';
import 'package:verzus/services/auth_service.dart';
import 'package:verzus/widgets/shimmers.dart';
import 'package:verzus/widgets/verzus_button.dart';

class TopicsScreen extends ConsumerWidget {
  const TopicsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicsStream = ref.watch(topicsProvider);
    final user = ref.watch(currentUserProvider).value;
    final isAdmin = user?.email?.endsWith('@verzus.xyz') ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Topics'),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showCreateTopicDialog(context, ref),
            ),
        ],
      ),
      body: topicsStream.when(
        data: (topics) {
          if (topics.isEmpty) {
            return const Center(child: Text('No topics available.'));
          }
          return ListView.builder(
            itemCount: topics.length,
            itemBuilder: (context, index) {
              final topic = topics[index];
              return ListTile(
                title: Text(topic.name),
                subtitle: Text(topic.description),
              );
            },
          );
        },
        loading: () => VerzusShimmers.list(),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  void _showCreateTopicDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Topic'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            VerzusButton(
              onPressed: () {
                final topic = TopicModel(
                  id: ref.read(topicRepositoryProvider)._topicsRef.doc().id,
                  name: nameController.text,
                  description: descriptionController.text,
                  category: categoryController.text,
                );
                ref.read(topicRepositoryProvider).createTopic(topic);
                Navigator.of(context).pop();
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}

final topicsProvider = StreamProvider<List<TopicModel>>((ref) {
  return ref.watch(topicRepositoryProvider).getTopics();
});
