// lib/services/board_recognition.dart
// Placeholder for a board-state recognition bridge. Safe for web; returns null.

import 'dart:typed_data';

class BoardRecognitionService {
  Future<void> loadModel() async {
    // No-op: add TFLite model and bindings on mobile later.
  }

  /// Accepts PNG bytes, returns a canonical board string (e.g., FEN). Placeholder implementation.
  Future<String?> computeFEN(Uint8List pngBytes) async {
    await loadModel();
    return null;
  }
}
