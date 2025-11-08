abstract class MatchResult {
  Map<String, dynamic> toJson();
}

abstract class ScoreParser {
  MatchResult parse(String ocrText);
}
