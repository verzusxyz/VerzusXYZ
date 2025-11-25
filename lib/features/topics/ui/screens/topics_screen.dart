import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/features/topics/data/models/topic_model.dart';
import 'package:verzus/features/topics/data/repositories/topic_repository.dart';
import 'package:verzus/utils/responsive.dart';
import 'package:verzus/widgets/shimmers.dart';

final topicsProvider = StreamProvider.autoDispose<List<Topic>>((ref) {
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
    );
  }
}
