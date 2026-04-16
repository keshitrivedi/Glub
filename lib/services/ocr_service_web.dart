import 'ocr_service_stub.dart';

/// Web build: ML Kit + native camera/gallery OCR is not supported.
/// This stub keeps `flutter run -d chrome` working and lets the UI show an error.
class OcrService {
  Future<OcrResult> scanPrescription({required bool fromCamera}) async {
    return OcrResult.failure(
      'Prescription scanning is not supported on Web. '
      'Run on Android/iOS/Windows/macOS for camera OCR.',
    );
  }

  void dispose() {}
}

