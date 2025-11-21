import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:verzus/services/games_service.dart';
import 'package:verzus/services/activity_log_service.dart';
import 'package:verzus/services/game_launcher.dart';
import 'package:verzus/services/auth_service.dart';
import 'package:verzus/theme.dart';
import 'package:verzus/widgets/verzus_button.dart';
import 'package:verzus/widgets/shimmers.dart';

class GamesScreen extends ConsumerWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              int crossAxisCount = 2;
              if (constraints.maxWidth >= 1200) {
                crossAxisCount = 4;
              } else if (constraints.maxWidth >= 800) {
                crossAxisCount = 3;
              } else if (constraints.maxWidth < 420) {
                crossAxisCount = 1;
              }
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.3,
                ),
                itemCount: games.length,
                itemBuilder: (context, index) {
                  final g = games[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.sports_esports_rounded,
                                color: VerzusColors.primaryPurple),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                g.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          g.platform.toUpperCase(),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Expanded(
                              child: VerzusButton.outline(
                                onPressed: () async {
                                  final auth =
                                      ref.read(authStateProvider).value;
                                  if (auth == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text('Please sign in')));
                                    return;
                                  }
                                  // Log launch
                                  await ActivityLogService().logLaunch(
                                    uid: auth.uid,
                                    gameId: g.gameId,
                                    platform: g.platform,
                                  );
                                  // Launch
                                  await const GameLauncherService()
                                      // ignore: use_build_context_synchronously
                                      .launchGame(context, g);
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
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
          ),
          itemCount: 6,
          itemBuilder: (_, __) => VerzusShimmers.gridTile(),
        ),
        error: (Object error, StackTrace stackTrace) {
          return null;
        },
        // error: (e, _) => Center(child: Text('Failed to load games data.')),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(subtitle,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center),
            if (action != null) ...[
              const SizedBox(height: 16),
              action!,
            ]
          ],
        ),
      ),
    );
  }
}
