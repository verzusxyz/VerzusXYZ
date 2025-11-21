// lib/services/ocr_service.dart
// Web-safe OCR service placeholder. On mobile, you can extend this to use ML Kit.

import 'dart:typed_data';
import 'package:image/image.dart' as img;

class OCRService {
  OCRService();

  // Extract text candidates from the PNG bytes.
  // This web-safe placeholder does not run OCR; it returns empty results.
  Future<List<String>> extractCandidatesFromPng(Uint8List pngBytes,
      {Map<String, num>? cropRect}) async {
    // Optionally crop to rect using the image package to reduce payload for native OCR.
    if (cropRect != null) {
      try {
        final decoded = img.decodeImage(pngBytes);
        if (decoded != null) {
          final x = (cropRect['x'] ?? 0).toInt();
          final y = (cropRect['y'] ?? 0).toInt();
          final w = (cropRect['w'] ?? decoded.width).toInt();
          final h = (cropRect['h'] ?? decoded.height).toInt();
          img.copyCrop(decoded, x: x, y: y, width: w, height: h);
          // You could pass `img.encodePng(cropped)` to a native OCR on mobile.
          // For now we ignore and return empty list.
        }
      } catch (_) {
        // ignore failures
      }
    }
    return <String>[];
  }

  // Suggest crop rectangles (very naive). Returns a map matching {scoreRect, usernameRect, confidence}.
  Future<Map<String, dynamic>> suggestCropRects(Uint8List pngBytes) async {
    // Without OCR, return central bands as a heuristic placeholder.
    try {
      final decoded = img.decodeImage(pngBytes);
      if (decoded != null) {
        final w = decoded.width;
        final h = decoded.height;
        return {
          'scoreRect': {
            'x': (w * 0.55).toInt(),
            'y': (h * 0.05).toInt(),
            'w': (w * 0.4).toInt(),
            'h': (h * 0.12).toInt()
          },
          'usernameRect': {
            'x': (w * 0.05).toInt(),
            'y': (h * 0.80).toInt(),
            'w': (w * 0.5).toInt(),
            'h': (h * 0.12).toInt()
          },
          'confidence': 0.2,
        };
      }
    } catch (_) {}
    // Fallback constants
    return {
      'scoreRect': {'x': 100, 'y': 200, 'w': 300, 'h': 80},
      'usernameRect': {'x': 50, 'y': 100, 'w': 250, 'h': 60},
      'confidence': 0.1,
    };
  }
}
