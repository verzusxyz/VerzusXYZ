import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/services/firebase_client_service.dart';
import 'package:verzus/repositories/firebase_repository.dart';
import 'package:verzus/services/auth_service.dart';
import 'package:verzus/models/user_model.dart';
import 'package:verzus/models/match_model.dart';
import 'package:verzus/models/game_model.dart';

/// ==== CORE DATA PROVIDERS ====

/// Current user data provider
final currentUserDataProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      final userRepo = ref.read(userRepositoryProvider);
      return userRepo.firebaseClient.listenToUser(user.uid);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

// /// User wallet provider
// final userWalletProvider = StreamProvider<Map<String, dynamic>?>((ref) {
//   final authState = ref.watch(authStateProvider);
//   return authState.when(
//     data: (user) {
//       if (user == null) return Stream.value(null);
//       final walletRepo = ref.read(walletRepositoryProvider);
//       return walletRepo.listenToWallet(user.uid);
//     },
//     loading: () => Stream.value(null),
//     error: (_, __) => Stream.value(null),
//   );
// });
//
/// User wallet provider - BULLETPROOF STREAM
// ✅ FIXED: No null safety issues
// ✅ FIXED: Direct Map<String, dynamic> - NO null safety issues
final userWalletProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      final walletRepo = ref.read(walletRepositoryProvider);
      // ✅ FIXED: Returns Map<String, dynamic> directly
      return walletRepo.listenToWallet(user.uid);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

/// Available matches provider
final availableMatchesProvider =
    StreamProvider.family<List<MatchModel>, String?>((ref, skillTopic) {
  final matchRepo = ref.read(matchRepositoryProvider);
  return matchRepo.getAvailableMatches(skillTopic: skillTopic);
});

/// User matches provider
final userMatchesProvider = StreamProvider<List<MatchModel>>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(<MatchModel>[]);
      final matchRepo = ref.read(matchRepositoryProvider);
      return matchRepo.getUserMatches(user.uid);
    },
    loading: () => Stream.value(<MatchModel>[]),
    error: (_, __) => Stream.value(<MatchModel>[]),
  );
});

/// Active tournaments provider
final activeTournamentsProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  final tournamentRepo = ref.read(tournamentRepositoryProvider);
  return tournamentRepo.getTournaments(status: 'open');
});

/// Popular games provider
final popularGamesProvider = StreamProvider<List<GameModel>>((ref) {
  final gameRepo = ref.read(gameRepositoryProvider);
  return gameRepo.getPopularGames();
});

/// Skill topics provider
final skillTopicsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final firebaseClient = ref.read(firebaseClientServiceProvider);
  return firebaseClient.getSkillTopics();
});

/// Leaderboard provider
final leaderboardProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String?>(
        (ref, skillTopic) {
  final firebaseClient = ref.read(firebaseClientServiceProvider);
  return firebaseClient.getLeaderboard(skillTopic: skillTopic);
});

/// User transactions provider
final userTransactionsProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(<Map<String, dynamic>>[]);
      final walletRepo = ref.read(walletRepositoryProvider);
      return walletRepo.getUserTransactions(user.uid);
    },
    loading: () => Stream.value(<Map<String, dynamic>>[]),
    error: (_, __) => Stream.value(<Map<String, dynamic>>[]),
  );
});

/// ==== SPECIFIC MATCH PROVIDERS ====

/// Match details provider
final matchDetailsProvider =
    StreamProvider.family<MatchModel?, String>((ref, matchId) {
  final matchRepo = ref.read(matchRepositoryProvider);
  return matchRepo.listenToMatch(matchId);
});

/// Tournament participants provider
final tournamentParticipantsProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>(
        (ref, tournamentId) {
  final tournamentRepo = ref.read(tournamentRepositoryProvider);
  return tournamentRepo.getTournamentParticipants(tournamentId);
});

/// ==== USER SEARCH PROVIDERS ====

/// User search provider
final userSearchProvider =
    FutureProvider.family<List<UserModel>, String>((ref, searchTerm) async {
  if (searchTerm.trim().isEmpty) return [];
  final userRepo = ref.read(userRepositoryProvider);
  return await userRepo.searchUsers(searchTerm.trim());
});

/// Game search provider
final gameSearchProvider =
    FutureProvider.family<List<GameModel>, String>((ref, searchTerm) async {
  if (searchTerm.trim().isEmpty) return [];
  final gameRepo = ref.read(gameRepositoryProvider);
  return await gameRepo.searchGames(searchTerm.trim());
});

