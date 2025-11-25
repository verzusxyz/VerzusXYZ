import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/features/games/data/repositories/game_repository.dart'; // Assuming games are selectable
import 'package:verzus/features/leaderboards/data/models/leaderboard_entry_model.dart';
import 'package:verzus/features/leaderboards/data/repositories/leaderboard_repository.dart';
import 'package:verzus/utils/responsive.dart';
import 'package:verzus/widgets/shimmers.dart';

final gamesForLeaderboardProvider = StreamProvider.autoDispose((ref) {
  return ref.watch(gameRepositoryProvider).getGames();
});

final selectedGameIdProvider = StateProvider<String?>((ref) => null);

final leaderboardProvider = FutureProvider.autoDispose<List<LeaderboardEntry>>((ref) {
  final gameId = ref.watch(selectedGameIdProvider);
  if (gameId == null) return [];
  return ref.watch(leaderboardRepositoryProvider).getLeaderboard(gameId);
});

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive = Responsive(context);
    final leaderboardAsync = ref.watch(leaderboardProvider);
    final gamesAsync = ref.watch(gamesForLeaderboardProvider);
    final selectedGameId = ref.watch(selectedGameIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboards'),
        actions: [
          gamesAsync.when(
            data: (games) {
              // Set the first game as default if none is selected
              if (selectedGameId == null && games.isNotEmpty) {
                Future.microtask(() => ref.read(selectedGameIdProvider.notifier).state = games.first.gameId);
              }
              return Padding(
                padding: EdgeInsets.only(right: responsive.widthPercent(0.02)),
                child: DropdownButton<String>(
                  value: selectedGameId,
                  hint: const Text('Select Game'),
                  underline: const SizedBox.shrink(),
                  items: games.map((game) => DropdownMenuItem(value: game.gameId, child: Text(game.title))).toList(),
                  onChanged: (value) => ref.read(selectedGameIdProvider.notifier).state = value,
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const Icon(Icons.error),
          ),
        ],
      ),
      body: leaderboardAsync.when(
        data: (leaderboard) {
          if (leaderboard.isEmpty) {
            return Center(child: Text(
              'No players ranked for this game yet.',
              style: TextStyle(fontSize: responsive.diagonalPercent(0.018)),
            ));
          }
          return ListView.builder(
            padding: EdgeInsets.all(responsive.widthPercent(0.04)),
            itemCount: leaderboard.length,
            itemBuilder: (context, index) {
              final entry = leaderboard[index];
              return Card(
                margin: EdgeInsets.only(bottom: responsive.heightPercent(0.015)),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  title: Text(entry.username, style: TextStyle(
                    fontSize: responsive.diagonalPercent(0.019),
                    fontWeight: FontWeight.w600,
                  )),
                  trailing: Text(entry.rating.toStringAsFixed(0), style: TextStyle(
                    fontSize: responsive.diagonalPercent(0.02),
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
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
