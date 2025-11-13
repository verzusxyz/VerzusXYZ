import 'score_parser_interface.dart';

class KdaBasedParser implements ScoreParser {
  @override
  ParsedMatchResult parse(String ocrText) {
    // This is a basic implementation and may need to be adjusted for specific games.
    // It looks for lines that contain two sets of K/D/A values.
    final lines = ocrText.split('\n');
    final scores = <List<int>>[];

    for (final line in lines) {
      final matches = RegExp(r'(\d+)\s*\/\s*(\d+)\s*\/\s*(\d+)').allMatches(line);
      if (matches.isNotEmpty) {
        for (final match in matches) {
          final k = int.tryParse(match.group(1)!) ?? 0;
          final d = int.tryParse(match.group(2)!) ?? 0;
          final a = int.tryParse(match.group(3)!) ?? 0;
          scores.add([k, d, a]);
        }
      }
    }

    if (scores.length >= 2) {
      // We can't know which player is which, so we'll just assign them
      // and the service layer can determine the winner.
      // A more robust implementation would also parse player names.
      return ParsedMatchResult(
        player1Score: scores[0][0], // Kills
        player2Score: scores[1][0],
      );
    }

    return ParsedMatchResult();
  }
}
