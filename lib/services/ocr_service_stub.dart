class OcrResult {
  final String? text;
  final String? error;
  final bool success;

  const OcrResult({this.text, this.error, required this.success});

  factory OcrResult.success(String text) =>
      OcrResult(text: text, success: true);

  factory OcrResult.failure(String error) =>
      OcrResult(error: error, success: false);
}
