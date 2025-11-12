import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screen_recording/flutter_screen_recording.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:tesseract_ocr/tesseract_ocr.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:verzus/models/game_model.dart';
import 'package:verzus/services/score_parser_factory.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:verzus/services/score_parsers/score_parser_interface.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'dart:async';
import 'package:native_screenshot/native_screenshot.dart';
import 'package:path_provider/path_provider.dart';


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
  ScreenRecordService() : super(RecordingState.idle);

  Timer? _frameAnalysisTimer;

  Future<void> startRecording(GameModel game, String matchId) async {
    if (state != RecordingState.idle) {
      return;
    }
    try {
      final success = await FlutterScreenRecording.startRecordScreen(game.gameId);
      if (success) {
        state = RecordingState.recording;
        _frameAnalysisTimer = Timer.periodic(const Duration(seconds: 5), (_) => _analyzeFrame(game, matchId));
        _showRecordingNotification();
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
    final String? videoPath = await FlutterScreenRecording.stopRecordScreen;
    state = RecordingState.processing;
    AwesomeNotifications().dismiss(1);

    if (videoPath != null) {
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        imageFormat: ImageFormat.PNG,
      );
      if (thumbnailPath != null) {
        await _processAndUploadResults(videoPath, game, matchId, thumbnailPath);
      } else {
        await _flagForManualReview(matchId, 'Thumbnail generation failed.');
      }
    }
    state = RecordingState.idle;
  }

  Future<void> _analyzeFrame(GameModel game, String matchId) async {
    if (state != RecordingState.recording) {
      return;
    }

    try {
      final imagePath = await _captureFrame();
      if (imagePath == null) {
        return;
      }

      final ocrText = await _performOcr(imagePath, game.ocrEngine);
      if (ocrText == null || ocrText.isEmpty) {
        return;
      }

      final lowerCaseOcrText = ocrText.toLowerCase();
      final hasEndGameKeyword = endGameKeywords.any((keyword) => lowerCaseOcrText.contains(keyword.toLowerCase()));
      final hasVariantKeyword = variantKeywords.any((keyword) => lowerCaseOcrText.contains(keyword.toLowerCase()));
      final hasNegativeKeyword = negativeKeywords.any((keyword) => lowerCaseOcrText.contains(keyword.toLowerCase()));

      if ((hasEndGameKeyword || hasVariantKeyword) && !hasNegativeKeyword) {
        state = RecordingState.verifying;
        // In a real implementation, we would check the next frame for stability.
        // For now, we will just wait a second and then stop the recording.
        await Future.delayed(const Duration(seconds: 1));
        if (state == RecordingState.verifying) {
          stopRecordingAndProcess(game, matchId);
        }
      }
    } catch (e) {
      // TODO: Log error
    }
  }

  Future<String?> _captureFrame() async {
    try {
      final imagePath = await NativeScreenshot.takeScreenshot();
      return imagePath;
    } catch (e) {
      // TODO: Log error
      return null;
    }
  }

  void _showRecordingNotification() {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'basic_channel',
        title: 'Recording in Progress',
        body: 'Your match is being recorded.',
        locked: true,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'STOP_RECORDING',
          label: 'Stop Recording',
        ),
      ],
    );
  }

  Future<void> _processAndUploadResults(String videoPath, GameModel game, String matchId, String screenshotPath) async {
    try {
      final ocrText = await _performOcr(screenshotPath, game.ocrEngine);

      if (ocrText == null || ocrText.isEmpty) {
        await _flagForManualReview(matchId, 'OCR failed to extract text.', videoPath: videoPath, thumbnailPath: screenshotPath);
        return;
      }

      final parser = ScoreParserFactory.getParser(game);
      final result = parser.parse(ocrText);

      await _uploadResult(matchId, result, videoPath, screenshotPath);
    } catch (e) {
      await _flagForManualReview(matchId, 'An unexpected error occurred during processing: $e');
    }
  }

  Future<void> _uploadResult(String matchId, MatchResult result, String videoPath, String thumbnailPath) async {
    final storageRef = FirebaseStorage.instance.ref();
    final videoFile = File(videoPath);
    final thumbnailFile = File(thumbnailPath);

    final videoUploadTask = storageRef.child('match_recordings/$matchId.mp4').putFile(videoFile);
    final thumbnailUploadTask = storageRef.child('match_thumbnails/$matchId.png').putFile(thumbnailFile);

    await Future.wait([videoUploadTask, thumbnailUploadTask]);

    final videoUrl = await videoUploadTask.snapshot.ref.getDownloadURL();
    final thumbnailUrl = await thumbnailUploadTask.snapshot.ref.getDownloadURL();

    await FirebaseFirestore.instance.collection('match_results').doc(matchId).set({
      'result': result.toJson(),
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'status': 'processed',
      'processedAt': FieldValue.serverTimestamp(),
    });

    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 2,
        channelKey: 'basic_channel',
        title: 'Match Finished 🎯',
        body: 'Results captured — tap to review on VerzusXYZ',
        payload: {'matchId': matchId},
      ),
    );
  }

  Future<void> _flagForManualReview(String matchId, String reason, {String? videoPath, String? thumbnailPath}) async {
    String? videoUrl;
    String? thumbnailUrl;

    if (videoPath != null) {
      final storageRef = FirebaseStorage.instance.ref();
      final videoFile = File(videoPath);
      final videoUploadTask = await storageRef.child('match_recordings/$matchId.mp4').putFile(videoFile);
      videoUrl = await videoUploadTask.ref.getDownloadURL();
    }

    if (thumbnailPath != null) {
      final storageRef = FirebaseStorage.instance.ref();
      final thumbnailFile = File(thumbnailPath);
      final thumbnailUploadTask = await storageRef.child('match_thumbnails/$matchId.png').putFile(thumbnailFile);
      thumbnailUrl = await thumbnailUploadTask.ref.getDownloadURL();
    }

    await FirebaseFirestore.instance.collection('match_results').doc(matchId).set({
      'status': 'needs_manual_review',
      'reason': reason,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'processedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String?> _performOcr(String imagePath, String ocrEngine) async {
    try {
      if (ocrEngine == 'mlkit') {
        final textRecognizer = TextRecognizer();
        final RecognizedText recognizedText = await textRecognizer.processImage(InputImage.fromFilePath(imagePath));
        return recognizedText.text;
      } else if (ocrEngine == 'tesseract') {
        return await TesseractOcr.extractText(imagePath);
      }
    } catch (e) {
      // TODO: Log error
    }
    return null;
  }
}
