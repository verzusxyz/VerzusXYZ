import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:verzus/firestore/firestore_data_schema.dart';
// import 'package:verzus/models/match_model.dart';
import 'package:verzus/services/capture_bridge.dart';
import 'package:verzus/services/ocr_service.dart';
import 'package:verzus/services/result_tracker.dart';

final matchEngineProvider = Provider<MatchEngine>((ref) => MatchEngine(ref));

class MatchEngine {
  final Ref ref;
  MatchEngine(this.ref);

  final _fs = FirebaseFirestore.instance;

  Future<void> startMatch(String matchId,
      {Map<String, dynamic>? captureCrops, int fps = 2}) async {
    final matchRef = _fs.collection(FirestoreSchema.matches).doc(matchId);
    await _fs.runTransaction((txn) async {
      final snap = await txn.get(matchRef);
      if (!snap.exists) throw Exception('Match not found');
      final data = snap.data() as Map<String, dynamic>;
      final status = data[MatchDocument.status] as String?;
      if (status != FirestoreConstants.matchStatusActive) {
        txn.update(matchRef, {
          MatchDocument.status: FirestoreConstants.matchStatusActive,
          MatchDocument.startTime: FieldValue.serverTimestamp(),
          MatchDocument.updatedAt: FieldValue.serverTimestamp(),
        });
      }
    });

    // Start passive capture (web/mobile) if crops provided; safe on all platforms
    if (captureCrops != null && captureCrops.isNotEmpty) {
      await CaptureBridge().startCapture(
        gameId: matchId,
        cropRects: captureCrops,
        fps: fps,
        onFrame: (Uint8List bytes, int ts) async {
          // Optional: run lightweight OCR to extract score hints
          final ocr = OCRService();
          final candidates = await ocr.extractCandidatesFromPng(bytes);
          // For now we do not auto-update scores; the ResultTracker handles finalization.
          if (kDebugMode && candidates.isNotEmpty) {
            // ignore: avoid_print
            print('OCR candidates: $candidates');
          }
        },
      );
    }
  }

  Future<void> endMatch({
    required String matchId,
    required String reporterUserId,
    required int reporterScore,
    required int opponentScore,
    bool isDemo = false,
  }) async {
    await ref.read(resultTrackerProvider).submitResult(
          matchId: matchId,
          reporterUserId: reporterUserId,
          reporterScore: reporterScore,
          opponentScore: opponentScore,
          isDemo: isDemo,
        );
    await CaptureBridge().stopCapture();
  }

  Future<void> cancelMatch(String matchId) async {
    await _fs.collection(FirestoreSchema.matches).doc(matchId).update({
      MatchDocument.status: FirestoreConstants.matchStatusCancelled,
      MatchDocument.updatedAt: FieldValue.serverTimestamp(),
    });
    await CaptureBridge().stopCapture();
  }
}
