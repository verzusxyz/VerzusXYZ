import 'package:verzus/services/score_parsers/score_parser_interface.dart';

enum GameOutcome { victory, defeat, unknown }

class WinLossMatchResult extends MatchResult {
  final GameOutcome outcome;

  WinLossMatchResult({required this.outcome});

  Map<String, dynamic> toJson() {
    return {
      'outcome': outcome.toString(),
    };
  }
}

class WinLossParser implements ScoreParser {
  @override
  MatchResult parse(String ocrText) {
    final lowerCaseText = ocrText.toLowerCase();

    // Prioritized list of keywords to avoid ambiguity
    const victoryKeywords = ['victory', 'winner'];
    const defeatKeywords = ['defeat', 'game over'];

    for (final keyword in victoryKeywords) {
      if (lowerCaseText.contains(keyword)) {
        return WinLossMatchResult(outcome: GameOutcome.victory);
      }
    }

    for (final keyword in defeatKeywords) {
      if (lowerCaseText.contains(keyword)) {
        return WinLossMatchResult(outcome: GameOutcome.defeat);
      }
    }

    return WinLossMatchResult(outcome: GameOutcome.unknown);
  }
}
