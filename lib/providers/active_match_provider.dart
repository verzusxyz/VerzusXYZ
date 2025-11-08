import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/models/game_model.dart';

class ActiveMatch {
  final GameModel game;
  final String matchId;

  ActiveMatch({required this.game, required this.matchId});
}

final activeMatchProvider = StateProvider<ActiveMatch?>((ref) => null);
