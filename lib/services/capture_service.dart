import 'package:native_screenshot/native_screenshot.dart';

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
}
