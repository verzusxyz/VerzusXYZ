import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:tesseract_ocr/tesseract_ocr.dart';

class OcrService {
  Future<String> extractTextFromImage(String imagePath, String ocrEngine) async {
    try {
      if (kIsWeb) {
        // Tesseract on web is not supported by the tesseract_ocr package.
        // A real implementation would require a different approach for web.
        return '';
      }

      if (ocrEngine == 'mlkit') {
        final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
        final RecognizedText recognizedText = await textRecognizer.processImage(InputImage.fromFilePath(imagePath));
        return recognizedText.text;
      } else if (ocrEngine == 'tesseract') {
        return await TesseractOcr.extractText(imagePath);
      }
    } catch (e) {
      // TODO: Log error
    }
    return '';
  }
}
