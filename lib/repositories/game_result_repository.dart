import 'package:verzus/models/game_result_model.dart';
import 'package:verzus/repositories/firebase_repository.dart';
import 'package:verzus/services/firebase_client_service.dart';

class GameResultRepository extends BaseRepository {
  GameResultRepository(super.firebaseClient);

  Future<String> createGameResult(GameResultModel result) async {
    return await firebaseClient.createGameResult(result.toFirestore());
  }
}
