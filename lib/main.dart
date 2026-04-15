import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Speech to Number',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const SpeechScreen(),
    );
  }
}

class SpeechScreen extends StatefulWidget {
  const SpeechScreen({super.key});

  @override
  State<SpeechScreen> createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _rawText = 'Press the microphone button and start speaking a number...';
  String _extractedNumber = '';

  List<stt.LocaleName> _indianLocales = [];
  String? _selectedLocaleId;

  // A small dictionary to fallback on if the speech engine returns words instead of digits.
  // Many speech recognition engines automatically convert spoken numbers into numeric digits.
  final Map<String, String> _wordToNumberMap = {
    // English
    'zero': '0', 'one': '1', 'two': '2', 'three': '3', 'four': '4',
    'five': '5', 'six': '6', 'seven': '7', 'eight': '8', 'nine': '9', 'ten': '10',
    // Hindi (often transcribed in english script depending on the engine, or raw hindi)
    'shunya': '0', 'ek': '1', 'do': '2', 'teen': '3', 'chaar': '4', 'char': '4',
    'paanch': '5', 'panch': '5', 'chhah': '6', 'che': '6', 'saat': '7', 'aath': '8',
    'nau': '9', 'das': '10',
    'shunyo': '0', 'ondu': '1', 'eradu': '2', 'mooru': '3',
    // Hindi / Marathi Devnagari Script
    'शून्य': '0', 'एक': '1', 'दो': '2', 'तीन': '3', 'चार': '4', 
    'पांच': '5', 'छह': '6', 'सात': '7', 'आठ': '8', 'नौ': '9', 'दस': '10',
  };

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
  }

  void _initSpeech() async {
    bool available = await _speech.initialize(
      onStatus: (val) {
        if (val == 'done') {
          setState(() => _isListening = false);
        }
      },
      onError: (val) => print('onError: $val'),
    );

    if (available) {
      // Fetch all locales supported by the device
      var locales = await _speech.locales();
      // Filter for Indian region locales (e.g. en-IN, hi-IN, ta-IN, te-IN, mr-IN, etc.)
      var indLocales = locales.where((loc) => loc.localeId.toLowerCase().contains('in')).toList();
      
      setState(() {
        _indianLocales = indLocales;
        if (_indianLocales.isNotEmpty) {
          // Default to Hindi if available, otherwise first Indian language
          final hindi = _indianLocales.where((l) => l.localeId.startsWith('hi')).toList();
          _selectedLocaleId = hindi.isNotEmpty ? hindi.first.localeId : _indianLocales.first.localeId;
        }
      });
    }
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          localeId: _selectedLocaleId,
          onResult: (val) {
            setState(() {
              _rawText = val.recognizedWords;
              _extractedNumber = _parseNumber(_rawText);
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  String _parseNumber(String input) {
    String lowerInput = input.toLowerCase().trim();

    // 1. Try to find Arabic numerals (digits) directly in the text
    // The speech engine often automatically translates "ek" or "one" into "1".
    RegExp digitRegExp = RegExp(r'\d+');
    var matches = digitRegExp.allMatches(lowerInput);
    if (matches.isNotEmpty) {
      return matches.map((m) => m.group(0)).join(); 
    }

    // 2. Fallback to dictionary mapping for known single-word numbers if no digits found
    for (var word in lowerInput.split(' ')) {
      if (_wordToNumberMap.containsKey(word)) {
        return _wordToNumberMap[word]!;
      }
    }

    return 'No number detected';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice to Number'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_indianLocales.isNotEmpty)
            DropdownButton<String>(
              value: _selectedLocaleId,
              icon: const Icon(Icons.language),
              dropdownColor: Theme.of(context).colorScheme.primaryContainer,
              underline: const SizedBox(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedLocaleId = newValue;
                });
              },
              items: _indianLocales.map<DropdownMenuItem<String>>((stt.LocaleName locale) {
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
        label: Text(_isListening ? 'Listening...' : 'Tap to Speak'),
        icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text('What the engine heard:', style: TextStyle(color: Colors.grey)),
              Text(
                _rawText,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18.0, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 40),
              const Text('Extracted Number:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              Text(
                _extractedNumber.isEmpty ? '--' : _extractedNumber,
                style: TextStyle(
                  fontSize: 64.0, 
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
