import 'package:verzus/services/score_parsers/score_parser_interface.dart';

enum GameOutcome { victory, defeat, unknown }

class WinLossParser implements ScoreParser {
  @override
  ParsedMatchResult parse(String ocrText) {
    final lowerCaseText = ocrText.toLowerCase();

    // Prioritized list of keywords to avoid ambiguity
    const victoryKeywords = ['victory', 'winner'];
    const defeatKeywords = ['defeat', 'game over'];

    for (final keyword in victoryKeywords) {
      if (lowerCaseText.contains(keyword)) {
        // We can't determine the winner ID here, so we'll just set scores
        // The service will determine the winner based on which player won
        return ParsedMatchResult(player1Score: 1, player2Score: 0);
      }
    }

    for (final keyword in defeatKeywords) {
      if (lowerCaseText.contains(keyword)) {
        return ParsedMatchResult(player1Score: 0, player2Score: 1);
      }
    }

    return ParsedMatchResult();
  }
}
