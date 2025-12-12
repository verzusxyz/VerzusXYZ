import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:verzus/firestore/firestore_data_schema.dart';

class TopicModel {
  final String id;
  final String name;
  final String description;
  final String category;
  final String iconUrl;
  final bool isActive;
  final double minWager;
  final double maxWager;
  final Map<String, dynamic> gameConfig;
  final DateTime createdAt;
  final DateTime updatedAt;

  TopicModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.iconUrl,
    required this.isActive,
    required this.minWager,
    required this.maxWager,
    required this.gameConfig,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TopicModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TopicModel(
      id: doc.id,
      name: data[SkillTopicDocument.name] ?? '',
      description: data[SkillTopicDocument.description] ?? '',
      category: data[SkillTopicDocument.category] ?? '',
      iconUrl: data[SkillTopicDocument.iconUrl] ?? '',
      isActive: data[SkillTopicDocument.isActive] ?? false,
      minWager: (data[SkillTopicDocument.minWager] ?? 0.0).toDouble(),
      maxWager: (data[SkillTopicDocument.maxWager] ?? 0.0).toDouble(),
      gameConfig: Map<String, dynamic>.from(data[SkillTopicDocument.gameConfig] ?? {}),
      createdAt: FirestoreHelpers.timestampToDateTime(data[SkillTopicDocument.createdAt]) ?? DateTime.now(),
      updatedAt: FirestoreHelpers.timestampToDateTime(data[SkillTopicDocument.updatedAt]) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      SkillTopicDocument.name: name,
      SkillTopicDocument.description: description,
      SkillTopicDocument.category: category,
      SkillTopicDocument.iconUrl: iconUrl,
      SkillTopicDocument.isActive: isActive,
      SkillTopicDocument.minWager: minWager,
      SkillTopicDocument.maxWager: maxWager,
      SkillTopicDocument.gameConfig: gameConfig,
      SkillTopicDocument.createdAt: FieldValue.serverTimestamp(),
      SkillTopicDocument.updatedAt: FieldValue.serverTimestamp(),
    };
  }
}
