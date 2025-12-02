import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/features/tournaments/data/models/sponsored_tournament_model.dart';

final sponsoredTournamentRepository =
    Provider<SponsoredTournamentRepository>((ref) {
  return SponsoredTournamentRepository(firestore: FirebaseFirestore.instance);
});

class SponsoredTournamentRepository {
  final FirebaseFirestore _firestore;

  SponsoredTournamentRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<SponsoredTournamentModel> get _sponsoredTournamentsRef =>
      _firestore
          .collection('sponsored_tournaments')
          .withConverter<SponsoredTournamentModel>(
            fromFirestore: (snapshot, _) =>
                SponsoredTournamentModel.fromJson(snapshot.data()!),
            toFirestore: (tournament, _) => tournament.toJson(),
          );

  Future<void> createSponsoredTournament({
    required String name,
    required double prizePool,
    required Map<int, double> prizeDistribution,
  }) async {
    final newDoc = _sponsoredTournamentsRef.doc();
    final tournament = SponsoredTournamentModel(
      id: newDoc.id,
      name: name,
      prizePool: prizePool,
      prizeDistribution: prizeDistribution,
      createdAt: DateTime.now(),
    );
    await newDoc.set(tournament);
  }
}
