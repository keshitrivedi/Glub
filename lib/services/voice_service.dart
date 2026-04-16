// services/voice_service.dart
// Owns: _speech instance, _initSpeech(), _listen(), locale handling, _isListening state.
// All variable names preserved exactly from main.dart.

import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceService extends ChangeNotifier {
  // ── Existing variables, unchanged names ────────────────────────────────────
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _rawText = '';
  List<stt.LocaleName> _indianLocales = [];
  String? _selectedLocaleId;

  // ── Public getters (read-only access for UI / providers) ───────────────────
  bool get isListening => _isListening;
  String get rawText => _rawText;
  List<stt.LocaleName> get indianLocales => _indianLocales;
  String? get selectedLocaleId => _selectedLocaleId;

  VoiceService() {
    _speech = stt.SpeechToText();
    _initSpeech();
  }

  // ── Existing function, unchanged name & logic ──────────────────────────────
  void _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (val) {
        if (val == 'done') {
          _isListening = false;
          notifyListeners();
        }
      },
      onError: (val) => debugPrint('onError: $val'),
    );

    if (available) {
      var locales = await _speech.locales();
      var indLocales = locales
          .where((loc) => loc.localeId.toLowerCase().contains('in'))
          .toList();

      _indianLocales = indLocales;
      if (_indianLocales.isNotEmpty) {
        final hindi =
            _indianLocales.where((l) => l.localeId.startsWith('hi')).toList();
        _selectedLocaleId = hindi.isNotEmpty
            ? hindi.first.localeId
            : _indianLocales.first.localeId;
      }
      notifyListeners();
    }
  }

  // ── Existing function, unchanged name & logic ──────────────────────────────
  // [onResult] callback delivers the raw recognised string to the caller
  // (screen or provider) — keeps UI/state logic out of this service.
  void _listen({required void Function(String rawText) onResult}) async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        _isListening = true;
        notifyListeners();

        _speech.listen(
          localeId: _selectedLocaleId,
          onResult: (val) {
            _rawText = val.recognizedWords;
            notifyListeners();
            onResult(_rawText);
          },
        );
      }
    } else {
      _isListening = false;
      notifyListeners();
      _speech.stop();
    }
  }

  // ── Public entry-point (thin wrapper so callers don't use underscore) ───────
  void listen({required void Function(String rawText) onResult}) {
    _listen(onResult: onResult);
  }

  // ── Locale selection (called from locale dropdown in UI) ───────────────────
  void setLocale(String localeId) {
    _selectedLocaleId = localeId;
    notifyListeners();
  }
}