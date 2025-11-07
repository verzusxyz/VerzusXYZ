import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore data schema definitions for VerzusXYZ
/// This file defines the structure and field names for all Firestore collections

class FirestoreSchema {
  static const String users = 'users';
  static const String usernames = 'usernames';
  static const String wallets = 'wallets';
  static const String walletTransactions = 'wallet_transactions';
  static const String matches = 'matches';
  static const String matchInvitations = 'match_invitations';
  static const String tournaments = 'tournaments';
  static const String tournamentParticipants = 'tournament_participants';
  static const String skillTopics = 'skill_topics';
  static const String leaderboardEntries = 'leaderboard_entries';
  static const String gameResults = 'game_results';
  static const String systemSettings = 'system_settings';
}

/// User document structure
class UserDocument {
  static const String id = 'id';
  static const String username = 'username';
  static const String email = 'email';
  static const String displayName = 'display_name';
  static const String profileImageUrl = 'profile_image_url';
  static const String skillRatings = 'skill_ratings';
  static const String totalWins = 'total_wins';
  static const String totalLosses = 'total_losses';
  static const String totalMatches = 'total_matches';
  static const String isOnline = 'is_online';
  static const String lastSeen = 'last_seen';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}

/// Wallet document structure
class WalletDocument {
  static const String id = 'id';
  static const String userId = 'user_id';
  static const String balance = 'balance';
  static const String pendingBalance = 'pending_balance';
  static const String totalDeposited = 'total_deposited';
  static const String totalWithdrawn = 'total_withdrawn';
  static const String totalWon = 'total_won';
  static const String totalLost = 'total_lost';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}

/// Wallet transaction document structure
class WalletTransactionDocument {
  static const String id = 'id';
  static const String userId = 'user_id';
  static const String type = 'type';
  static const String amount = 'amount';
  static const String status = 'status';
  static const String description = 'description';
  static const String relatedMatchId = 'related_match_id';
  static const String relatedTournamentId = 'related_tournament_id';
  static const String paymentMethod = 'payment_method';
  static const String externalTransactionId = 'external_transaction_id';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}

/// Match document structure
class MatchDocument {
  static const String id = 'id';
  static const String creatorId = 'creator_id';
  static const String opponentId = 'opponent_id';
  static const String skillTopic = 'skill_topic';
  static const String wagerAmount = 'wager_amount';
  static const String status = 'status';
  static const String matchType = 'match_type';
  static const String matchFormat = 'match_format';
  static const String participants = 'participants';
  static const String gameMode = 'game_mode';
  static const String winnerId = 'winner_id';
  static const String loserId = 'loser_id';
  static const String creatorScore = 'creator_score';
  static const String opponentScore = 'opponent_score';
  static const String startTime = 'start_time';
  static const String endTime = 'end_time';
  static const String gameData = 'game_data';
  static const String platformFee = 'platform_fee';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
  // Tournament linkage (optional)
  static const String tournamentId = 'tournament_id';
  static const String tournamentRound = 'tournament_round';
  static const String tournamentMatchIndex = 'tournament_match_index';
}

/// Match invitation document structure
class MatchInvitationDocument {
  static const String id = 'id';
  static const String matchId = 'match_id';
  static const String creatorId = 'creator_id';
  static const String invitedUserId = 'invited_user_id';
  static const String status = 'status';
  static const String expiresAt = 'expires_at';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}

/// Tournament document structure
class TournamentDocument {
  static const String id = 'id';
  static const String creatorId = 'creator_id';
  static const String title = 'title';
  static const String description = 'description';
  static const String skillTopic = 'skill_topic';
  static const String entryFee = 'entry_fee';
  static const String prizePool = 'prize_pool';
  static const String maxParticipants = 'max_participants';
  static const String currentParticipants = 'current_participants';
  static const String status = 'status';
  static const String tournamentType = 'tournament_type'; // single_elim, double_elim, round_robin, pools_knockout
  static const String startDate = 'start_date';
  static const String endDate = 'end_date';
  static const String registrationDeadline = 'registration_deadline';
  static const String rules = 'rules';
  static const String platformFee = 'platform_fee'; // computed upon payout (20% default)
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
  // Extended fields for user-created tournaments
  static const String visibility = 'visibility'; // public, private
  static const String inviteCode = 'invite_code'; // for private tournaments
  static const String payoutMode = 'payout_mode'; // winner_takes_all, top3, custom
  static const String payoutRatios = 'payout_ratios'; // map: rank->percentage, must sum to 100
  static const String checkinDeadlineMins = 'checkin_deadline_mins';
  static const String matchDeadlineMins = 'match_deadline_mins';
  static const String matchBestOf = 'match_best_of'; // 1,3,5
  static const String seeding = 'seeding'; // random, elo
  static const String pools = 'pools'; // optional config when pools_knockout
  static const String walletKind = 'wallet_kind'; // live or demo
  static const String gameId = 'game_id';
  static const String inviteLinks = 'invite_links'; // array of shareable links
  static const String createdInviteCount = 'created_invite_count';
  static const String entryFeesTotal = 'entry_fees_total'; // running total of entries
  static const String commissionRate = 'commission_rate'; // default 0.20
  static const String bracket = 'bracket'; // serialized bracket tree or schedule
  // Dispute & notifications
  static const String disputePolicy = 'dispute_policy'; // creator_judge, admin, community
  static const String judgeUserId = 'judge_user_id'; // defaults to creator_id when creator_judge
  static const String notifyOnPairing = 'notify_on_pairing';
  static const String notifyOnDeadline = 'notify_on_deadline';
}

