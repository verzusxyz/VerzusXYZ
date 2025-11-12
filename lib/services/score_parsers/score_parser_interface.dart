class ParsedMatchResult {
  final int? player1Score;
  final int? player2Score;
  final String? winnerId; // This will be determined later

  ParsedMatchResult({this.player1Score, this.player2Score, this.winnerId});
}

abstract class ScoreParser {
  ParsedMatchResult parse(String ocrText);
}
