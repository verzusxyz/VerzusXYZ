import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/core/services/firebase_service.dart';
import 'package:verzus/features/admin/data/repositories/admin_repository.dart';
import 'package:verzus/features/admin/data/repositories/sponsored_tournament_repository.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(ref.read(firebaseServiceProvider));
});

final sponsoredTournamentRepositoryProvider =
    Provider<SponsoredTournamentRepository>((ref) {
  return SponsoredTournamentRepository(ref.read(firebaseServiceProvider));
});
