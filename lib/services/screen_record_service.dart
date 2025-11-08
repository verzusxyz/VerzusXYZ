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


class ScreenRecordService extends StateNotifier<bool> {
  ScreenRecordService() : super(false);

  Future<void> startRecording(String gameId) async {
    if (state) {
      return;
    }
    try {
      state = await FlutterScreenRecording.startRecordScreen(gameId);
      if (state) {
        _showRecordingNotification();
      }
    } catch (e) {
      // TODO: Inform user that permission is required
    }
  }

  Future<void> stopRecordingAndProcess(GameModel game, String matchId) async {
    if (!state) {
      return;
    }
    final String? videoPath = await FlutterScreenRecording.stopRecordScreen;
    state = false;
    AwesomeNotifications().dismiss(1);

    if (videoPath != null) {
      await _processAndUploadResults(videoPath, game, matchId);
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

  Future<void> _processAndUploadResults(String videoPath, GameModel game, String matchId) async {
    try {
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        imageFormat: ImageFormat.PNG,
      );

      if (thumbnailPath == null) {
        await _flagForManualReview(matchId, 'Thumbnail generation failed.');
        return;
      }

      final ocrText = await _performOcr(thumbnailPath, game.ocrEngine);

      if (ocrText == null || ocrText.isEmpty) {
        await _flagForManualReview(matchId, 'OCR failed to extract text.', videoPath: videoPath, thumbnailPath: thumbnailPath);
        return;
      }

      final parser = ScoreParserFactory.getParser(game);
      final result = parser.parse(ocrText);

      await _uploadResult(matchId, result, videoPath, thumbnailPath);
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
