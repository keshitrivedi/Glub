// features/voice/screens/speech_screen.dart
// Owns: all UI from main.dart's SpeechScreen widget.
// State logic delegated to VoiceService + NumberParser.
// _extractedNumber is now an int? (validated); display logic updated accordingly.

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../services/voice_service.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/number_parser.dart';

class SpeechScreen extends StatefulWidget {
  const SpeechScreen({super.key});

  @override
  State<SpeechScreen> createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  // ── Existing variable names preserved ─────────────────────────────────────
  // _speech, _isListening, _rawText, _indianLocales, _selectedLocaleId are now
  // owned by VoiceService. Kept as local references for display.
  late final VoiceService _voiceService;

  // _extractedNumber: was String in original; now int? for type safety.
  // Display logic below matches original behaviour.
  int? _extractedNumber;

  @override
  void initState() {
    super.initState();
    _voiceService = VoiceService();
    // Rebuild screen whenever service state changes (isListening, rawText, locales).
    _voiceService.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    _voiceService.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _onServiceUpdate() {
    setState(() {
      // Re-run parse every time rawText changes.
      _extractedNumber = NumberParser.parse(_voiceService.rawText);
    });
  }

  // ── _listen() call preserved — delegates to service ───────────────────────
  void _listen() {
    _voiceService.listen(
      onResult: (rawText) {
        setState(() {
          _extractedNumber = NumberParser.parse(rawText);
        });
      },
    );
  }

  // ── Display helpers ────────────────────────────────────────────────────────
  String get _displayRawText {
    final t = _voiceService.rawText;
    return t.isEmpty
        ? 'Press the microphone button and start speaking a number...'
        : t;
  }

  String get _displayNumber {
    if (_extractedNumber != null) return _extractedNumber.toString();
    // Show parse feedback only once user has spoken something.
    if (_voiceService.rawText.isNotEmpty) return 'No number detected';
    return '--';
  }

  // ── build() — identical layout to original ────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final bool isListening = _voiceService.isListening;
    final List<stt.LocaleName> indianLocales = _voiceService.indianLocales;
    final String? selectedLocaleId = _voiceService.selectedLocaleId;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Glub'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (indianLocales.isNotEmpty)
            DropdownButton<String>(
              value: selectedLocaleId,
              icon: const Icon(Icons.language, color: AppColors.textDark),
              dropdownColor: AppColors.lightGreen,
              underline: const SizedBox(),
              onChanged: (String? newValue) {
                if (newValue != null) _voiceService.setLocale(newValue);
              },
              items: indianLocales
                  .map<DropdownMenuItem<String>>((stt.LocaleName locale) {
                return DropdownMenuItem<String>(
                  value: locale.localeId,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(locale.name),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _listen,
        label: Text(isListening ? 'Listening...' : 'Tap to Speak'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.mic),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'What the engine heard:',
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  _displayRawText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'Extracted Number:',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
                ),
                Text(
                  _displayNumber,
                  style: const TextStyle(
                    fontSize: 64.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}