import 'package:cloud_firestore/cloud_firestore.dart';

class GameModel {
  final String gameId;
  final String title;
  final String platform; // android, ios, web
  final String? packageId; // for Android
  final String? bundleId; // for iOS  
  final String? webUrl; // for web games
  final String? iconUrl;
  final DefaultCropData? defaultCropData;
  final bool autoGenEnabled;
  final double popularityScore;
  final bool supportsRoomUrl;
  final bool supportsRoomCode;
  final bool supportsBoardState;
  final List<String> roomIdPatterns;
  final DateTime createdAt;
  final String? approvedBy;

  const GameModel({
    required this.gameId,
    required this.title,
    required this.platform,
    this.packageId,
    this.bundleId,
    this.webUrl,
    this.iconUrl,
    this.defaultCropData,
    this.autoGenEnabled = true,
    this.popularityScore = 0.0,
    this.supportsRoomUrl = false,
    this.supportsRoomCode = false,
    this.supportsBoardState = false,
    this.roomIdPatterns = const [],
    required this.createdAt,
    this.approvedBy,
  });

  factory GameModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GameModel(
      gameId: doc.id,
      title: data['title'] ?? '',
      platform: data['platform'] ?? '',
      packageId: data['packageId'],
      bundleId: data['bundleId'],
      webUrl: data['webUrl'],
      iconUrl: data['iconUrl'],
      defaultCropData: data['defaultCropData'] != null
        ? DefaultCropData.fromMap(data['defaultCropData'])
        : null,
      autoGenEnabled: data['autoGenEnabled'] ?? true,
      popularityScore: (data['popularityScore'] ?? 0.0).toDouble(),
      supportsRoomUrl: data['supportsRoomUrl'] ?? false,
      supportsRoomCode: data['supportsRoomCode'] ?? false,
      supportsBoardState: data['supportsBoardState'] ?? false,
      roomIdPatterns: List<String>.from(data['roomIdPatterns'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      approvedBy: data['approvedBy'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'platform': platform,
      'packageId': packageId,
      'bundleId': bundleId,
      'webUrl': webUrl,
      'iconUrl': iconUrl,
      'defaultCropData': defaultCropData?.toMap(),
      'autoGenEnabled': autoGenEnabled,
      'popularityScore': popularityScore,
      'supportsRoomUrl': supportsRoomUrl,
      'supportsRoomCode': supportsRoomCode,
      'supportsBoardState': supportsBoardState,
      'roomIdPatterns': roomIdPatterns,
      'createdAt': Timestamp.fromDate(createdAt),
      'approvedBy': approvedBy,
    };
  }

  String get identifier {
    switch (platform) {
      case 'android':
        return 'android:${packageId ?? 'unknown'}';
      case 'ios':
        return 'ios:${bundleId ?? 'unknown'}';
      case 'web':
        return 'web:${webUrl ?? 'unknown'}';
      default:
        return gameId;
    }
  }
}

class DefaultCropData {
  final CropRect scoreRect;
  final CropRect usernameRect;
  final CropRect? roomCodeRect;

  const DefaultCropData({
    required this.scoreRect,
    required this.usernameRect,
    this.roomCodeRect,
  });

  factory DefaultCropData.fromMap(Map<String, dynamic> map) {
    return DefaultCropData(
      scoreRect: CropRect.fromMap(map['scoreRect']),
      usernameRect: CropRect.fromMap(map['usernameRect']),
      roomCodeRect: map['roomCodeRect'] != null
        ? CropRect.fromMap(map['roomCodeRect'])
        : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'scoreRect': scoreRect.toMap(),
      'usernameRect': usernameRect.toMap(),
      'roomCodeRect': roomCodeRect?.toMap(),
    };
  }
}

class CropRect {
  final double x;
  final double y;
  final double width;
  final double height;

  const CropRect({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  factory CropRect.fromMap(Map<String, dynamic> map) {
    return CropRect(
      x: (map['x'] ?? 0.0).toDouble(),
      y: (map['y'] ?? 0.0).toDouble(),
      width: (map['width'] ?? 0.0).toDouble(),
      height: (map['height'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'x': x,
      'y': y,
      'width': width,
      'height': height,
    };
  }
}

class GameSubmissionModel {
  final String submissionId;
  final String userId;
  final String platform;
  final String? packageId;
  final String? bundleId;
  final String? webUrl;
  final String gameName;
  final String playerProvidedUsername;
  final DefaultCropData? defaultCropData;
  final List<String> sampleImageUrls;
  final double cropConfidence;
  final List<String> ocrCandidates;
  final GameSubmissionStatus status;
  final DateTime createdAt;
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? reviewNotes;

  const GameSubmissionModel({
    required this.submissionId,
    required this.userId,
    required this.platform,
    this.packageId,
    this.bundleId,
    this.webUrl,
    required this.gameName,
    required this.playerProvidedUsername,
    this.defaultCropData,
    this.sampleImageUrls = const [],
    this.cropConfidence = 0.0,
    this.ocrCandidates = const [],
    this.status = GameSubmissionStatus.pending,
    required this.createdAt,
    this.reviewedBy,
    this.reviewedAt,
    this.reviewNotes,
  });

  factory GameSubmissionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GameSubmissionModel(
      submissionId: doc.id,
      userId: data['userId'] ?? '',
      platform: data['platform'] ?? '',
      packageId: data['packageId'],
      bundleId: data['bundleId'],
      webUrl: data['webUrl'],
      gameName: data['gameName'] ?? '',
      playerProvidedUsername: data['playerProvidedUsername'] ?? '',
      defaultCropData: data['defaultCropData'] != null
        ? DefaultCropData.fromMap(data['defaultCropData'])
        : null,
      sampleImageUrls: List<String>.from(data['sampleImageUrls'] ?? []),
      cropConfidence: (data['cropConfidence'] ?? 0.0).toDouble(),
      ocrCandidates: List<String>.from(data['ocrCandidates'] ?? []),
      status: GameSubmissionStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => GameSubmissionStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      reviewedBy: data['reviewedBy'],
      reviewedAt: data['reviewedAt'] != null
        ? (data['reviewedAt'] as Timestamp).toDate()
        : null,
      reviewNotes: data['reviewNotes'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'platform': platform,
      'packageId': packageId,
      'bundleId': bundleId,
      'webUrl': webUrl,
      'gameName': gameName,
      'playerProvidedUsername': playerProvidedUsername,
      'defaultCropData': defaultCropData?.toMap(),
      'sampleImageUrls': sampleImageUrls,
      'cropConfidence': cropConfidence,
      'ocrCandidates': ocrCandidates,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'reviewedBy': reviewedBy,
      'reviewedAt': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
      'reviewNotes': reviewNotes,
    };
  }
}

enum GameSubmissionStatus {
  pending,
  approved,
  rejected,
  merged,
}

extension GameSubmissionStatusX on GameSubmissionStatus {
  String get displayName {
    switch (this) {
      case GameSubmissionStatus.pending:
        return 'Pending Review';
      case GameSubmissionStatus.approved:
        return 'Approved';
      case GameSubmissionStatus.rejected:
        return 'Rejected';
      case GameSubmissionStatus.merged:
        return 'Merged with Existing';
    }
  }
}