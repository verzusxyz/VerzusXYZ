import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? data;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
    this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
      'data': data,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      createdAt: (map['createdAt'] as Timestamp? ?? Timestamp.now()).toDate(),
      isRead: map['isRead'] ?? false,
      data: map['data'] as Map<String, dynamic>?,
    );
  }
}