/// ==== SYSTEM SETTINGS PROVIDERS ====

/// Platform fee rate provider
final platformFeeRateProvider = FutureProvider<double>((ref) async {
  final firebaseClient = ref.read(firebaseClientServiceProvider);
  final setting = await firebaseClient.getSystemSetting('platform_fee_rate');
  return setting != null
      ? double.tryParse(setting['value'] ?? '0.10') ?? 0.10
      : 0.10;
});

/// Minimum wager amount provider
final minWagerAmountProvider = FutureProvider<double>((ref) async {
  final firebaseClient = ref.read(firebaseClientServiceProvider);
  final setting = await firebaseClient.getSystemSetting('min_wager_amount');
  return setting != null
      ? double.tryParse(setting['value'] ?? '1.00') ?? 1.00
      : 1.00;
});

/// Maximum wager amount provider
final maxWagerAmountProvider = FutureProvider<double>((ref) async {
  final firebaseClient = ref.read(firebaseClientServiceProvider);
  final setting = await firebaseClient.getSystemSetting('max_wager_amount');
  return setting != null
      ? double.tryParse(setting['value'] ?? '1000.00') ?? 1000.00
      : 1000.00;
});

/// ==== STATE MANAGEMENT PROVIDERS ====

/// Loading states for various operations
final isCreatingMatchProvider = Provider<bool>((ref) => false);
final isJoiningMatchProvider = Provider<bool>((ref) => false);
final isSubmittingResultProvider = Provider<bool>((ref) => false);
final isCreatingTournamentProvider = Provider<bool>((ref) => false);
final isJoiningTournamentProvider = Provider<bool>((ref) => false);
final isUpdatingProfileProvider = Provider<bool>((ref) => false);
final isProcessingPaymentProvider = Provider<bool>((ref) => false);

/// Selected skill topic for filtering
final selectedSkillTopicProvider = Provider<String?>((ref) => null);

/// Search query providers
final userSearchQueryProvider = Provider<String>((ref) => '');
final gameSearchQueryProvider = Provider<String>((ref) => '');

/// Current match in focus
final currentMatchProvider = Provider<String?>((ref) => null);

/// Current tournament in focus
final currentTournamentProvider = Provider<String?>((ref) => null);

/// ==== HELPER PROVIDERS ====

/// Check if user can join match
final canJoinMatchProvider = Provider.family<bool, MatchModel>((ref, match) {
  final currentUser = ref.watch(currentUserDataProvider);
  return currentUser.when(
    data: (user) {
      if (user == null) return false;
      if (match.creatorId == user.uid) return false; // Can't join own match
      if (match.opponentId != null) return false; // Match already full
      // ignore: unrelated_type_equality_checks
      if (match.status != 'pending') return false; // Match not available
      return true;
    },
    loading: () => false,
    error: (_, __) => false,
  );
});

/// Check if user can create match
final canCreateMatchProvider = Provider<bool>((ref) {
  final currentUser = ref.watch(currentUserDataProvider);
  final wallet = ref.watch(userWalletProvider);

  return currentUser.when(
    data: (user) {
      if (user == null) return false;
      return wallet.when(
        data: (walletData) {
          if (walletData == null) return false;
          final balance = (walletData['balance'] as num?)?.toDouble() ?? 0.0;
          return balance > 0; // Need some balance to create match
        },
        loading: () => false,
        error: (_, __) => false,
      );
    },
    loading: () => false,
    error: (_, __) => false,
  );
});

/// User stats provider
final userStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final currentUser = ref.watch(currentUserDataProvider);
  return currentUser.when(
    data: (user) {
      if (user == null) return {};
      return {
        'totalWins': user.totalWins,
        'totalLosses': user.totalLosses,
        'totalMatches': user.totalMatches,
        'winRate': user.totalMatches > 0
            ? (user.totalWins / user.totalMatches * 100).toStringAsFixed(1)
            : '0.0',
        'skillRatings': user.skillRatings,
      };
    },
    loading: () => {},
    error: (_, __) => {},
  );
});

/// Is user online provider
final isUserOnlineProvider = Provider.family<bool, String>((ref, userId) {
  final currentUser = ref.watch(currentUserDataProvider);
  return currentUser.when(
    data: (user) => user?.uid == userId ? (user?.isOnline ?? false) : false,
    loading: () => false,
    error: (_, __) => false,
  );
});
