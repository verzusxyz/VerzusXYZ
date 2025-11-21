import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:verzus/firestore/firestore_data_schema.dart';

class UserModel {
  final String uid;
  final String displayName;
  final String email;
  final String username;
  final String country;
  final String? phone;
  final KycStatus kycStatus;
  final String? avatarUrl;
  final String? referredBy;
  final Map<String, double> skillRatings;
  final int totalWins;
  final int totalLosses;
  final int totalMatches;
  final bool isOnline;
  final DateTime createdAt;
  final DateTime? lastSeen;

  const UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.username,
    required this.country,
    this.phone,
    this.kycStatus = KycStatus.pending,
    this.avatarUrl,
    this.referredBy,
    this.skillRatings = const {},
    this.totalWins = 0,
    this.totalLosses = 0,
    this.totalMatches = 0,
    this.isOnline = false,
    required this.createdAt,
    this.lastSeen,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      displayName: data[UserDocument.displayName] ?? '',
      email: data[UserDocument.email] ?? '',
      username: data[UserDocument.username] ?? '',
      country: data['country'] ?? '',
      phone: data['phone'],
      kycStatus: KycStatus.values.firstWhere(
        (e) => e.name == data['kycStatus'],
        orElse: () => KycStatus.pending,
      ),
      avatarUrl: data[UserDocument.profileImageUrl],
      referredBy: data['referredBy'],
      skillRatings: Map<String, double>.from(data[UserDocument.skillRatings] ?? {}),
      totalWins: data[UserDocument.totalWins] ?? 0,
      totalLosses: data[UserDocument.totalLosses] ?? 0,
      totalMatches: data[UserDocument.totalMatches] ?? 0,
      isOnline: data[UserDocument.isOnline] ?? false,
      createdAt: FirestoreHelpers.timestampToDateTime(data[UserDocument.createdAt]) ?? DateTime.now(),
      lastSeen: FirestoreHelpers.timestampToDateTime(data[UserDocument.lastSeen]),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      UserDocument.id: uid,
      UserDocument.displayName: displayName,
      UserDocument.email: email,
      UserDocument.username: username,
      'country': country,
      'phone': phone,
      'kycStatus': kycStatus.name,
      UserDocument.profileImageUrl: avatarUrl,
      'referredBy': referredBy,
      UserDocument.skillRatings: skillRatings,
      UserDocument.totalWins: totalWins,
      UserDocument.totalLosses: totalLosses,
      UserDocument.totalMatches: totalMatches,
      UserDocument.isOnline: isOnline,
      UserDocument.createdAt: FirestoreHelpers.dateTimeToTimestamp(createdAt),
      UserDocument.lastSeen: lastSeen != null ? FirestoreHelpers.dateTimeToTimestamp(lastSeen!) : null,
      UserDocument.updatedAt: FieldValue.serverTimestamp(),
    };
  }

  UserModel copyWith({
    String? displayName,
    String? email,
    String? username,
    String? country,
    String? phone,
    KycStatus? kycStatus,
    String? avatarUrl,
    String? referredBy,
    Map<String, double>? skillRatings,
    int? totalWins,
    int? totalLosses,
    int? totalMatches,
    bool? isOnline,
    DateTime? lastSeen,
  }) {
    return UserModel(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      username: username ?? this.username,
      country: country ?? this.country,
      phone: phone ?? this.phone,
      kycStatus: kycStatus ?? this.kycStatus,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      referredBy: referredBy ?? this.referredBy,
      skillRatings: skillRatings ?? this.skillRatings,
      totalWins: totalWins ?? this.totalWins,
      totalLosses: totalLosses ?? this.totalLosses,
      totalMatches: totalMatches ?? this.totalMatches,
      isOnline: isOnline ?? this.isOnline,
      createdAt: createdAt,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}

enum KycStatus {
  pending,
  verified,
  rejected,
  suspended,
}

extension KycStatusX on KycStatus {
  bool get isVerified => this == KycStatus.verified;
  bool get canPlayLive => this == KycStatus.verified;
  
  String get displayName {
    switch (this) {
      case KycStatus.pending:
        return 'Pending Verification';
      case KycStatus.verified:
        return 'Verified';
      case KycStatus.rejected:
        return 'Verification Rejected';
      case KycStatus.suspended:
        return 'Account Suspended';
    }
  }
}