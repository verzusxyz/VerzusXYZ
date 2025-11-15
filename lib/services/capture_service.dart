import 'package:native_screenshot/native_screenshot.dart';

import 'package:flutter_screen_recording/flutter_screen_recording.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class CaptureService {
  Future<String?> captureFrame() async {
    try {
      final imagePath = await NativeScreenshot.takeScreenshot();
      return imagePath;
    } catch (e) {
      // TODO: Log error
      return null;
    }
  }

  Future<bool> startRecording(String gameId) async {
    return await FlutterScreenRecording.startRecordScreen(gameId);
  }

  Future<String?> stopRecording() async {
    return await FlutterScreenRecording.stopRecordScreen;
  }

  Future<String?> generateVideoThumbnail(String videoPath) async {
    return await VideoThumbnail.thumbnailFile(
      video: videoPath,
      imageFormat: ImageFormat.PNG,
    );
  }
}
