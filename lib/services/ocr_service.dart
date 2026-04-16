// Web cannot compile `dart:io`, and ML Kit OCR is not supported on web.
// We use conditional imports so `flutter run -d chrome` still builds.

export 'ocr_service_stub.dart'
    if (dart.library.io) 'ocr_service_io.dart'
    if (dart.library.html) 'ocr_service_web.dart';
