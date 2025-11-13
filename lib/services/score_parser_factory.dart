import 'package:verzus/models/game_model.dart';
import 'package:verzus/services/score_parsers/kda_based_parser.dart';
import 'package:verzus/services/score_parsers/score_based_parser.dart';
import 'package:verzus/services/score_parsers/score_parser_interface.dart';
import 'package:verzus/services/score_parsers/win_loss_parser.dart';

class ScoreParserFactory {
  static ScoreParser getParser(GameModel game) {
    switch (game.resultType) {
      case GameResultType.scoreBased:
        return ScoreBasedParser();
      case GameResultType.winLoss:
        return WinLossParser();
      case GameResultType.kdaBased:
        return KdaBasedParser();
      default:
        throw Exception('Unsupported result type: ${game.resultType}');
    }
  }
}