/// Tournament participant document structure
class TournamentParticipantDocument {
  static const String id = 'id';
  static const String tournamentId = 'tournament_id';
  static const String userId = 'user_id';
  static const String rank = 'rank';
  static const String score = 'score';
  static const String status = 'status';
  static const String joinedAt = 'joined_at';
}

/// Skill topic document structure
class SkillTopicDocument {
  static const String id = 'id';
  static const String name = 'name';
  static const String description = 'description';
  static const String category = 'category';
  static const String iconUrl = 'icon_url';
  static const String isActive = 'is_active';
  static const String minWager = 'min_wager';
  static const String maxWager = 'max_wager';
  static const String gameConfig = 'game_config';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}

/// Leaderboard entry document structure
class LeaderboardEntryDocument {
  static const String id = 'id';
  static const String userId = 'user_id';
  static const String skillTopic = 'skill_topic';
  static const String skillRating = 'skill_rating';
  static const String totalWins = 'total_wins';
  static const String totalLosses = 'total_losses';
  static const String totalMatches = 'total_matches';
  static const String winRate = 'win_rate';
  static const String totalEarnings = 'total_earnings';
  static const String rank = 'rank';
  static const String updatedAt = 'updated_at';
}

/// Game result document structure
class GameResultDocument {
  static const String id = 'id';
  static const String matchId = 'match_id';
  static const String player1Id = 'player1_id';
  static const String player2Id = 'player2_id';
  static const String player1Score = 'player1_score';
  static const String player2Score = 'player2_score';
  static const String winnerId = 'winner_id';
  static const String gameData = 'game_data';
  static const String duration = 'duration';
  static const String createdAt = 'created_at';
}

/// System settings document structure
class SystemSettingsDocument {
  static const String id = 'id';
  static const String key = 'key';
  static const String value = 'value';
  static const String description = 'description';
  static const String updatedAt = 'updated_at';
}

/// Admin financials ledger
class AdminFinancialsSchema {
  static const String collection = 'admin_financials';
  static const String commissions = 'commissions'; // doc id
  static const String totalCommission = 'total_commission';
  static const String updatedAt = 'updated_at';
}

/// Common field values and constants
class FirestoreConstants {
  // Match status values
  static const String matchStatusPending = 'pending';
  static const String matchStatusActive = 'active';
  static const String matchStatusCompleted = 'completed';
  static const String matchStatusCancelled = 'cancelled';
  static const String matchStatusDisputed = 'disputed';
  
  // Tournament status values
  static const String tournamentStatusDraft = 'draft';
  static const String tournamentStatusOpen = 'open';
  static const String tournamentStatusStarted = 'started';
  static const String tournamentStatusCompleted = 'completed';
  static const String tournamentStatusCancelled = 'cancelled';
  
  // Transaction types
  static const String transactionTypeDeposit = 'deposit';
  static const String transactionTypeWithdrawal = 'withdrawal';
  static const String transactionTypeWager = 'wager';
  static const String transactionTypeWin = 'win';
  static const String transactionTypeFee = 'fee';
  static const String transactionTypeRefund = 'refund';
  
  // Transaction status values
  static const String transactionStatusPending = 'pending';
  static const String transactionStatusCompleted = 'completed';
  static const String transactionStatusFailed = 'failed';
  static const String transactionStatusCancelled = 'cancelled';
  
  // Match types
  static const String matchTypeQuickPlay = 'quick_play';
  static const String matchTypeSkillBased = 'skill_based';
  static const String matchTypePrivate = 'private';
  static const String matchTypeTournament = 'tournament';
  
  // Invitation status values
  static const String invitationStatusPending = 'pending';
  static const String invitationStatusAccepted = 'accepted';
  static const String invitationStatusDeclined = 'declined';
  static const String invitationStatusExpired = 'expired';
  
  // System setting keys
  static const String settingPlatformFeeRate = 'platform_fee_rate';
  static const String settingMinWagerAmount = 'min_wager_amount';
  static const String settingMaxWagerAmount = 'max_wager_amount';
  static const String settingMinWithdrawalAmount = 'min_withdrawal_amount';
  static const String settingMaintenanceMode = 'maintenance_mode';
}

/// Helper functions for Firestore operations
class FirestoreHelpers {
  /// Convert Firestore timestamp to DateTime
  static DateTime? timestampToDateTime(dynamic timestamp) {
    if (timestamp == null) return null;
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is String && timestamp == 'TIMESTAMP') return DateTime.now();
    return null;
  }
  
  /// Convert DateTime to Firestore timestamp
  static Timestamp dateTimeToTimestamp(DateTime dateTime) {
    return Timestamp.fromDate(dateTime);
  }
  
  /// Get current timestamp for Firestore
  static Timestamp getCurrentTimestamp() {
    return Timestamp.now();
  }
  
  /// Generate a new document ID
  static String generateDocumentId() {
    return FirebaseFirestore.instance.collection('temp').doc().id;
  }
}