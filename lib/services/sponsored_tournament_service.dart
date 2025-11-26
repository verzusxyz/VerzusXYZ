import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/core/services/firebase_service.dart';
import 'package:verzus/features/tournaments/data/models/sponsored_tournament_model.dart';

final sponsoredTournamentServiceProvider =
    Provider<SponsoredTournamentService>((ref) {
  return SponsoredTournamentService(ref.read(firebaseServiceProvider));
});

class SponsoredTournamentService {
  final FirebaseService _firebaseService;

  SponsoredTournamentService(this._firebaseService);

  FirebaseFirestore get _firestore => _firebaseService.firestore;

  CollectionReference<SponsoredTournamentModel>
      get _sponsoredTournamentsRef =>
          _firestore.collection('sponsored_tournaments').withConverter<SponsoredTournamentModel>(
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
