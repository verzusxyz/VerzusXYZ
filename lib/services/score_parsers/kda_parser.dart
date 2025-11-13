import 'package:verzus/services/score_parsers/score_parser_interface.dart';

class Kda {
  final int kills;
  final int deaths;
  final int assists;

  Kda({required this.kills, required this.deaths, required this.assists});

  double get ratio => deaths == 0 ? kills.toDouble() : kills / deaths;

  Map<String, dynamic> toJson() {
    return {
      'kills': kills,
      'deaths': deaths,
      'assists': assists,
    };
  }
}

class KdaMatchResult extends MatchResult {
  final Map<String, Kda> playerKdas;
  final String winner;

  KdaMatchResult({required this.playerKdas, required this.winner});

  Map<String, dynamic> toJson() {
    return {
      'playerKdas': playerKdas.map((key, value) => MapEntry(key, value.toJson())),
      'winner': winner,
    };
  }
}

class KdaParser implements ScoreParser {
  @override
  MatchResult parse(String ocrText) {
    // This is a simplified implementation. A real implementation would need
    // to be much more sophisticated to handle the variety of scoreboard formats.
    final playerKdas = <String, Kda>{};
    final lines = ocrText.split('\n');

    for (final line in lines) {
      final match = RegExp(r'(\w+)\s+(\d+)\s*/\s*(\d+)\s*/\s*(\d+)').firstMatch(line);
      if (match != null) {
        final playerName = match.group(1)!;
        final kills = int.tryParse(match.group(2)!) ?? 0;
        final deaths = int.tryParse(match.group(3)!) ?? 0;
        final assists = int.tryParse(match.group(4)!) ?? 0;
        playerKdas[playerName] = Kda(kills: kills, deaths: deaths, assists: assists);
      }
    }

    String winner = '';
    double maxRatio = 0.0;
    playerKdas.forEach((player, kda) {
      if (kda.ratio > maxRatio) {
        maxRatio = kda.ratio;
        winner = player;
      }
    });

    return KdaMatchResult(playerKdas: playerKdas, winner: winner);
  }
}
