import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/features/admin/data/models/affiliate_level_model.dart';
import 'package:verzus/features/admin/data/models/platform_fee_model.dart';

final adminRepository = Provider<AdminRepository>((ref) {
  return AdminRepository(firestore: FirebaseFirestore.instance);
});

class AdminRepository {
  final FirebaseFirestore _firestore;

  AdminRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  CollectionReference<AffiliateLevelModel> get _affiliateLevelsRef => _firestore
      .collection('affiliate_levels')
      .withConverter<AffiliateLevelModel>(
        fromFirestore: (snapshot, _) =>
            AffiliateLevelModel.fromJson(snapshot.data()!),
        toFirestore: (level, _) => level.toJson(),
      );

  CollectionReference<PlatformFeeModel> get _platformFeesRef =>
      _firestore.collection('platform_fees').withConverter<PlatformFeeModel>(
            fromFirestore: (snapshot, _) =>
                PlatformFeeModel.fromJson(snapshot.data()!),
            toFirestore: (fees, _) => fees.toJson(),
          );

  Future<void> addAffiliateLevel({
    required String name,
    required double commissionRate,
  }) async {
    final newDoc = _affiliateLevelsRef.doc();
    final level = AffiliateLevelModel(
      id: newDoc.id,
      name: name,
      commissionRate: commissionRate,
    );
    await newDoc.set(level);
  }

  Future<void> savePlatformFees({
    required double matches,
    required double tournaments,
    required double autoTournaments,
    required double topics,
  }) async {
    final fees = PlatformFeeModel(
      id: 'default',
      matches: matches,
      tournaments: tournaments,
      autoTournaments: autoTournaments,
      topics: topics,
    );
    await _platformFeesRef.doc('default').set(fees);
  }
}
