import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:verzus/firestore/firestore_data_schema.dart';

class MatchModel {
  final String id;
  final String creatorId;
  final String? opponentId;
  final String skillTopic;
  final double wagerAmount; // Optional stake/entry (can be 0)
  final MatchStatus status;
  final MatchType matchType; // Legacy high-level type (quickPlay/skillBased/private/tournament)
  final MatchFormat matchFormat; // Required UI format: 1v1, FFA, Team-based
  final String gameMode;
  final String? winnerId;
  final String? loserId;
  final int? creatorScore;
  final int? opponentScore;
  final DateTime? startTime;
  final DateTime? endTime;
  final Map<String, dynamic>? gameData;
  final List<String> participants; // For FFA/Team-based; includes creatorId
  final double platformFee;
  final String? tournamentId; // linkage if part of tournament
  final int? tournamentRound;
  final int? tournamentMatchIndex;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MatchModel({
    required this.id,
    required this.creatorId,
    this.opponentId,
    required this.skillTopic,
    required this.wagerAmount,
    this.status = MatchStatus.pending,
    this.matchType = MatchType.quickPlay,
    this.matchFormat = MatchFormat.oneVOne,
    this.gameMode = 'standard',
    this.winnerId,
    this.loserId,
    this.creatorScore,
    this.opponentScore,
    this.startTime,
    this.endTime,
    this.gameData,
    this.participants = const [],
    this.platformFee = 0.0,
    this.tournamentId,
    this.tournamentRound,
    this.tournamentMatchIndex,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MatchModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MatchModel(
      id: doc.id,
      creatorId: data[MatchDocument.creatorId] ?? '',
      opponentId: data[MatchDocument.opponentId],
      skillTopic: data[MatchDocument.skillTopic] ?? '',
      wagerAmount: (data[MatchDocument.wagerAmount] ?? 0.0).toDouble(),
      status: MatchStatus.values.firstWhere(
        (e) => e.name == data[MatchDocument.status],
        orElse: () => MatchStatus.pending,
      ),
      matchType: MatchType.values.firstWhere(
        (e) => e.name == data[MatchDocument.matchType],
        orElse: () => MatchType.quickPlay,
      ),
      matchFormat: MatchFormat.values.firstWhere(
        (e) => e.name == (data[MatchDocument.matchFormat] ?? MatchFormat.oneVOne.name),
        orElse: () => MatchFormat.oneVOne,
      ),
      gameMode: data[MatchDocument.gameMode] ?? 'standard',
      winnerId: data[MatchDocument.winnerId],
      loserId: data[MatchDocument.loserId],
      creatorScore: data[MatchDocument.creatorScore],
      opponentScore: data[MatchDocument.opponentScore],
      startTime: FirestoreHelpers.timestampToDateTime(data[MatchDocument.startTime]),
      endTime: FirestoreHelpers.timestampToDateTime(data[MatchDocument.endTime]),
      gameData: data[MatchDocument.gameData],
      participants: (data[MatchDocument.participants] as List<dynamic>? ?? const []).map((e) => e.toString()).toList(),
      platformFee: (data[MatchDocument.platformFee] ?? 0.0).toDouble(),
      tournamentId: data[MatchDocument.tournamentId],
      tournamentRound: data[MatchDocument.tournamentRound],
      tournamentMatchIndex: data[MatchDocument.tournamentMatchIndex],
      createdAt: FirestoreHelpers.timestampToDateTime(data[MatchDocument.createdAt]) ?? DateTime.now(),
      updatedAt: FirestoreHelpers.timestampToDateTime(data[MatchDocument.updatedAt]) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      MatchDocument.id: id,
      MatchDocument.creatorId: creatorId,
      MatchDocument.opponentId: opponentId,
      MatchDocument.skillTopic: skillTopic,
      MatchDocument.wagerAmount: wagerAmount,
      MatchDocument.status: status.name,
      MatchDocument.matchType: matchType.name,
      MatchDocument.matchFormat: matchFormat.name,
      MatchDocument.gameMode: gameMode,
      MatchDocument.winnerId: winnerId,
      MatchDocument.loserId: loserId,
      MatchDocument.creatorScore: creatorScore,
      MatchDocument.opponentScore: opponentScore,
      MatchDocument.startTime: startTime != null ? FirestoreHelpers.dateTimeToTimestamp(startTime!) : null,
      MatchDocument.endTime: endTime != null ? FirestoreHelpers.dateTimeToTimestamp(endTime!) : null,
      MatchDocument.gameData: gameData,
      MatchDocument.participants: participants,
      MatchDocument.platformFee: platformFee,
      MatchDocument.tournamentId: tournamentId,
      MatchDocument.tournamentRound: tournamentRound,
      MatchDocument.tournamentMatchIndex: tournamentMatchIndex,
      MatchDocument.createdAt: FirestoreHelpers.dateTimeToTimestamp(createdAt),
      MatchDocument.updatedAt: FieldValue.serverTimestamp(),
    };
  }

  bool get isActive => status == MatchStatus.active;
  bool get isCompleted => status == MatchStatus.completed;
  bool get canJoin {
    if (status != MatchStatus.pending) return false;
    if (matchFormat == MatchFormat.oneVOne) {
      return opponentId == null;
    }
    return true; // FFA/Team-based will manage capacity elsewhere
  }
  bool get hasOpponent => opponentId != null;

  MatchModel copyWith({
    String? opponentId,
    String? skillTopic,
    double? wagerAmount,
    MatchStatus? status,
    MatchType? matchType,
    MatchFormat? matchFormat,
    String? gameMode,
    String? winnerId,
    String? loserId,
    int? creatorScore,
    int? opponentScore,
    DateTime? startTime,
    DateTime? endTime,
    Map<String, dynamic>? gameData,
    List<String>? participants,
    double? platformFee,
    String? tournamentId,
    int? tournamentRound,
    int? tournamentMatchIndex,
    DateTime? updatedAt,
  }) {
    return MatchModel(
      id: id,
      creatorId: creatorId,
      opponentId: opponentId ?? this.opponentId,
      skillTopic: skillTopic ?? this.skillTopic,
      wagerAmount: wagerAmount ?? this.wagerAmount,
      status: status ?? this.status,
      matchType: matchType ?? this.matchType,
      matchFormat: matchFormat ?? this.matchFormat,
      gameMode: gameMode ?? this.gameMode,
      winnerId: winnerId ?? this.winnerId,
      loserId: loserId ?? this.loserId,
      creatorScore: creatorScore ?? this.creatorScore,
      opponentScore: opponentScore ?? this.opponentScore,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      gameData: gameData ?? this.gameData,
      participants: participants ?? this.participants,
      platformFee: platformFee ?? this.platformFee,
      tournamentId: tournamentId ?? this.tournamentId,
      tournamentRound: tournamentRound ?? this.tournamentRound,
      tournamentMatchIndex: tournamentMatchIndex ?? this.tournamentMatchIndex,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum MatchType {
  quickPlay,
  skillBased,
  private,
  tournament,
}

enum MatchFormat {
  oneVOne, // 1v1
  freeForAll, // FFA
  teamBased, // Teams
}

enum MatchStatus {
  pending,    // Waiting for opponent/participants
  active,     // Match in progress
  completed,  // Match finished
  cancelled,  // Match cancelled
  disputed,   // Under dispute
}

extension MatchTypeX on MatchType {
  String get displayName {
    switch (this) {
      case MatchType.quickPlay:
        return 'Quick Play';
      case MatchType.skillBased:
        return 'Skill Based';
      case MatchType.private:
        return 'Private Match';
      case MatchType.tournament:
        return 'Tournament';
    }
  }
}

extension MatchFormatX on MatchFormat {
  String get displayName {
    switch (this) {
      case MatchFormat.oneVOne:
        return '1v1';
      case MatchFormat.freeForAll:
        return 'Free-for-all';
      case MatchFormat.teamBased:
        return 'Team-based';
    }
  }
}

extension MatchStatusX on MatchStatus {
  String get displayName {
    switch (this) {
      case MatchStatus.pending:
        return 'Waiting for Participants';
      case MatchStatus.active:
        return 'In Progress';
      case MatchStatus.completed:
        return 'Completed';
      case MatchStatus.cancelled:
        return 'Cancelled';
      case MatchStatus.disputed:
        return 'Disputed';
    }
  }

  bool get isFinalized => [MatchStatus.completed, MatchStatus.cancelled].contains(this);
  bool get canCancel => this == MatchStatus.pending;
}
