import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/core/services/firebase_service.dart';
import 'package:verzus/features/topics/data/repositories/topics_repository.dart';

final topicsRepositoryProvider = Provider<TopicsRepository>((ref) {
  return TopicsRepository(ref.read(firebaseServiceProvider));
});
