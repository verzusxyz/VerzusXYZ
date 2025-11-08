import 'package:verzus/services/score_parsers/score_parser_interface.dart';

class ScoreBasedMatchResult extends MatchResult {
  final Map<String, int> scores;
  final String winner;

  ScoreBasedMatchResult({required this.scores, required this.winner});

  Map<String, dynamic> toJson() {
    return {
      'scores': scores,
      'winner': winner,
    };
  }
}

class ScoreBasedParser implements ScoreParser {
  @override
  MatchResult parse(String ocrText) {
    // Simple implementation using regex to find scores next to player names.
    // This will need to be made more robust based on actual OCR output.
    final scores = <String, int>{};
    final lines = ocrText.split('\n');
    for (final line in lines) {
      final match = RegExp(r'(\w+)\s+(\d+)').firstMatch(line);
      if (match != null) {
        final playerName = match.group(1)!;
        final score = int.tryParse(match.group(2)!) ?? 0;
        scores[playerName] = score;
      }
    }

    String winner = '';
    int maxScore = 0;
    scores.forEach((player, score) {
      if (score > maxScore) {
        maxScore = score;
        winner = player;
      }
    });

    return ScoreBasedMatchResult(scores: scores, winner: winner);
  }
}
