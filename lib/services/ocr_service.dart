import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:tesseract_ocr/tesseract_ocr.dart';

class OcrService {
  Future<String> extractTextFromImage(dynamic image, String ocrEngine) async {
    try {
      if (kIsWeb) {
        // Tesseract on web is not supported by the tesseract_ocr package.
        // A real implementation would require a different approach for web.
        return '';
      }

      if (ocrEngine == 'mlkit') {
        final textRecognizer = TextRecognizer();
        final inputImage = _getInputImage(image);
        if (inputImage == null) return '';
        final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
        return recognizedText.text;
      } else if (ocrEngine == 'tesseract') {
        if (image is String) {
          return await TesseractOcr.extractText(image);
        }
      }
    } catch (e) {
      // TODO: Log error
    }
    return '';
  }

  InputImage? _getInputImage(dynamic image) {
    if (image is String) {
      return InputImage.fromFilePath(image);
    } else if (image is File) {
      return InputImage.fromFile(image);
    } else if (image is Uint8List) {
      // TODO: Get image metadata for Uint8List
      return null;
    }
    return null;
  }

  Future<String> performOcr(String imagePath, String ocrEngine) async {
    return await extractTextFromImage(imagePath, ocrEngine);
  }
}
