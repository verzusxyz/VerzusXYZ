import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_screen_recording/flutter_screen_recording.dart';
import 'package:flutter_repro/flutter_repro.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

class ScreenRecordService {
  bool _isRecording = false;
  final ScreenshotController _screenshotController = ScreenshotController();
  Timer? _ocrTimer;

  // Dependencies
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextRecognizer _textRecognizer = TextRecognizer();

  // Singleton pattern for easy access
  ScreenRecordService._privateConstructor();
  static final ScreenRecordService _instance = ScreenRecordService._privateConstructor();
  factory ScreenRecordService() {
    return _instance;
  }

  Future<bool> _requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      // flutter_screen_recording handles permissions on Android
      return true;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      // ReplayKit permissions are handled by the system when the recording starts
      return true;
    }
    return false;
  }

  Future<void> startRecording(String gameName) async {
    if (_isRecording) {
      debugPrint('Screen recording is already in progress.');
      return;
    }

    final hasPermission = await _requestPermissions();
    if (!hasPermission) {
      debugPrint('Screen recording permission denied.');
      return;
    }

    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        await FlutterScreenRecording.startRecordScreen(gameName);
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        await FlutterRepro.startRecording();
      }

      _isRecording = true;
      _startOcrTimer();
      debugPrint('Screen recording started for $gameName.');
    } catch (e) {
      debugPrint('Failed to start screen recording: $e');
    }
  }

  Future<void> stopRecording(String gameId) async {
    if (!_isRecording) {
      debugPrint('No screen recording is in progress.');
      return;
    }

    _ocrTimer?.cancel();

    try {
      String? videoPath;
      if (defaultTargetPlatform == TargetPlatform.android) {
        videoPath = await FlutterScreenRecording.stopRecordScreen;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final result = await FlutterRepro.stopRecording();
        videoPath = result['videoPath'];
      }

      _isRecording = false;
      debugPrint('Screen recording stopped. Video saved at: $videoPath');

      if (videoPath != null && videoPath.isNotEmpty) {
        await _processAndUploadResults(gameId, videoPath);
      }
    } catch (e) {
      debugPrint('Failed to stop screen recording: $e');
    }
  }

  void _startOcrTimer() {
    // Run OCR scan every 10 seconds
    _ocrTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _captureAndScanFrame();
    });
  }

  Future<void> _captureAndScanFrame() async {
    debugPrint('Capturing and scanning a screen frame for OCR...');

    try {
      final imageFile = await _screenshotController.capture();
      if (imageFile != null) {
        final InputImage inputImage = InputImage.fromBytes(bytes: imageFile, metadata: InputImageMetadata(size: const Size(1,1), rotation: InputImageRotation.rotation0deg, format: InputImageFormat.nv21, bytesPerRow: 1));
        final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

        String text = recognizedText.text;
        debugPrint("Detected text: $text");
        _parseScore(text);
      }
    } catch (e) {
      debugPrint('Error during OCR scan: $e');
    }
  }

  Future<void> _processAndUploadResults(String gameId, String videoPath) async {
    debugPrint('Processing and uploading results for game: $gameId');

    final file = File(videoPath);
    if (!await file.exists()) {
      debugPrint('Video file does not exist at path: $videoPath');
      return;
    }

    try {
      // 1. Upload video to Firebase Storage
      final videoRef = _storage.ref().child('game_recordings/$gameId/${DateTime.now().millisecondsSinceEpoch}.mp4');
      final uploadTask = videoRef.putFile(file);
      final snapshot = await uploadTask.whenComplete(() => {});
      final videoUrl = await snapshot.ref.getDownloadURL();
      debugPrint('Video uploaded to: $videoUrl');

      // 2. Take a final screenshot, perform OCR, and upload it
      final imageFile = await _screenshotController.capture();
      if (imageFile != null) {
        final screenshotRef = _storage.ref().child('game_screenshots/$gameId/${DateTime.now().millisecondsSinceEpoch}.png');
        final screenshotUploadTask = screenshotRef.putData(imageFile);
        final screenshotSnapshot = await screenshotUploadTask.whenComplete(() => {});
        final screenshotUrl = await screenshotSnapshot.ref.getDownloadURL();
        debugPrint('Screenshot uploaded to: $screenshotUrl');

        // Perform OCR on the final screenshot
        final InputImage inputImage = InputImage.fromBytes(bytes: imageFile, metadata: InputImageMetadata(size: const Size(1,1), rotation: InputImageRotation.rotation0deg, format: InputImageFormat.nv21, bytesPerRow: 1));
        final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
        final String detectedText = recognizedText.text;
        final String winner = _parseScore(detectedText);

        // 3. Update Firestore with the results
        final matchResult = {
          'gameId': gameId,
          'winner': winner,
          'detectedText': detectedText,
          'timestamp': FieldValue.serverTimestamp(),
          'videoUrl': videoUrl,
          'screenshotUrl': screenshotUrl,
        };

        await _firestore.collection('match_results').add(matchResult);
        debugPrint('Match result saved to Firestore.');
      }
    } catch (e) {
      debugPrint('Error processing and uploading results: $e');
    }
  }

  String _parseScore(String text) {
    // This is a placeholder for score parsing logic.
    // A real implementation would use regex or other methods to extract scores.
    if (text.toLowerCase().contains('player1 wins')) {
      return 'Player1';
    } else if (text.toLowerCase().contains('player2 wins')) {
      return 'Player2';
    }
    return 'Unknown';
  }
}
