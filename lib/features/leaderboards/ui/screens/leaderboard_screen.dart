import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/features/leaderboards/data/repositories/leaderboard_repository.dart';

// This would typically be passed in from the game selection screen.
final selectedGameIdProvider = StateProvider<String>((ref) => 'some_default_game_id');

final leaderboardProvider = FutureProvider.autoDispose<List<LeaderboardEntry>>((ref) {
  final gameId = ref.watch(selectedGameIdProvider);
  return ref.watch(leaderboardRepositoryProvider).getLeaderboard(gameId);
});

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboardAsync = ref.watch(leaderboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboards'),
        // In a real app, you'd have a dropdown here to select the game.
      ),
      body: leaderboardAsync.when(
        data: (leaderboard) {
          if (leaderboard.isEmpty) {
            return const Center(child: Text('No players ranked for this game yet.'));
          }
          return ListView.builder(
            itemCount: leaderboard.length,
            itemBuilder: (context, index) {
              final entry = leaderboard[index];
              return ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(entry.username),
                trailing: Text(entry.rating.toStringAsFixed(0)),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
