import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/services/firestore_storage_service.dart';

final firestoreStorageServiceProvider = Provider<FirestoreStorageService>((ref) {
  return FirestoreStorageService();
});
