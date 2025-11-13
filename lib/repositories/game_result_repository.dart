import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/models/game_result_model.dart';
import 'package:verzus/repositories/firebase_repository.dart';
import 'package:verzus/services/firebase_client_service.dart';

final gameResultRepositoryProvider = Provider<GameResultRepository>((ref) {
  final firebaseClient = ref.read(firebaseClientServiceProvider);
  return GameResultRepository(firebaseClient);
});

class GameResultRepository extends BaseRepository {
  GameResultRepository(super.firebaseClient);

  Future<String> createGameResult(GameResultModel result) async {
    return await firebaseClient.createGameResult(result.toFirestore());
  }
}
