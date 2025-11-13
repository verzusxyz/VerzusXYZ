import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/services/firestore_storage_service.dart';
import 'package:verzus/services/firebase_client_service.dart';

final firestoreStorageServiceProvider = Provider<FirestoreStorageService>((ref) {
  final firebaseClient = ref.watch(firebaseClientServiceProvider);
  return FirestoreStorageService(firebaseClient);
});
