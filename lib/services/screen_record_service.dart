import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screen_recording/flutter_screen_recording.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:verzus/models/game_model.dart';
import 'package:verzus/models/game_result_model.dart';
import 'package:verzus/models/match_model.dart';
import 'package:verzus/repositories/firebase_repository.dart';
import 'package:verzus/repositories/game_result_repository.dart';
import 'package:verzus/repositories/manual_review_repository.dart';
import 'package:verzus/services/capture_service.dart';
import 'package:verzus/services/firestore_storage_service.dart';
import 'package:verzus/services/notification_service.dart';
import 'package:verzus/services/ocr_service.dart';
import 'package:verzus/services/score_parser_factory.dart';
import 'package:verzus/services/score_parsers/score_parser_interface.dart';

const List<String> endGameKeywords = [
  "Game Over", "Match Over", "You Win", "You Lose", "Victory",
  "Defeat", "Draw", "Results", "Final Score", "End of Match",
  "KO", "Finished", "Round Complete", "Complete", "Mission Complete",
  "Level Cleared", "Time Up", "Results Screen", "Winner", "Loser"
];

const List<String> variantKeywords = [
  "Win!", "Lose!", "Top Score", "Champion", "MVP",
  "Ranked Result", "XP Earned", "Scoreboard", "Replay", "Next Match"
];

const List<String> negativeKeywords = [
  "Pause", "Resume", "Retry", "Next Level", "Continue",
  "Options", "Settings", "Loading", "Connecting", "Waiting for Players"
];

enum RecordingState { idle, recording, verifying, processing }

class ScreenRecordService extends StateNotifier<RecordingState> {
  final MatchRepository _matchRepository;
  final GameResultRepository _gameResultRepository;
  final ManualReviewRepository _manualReviewRepository;
  final OcrService _ocrService;
  final FirestoreStorageService _storageService;
  final NotificationService _notificationService;
  final CaptureService _captureService;

  ScreenRecordService(
    this._matchRepository,
    this._gameResultRepository,
    this._manualReviewRepository,
    this._ocrService,
    this._storageService,
    this._notificationService,
    this._captureService,
  ) : super(RecordingState.idle);

  Timer? _frameAnalysisTimer;

  Future<void> startRecording(GameModel game, String matchId) async {
    if (state != RecordingState.idle) {
      return;
    }
    try {
      final success = await _captureService.startRecording(game.gameId);
      if (success) {
        state = RecordingState.recording;
        _frameAnalysisTimer = Timer.periodic(const Duration(seconds: 5), (_) => _analyzeFrame(game, matchId));
        _notificationService.showRecordingNotification();
      }
    } catch (e) {
      // TODO: Inform user that permission is required
    }
  }

  Future<void> stopRecordingAndProcess(GameModel game, String matchId) async {
    if (state == RecordingState.idle || state == RecordingState.processing) {
      return;
    }
    _frameAnalysisTimer?.cancel();
    final String? videoPath = await _captureService.stopRecording();
    state = RecordingState.processing;
    _notificationService.dismissRecording(1);

    if (videoPath != null) {
      final thumbnailPath = await _captureService.generateVideoThumbnail(videoPath);
      if (thumbnailPath != null) {
        await _processAndUploadResults(videoPath, game, matchId, thumbnailPath);
      } else {
        final match = await _matchRepository.listenToMatch(matchId).first;
        if (match != null) {
          await _flagForManualReview(match, 'Thumbnail generation failed.');
        }
      }
    }
    state = RecordingState.idle;
  }

  Future<void> _analyzeFrame(GameModel game, String matchId) async {
    if (state != RecordingState.recording) {
      return;
    }

    try {
      final imagePath = await _captureService.captureFrame();
      if (imagePath == null) {
        return;
      }

      final ocrText = await _ocrService.performOcr(imagePath, game.ocrEngine);
      if (ocrText.isEmpty) {
        return;
      }

      final lowerCaseOcrText = ocrText.toLowerCase();
      final hasEndGameKeyword = endGameKeywords.any((keyword) => lowerCaseOcrText.contains(keyword.toLowerCase()));
      final hasVariantKeyword = variantKeywords.any((keyword) => lowerCaseOcrText.contains(keyword.toLowerCase()));
      final hasNegativeKeyword = negativeKeywords.any((keyword) => lowerCaseOcrText.contains(keyword.toLowerCase()));

      if ((hasEndGameKeyword || hasVariantKeyword) && !hasNegativeKeyword) {
        state = RecordingState.verifying;
        await Future.delayed(const Duration(seconds: 1));
        if (state == RecordingState.verifying) {
          stopRecordingAndProcess(game, matchId);
        }
      }
    } catch (e) {
      // TODO: Log error
    }
  }

  Future<void> _processAndUploadResults(String videoPath, GameModel game, String matchId, String screenshotPath) async {
    try {
      final match = await _matchRepository.listenToMatch(matchId).first;
      if (match == null) {
        throw Exception('Match not found');
      }

      final ocrText = await _ocrService.performOcr(screenshotPath, game.ocrEngine);
      if (ocrText.isEmpty) {
        await _flagForManualReview(match, 'OCR failed to extract text.', videoPath: videoPath, thumbnailPath: screenshotPath);
        return;
      }

      final parser = ScoreParserFactory.getParser(game);
      final parsedResult = parser.parse(ocrText);

      String? winnerId;
      if (parsedResult.player1Score != null && parsedResult.player2Score != null) {
        if (parsedResult.player1Score! > parsedResult.player2Score!) {
          winnerId = match.creatorId;
        } else if (parsedResult.player2Score! > parsedResult.player1Score!) {
          winnerId = match.opponentId;
        }
      }

      final gameResult = GameResultModel(
        id: '', // Will be generated by Firestore
        matchId: matchId,
        player1Id: match.creatorId,
        player2Id: match.opponentId,
        player1Score: parsedResult.player1Score,
        player2Score: parsedResult.player2Score,
        winnerId: winnerId,
        createdAt: DateTime.now(),
      );

      await _uploadResult(gameResult, videoPath, screenshotPath);
    } catch (e) {
      // TODO: Log error
    }
  }

  Future<void> _uploadResult(GameResultModel result, String videoPath, String thumbnailPath) async {
    final videoFile = File(videoPath);
    final thumbnailFile = File(thumbnailPath);

    await _storageService.uploadFile('match_recordings/${result.matchId}.mp4', videoFile);
    await _storageService.uploadFile('match_thumbnails/${result.matchId}.png', thumbnailFile);

    await _gameResultRepository.createGameResult(result);

    _notificationService.showMatchFinished(result.matchId);
  }

  Future<void> _flagForManualReview(MatchModel match, String reason, {String? videoPath, String? thumbnailPath}) async {
    String? videoUrl;
    String? thumbnailUrl;

    if (videoPath != null) {
      videoUrl = await _storageService.uploadFile('manual_reviews/${match.id}/video.mp4', File(videoPath));
    }

    if (thumbnailPath != null) {
      thumbnailUrl = await _storageService.uploadFile('manual_reviews/${match.id}/thumbnail.png', File(thumbnailPath));
    }

    final review = ManualReviewModel(
      id: '', // Will be generated by Firestore
      matchId: match.id,
      reason: reason,
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
      createdAt: DateTime.now(),
    );

    await _manualReviewRepository.createManualReview(review);
  }
}
