import 'package:verzus/services/score_parsers/score_parser_interface.dart';

class KdaBasedParser implements ScoreParser {
  @override
  ParsedMatchResult parse(String ocrText) {
    // KDA parsing is highly game-specific and complex.
    // This is a placeholder implementation that assumes a simple format.
    // e.g., "Player1: 10/2/5, Player2: 5/3/8"
    // For now, we will just return empty results.
    // A more robust implementation would require significant regex and logic.
    return ParsedMatchResult();
  }
}
