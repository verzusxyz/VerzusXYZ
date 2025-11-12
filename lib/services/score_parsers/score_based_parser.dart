import 'package:verzus/services/score_parsers/score_parser_interface.dart';

class ScoreBasedParser implements ScoreParser {
  @override
  ParsedMatchResult parse(String ocrText) {
    // Simple implementation using regex to find scores.
    // This assumes a simple "Player1: 10, Player2: 5" format.
    // This will need to be made more robust based on actual OCR output.
    final scores = <int>[];
    final matches = RegExp(r'(\d+)').allMatches(ocrText);
    for (final match in matches) {
      final score = int.tryParse(match.group(1)!) ?? 0;
      scores.add(score);
    }

    if (scores.length >= 2) {
      return ParsedMatchResult(player1Score: scores[0], player2Score: scores[1]);
    } else if (scores.length == 1) {
      return ParsedMatchResult(player1Score: scores[0]);
    } else {
      return ParsedMatchResult();
    }
  }
}
