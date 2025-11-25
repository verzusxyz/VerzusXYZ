import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:verzus/features/activity/data/repositories/activity_log_repository.dart';
import 'package:verzus/features/games/data/repositories/game_repository.dart';
import 'package:verzus/features/auth/data/repositories/auth_repository.dart';
import 'package:verzus/features/games/providers/game_launcher_provider.dart';
import 'package:verzus/utils/responsive.dart';
import 'package:verzus/widgets/verzus_button.dart';
import 'package:verzus/widgets/shimmers.dart';

final gamesStreamProvider = StreamProvider.autoDispose((ref) {
  return ref.watch(gameRepositoryProvider).getGames();
});

class GamesScreen extends ConsumerWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive = Responsive(context);
    final gamesAsync = ref.watch(gamesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Games Library'),
        actions: [
          IconButton(
            onPressed: () => context.push('/games/submit'),
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Submit Game',
          )
        ],
      ),
      body: gamesAsync.when(
        data: (games) {
          if (games.isEmpty) {
            return _EmptyState(
              emoji: '🎮',
              title: 'No games yet',
              subtitle: 'Submit a game you want to compete in',
              action: VerzusButton(
                onPressed: () => context.push('/games/submit'),
                child: const Text('Submit a Game'),
              ),
            );
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = responsive.widthPercent(0.42);
              final crossAxisCount = (constraints.maxWidth / (itemWidth + responsive.widthPercent(0.04))).floor();
              return GridView.builder(
                padding: EdgeInsets.all(responsive.widthPercent(0.04)),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: responsive.widthPercent(0.03),
                  mainAxisSpacing: responsive.widthPercent(0.03),
                  childAspectRatio: 1.3,
                ),
                itemCount: games.length,
                itemBuilder: (context, index) {
                  final g = games[index];
                  return Container(
                    padding: EdgeInsets.all(responsive.diagonalPercent(0.018)),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(responsive.diagonalPercent(0.015)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.sports_esports_rounded, color: Theme.of(context).colorScheme.primary),
                            SizedBox(width: responsive.widthPercent(0.02)),
                            Expanded(
                              child: Text(
                                g.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: responsive.diagonalPercent(0.018),
                                    ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: responsive.heightPercent(0.01)),
                        Text(
                          g.platform.toUpperCase(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                                fontSize: responsive.diagonalPercent(0.014),
                              ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Expanded(
                              child: VerzusButton.outline(
                                onPressed: () async {
                                  final authUser = ref.read(authRepositoryProvider).currentUser;
                                  if (authUser == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Please sign in')));
                                    return;
                                  }
                                  await ref.read(activityLogRepositoryProvider).logLaunch(
                                        uid: authUser.uid,
                                        gameId: g.gameId,
                                        platform: g.platform,
                                      );
                                  await ref.read(gameLauncherProvider).launchGame(context, g);
                                },
                                child: const Text('Play'),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
        loading: () => GridView.builder(
          padding: EdgeInsets.all(responsive.widthPercent(0.04)),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: (constraints.maxWidth / (responsive.widthPercent(0.42) + responsive.widthPercent(0.04))).floor(),
            crossAxisSpacing: responsive.widthPercent(0.03),
            mainAxisSpacing: responsive.widthPercent(0.03),
            childAspectRatio: 1.3,
          ),
          itemCount: 8,
          itemBuilder: (_, __) => VerzusShimmers.gridTile(),
        ),
        error: (error, stackTrace) =>
            Center(child: Text('Failed to load games data: $error')),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Widget? action;
  const _EmptyState(
      {required this.emoji,
      required this.title,
      required this.subtitle,
      this.action});

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(responsive.widthPercent(0.06)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: TextStyle(fontSize: responsive.diagonalPercent(0.06))),
            SizedBox(height: responsive.heightPercent(0.015)),
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold, fontSize: responsive.diagonalPercent(0.022))),
            SizedBox(height: responsive.heightPercent(0.01)),
            Text(subtitle,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontSize: responsive.diagonalPercent(0.018)),
                textAlign: TextAlign.center),
            if (action != null) ...[
              SizedBox(height: responsive.heightPercent(0.02)),
              action!,
            ]
          ],
        ),
      ),
    );
  }
}
