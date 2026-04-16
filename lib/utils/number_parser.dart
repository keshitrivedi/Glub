// utils/number_parser.dart
// Owns: _wordToNumberMap, _parseNumber logic
// Moved verbatim from main.dart — zero logic changes.

class NumberParser {
  // ── Existing variable, unchanged name ──────────────────────────────────────
  static const Map<String, String> _wordToNumberMap = {
    // English
    'zero': '0', 'one': '1', 'two': '2', 'three': '3', 'four': '4',
    'five': '5', 'six': '6', 'seven': '7', 'eight': '8', 'nine': '9', 'ten': '10',
    // Hindi (romanised)
    'shunya': '0', 'ek': '1', 'do': '2', 'teen': '3', 'chaar': '4', 'char': '4',
    'paanch': '5', 'panch': '5', 'chhah': '6', 'che': '6', 'saat': '7', 'aath': '8',
    'nau': '9', 'das': '10',
    // Kannada (romanised)
    'shunyo': '0', 'ondu': '1', 'eradu': '2', 'mooru': '3',
    // Hindi / Marathi — Devanagari script
    'शून्य': '0', 'एक': '1', 'दो': '2', 'तीन': '3', 'चार': '4',
    'पांच': '5', 'छह': '6', 'सात': '7', 'आठ': '8', 'नौ': '9', 'दस': '10',
  };

  // ── Existing function, unchanged name ──────────────────────────────────────
  // Returns a numeric string, or 'No number detected'.
  // Called internally; use the public [parse] wrapper in app code.
  static String _parseNumber(String input) {
    String lowerInput = input.toLowerCase().trim();

    // 1. Try to find Arabic numerals directly in the text.
    //    The speech engine often auto-translates "ek" / "one" into "1".
    RegExp digitRegExp = RegExp(r'\d+');
    var matches = digitRegExp.allMatches(lowerInput);
    if (matches.isNotEmpty) {
      return matches.map((m) => m.group(0)).join();
    }

    // 2. Fallback: dictionary mapping for known single-word numbers.
    for (var word in lowerInput.split(' ')) {
      if (_wordToNumberMap.containsKey(word)) {
        return _wordToNumberMap[word]!;
      }
    }

    return 'No number detected';
  }

  // ── Public wrapper (new) ───────────────────────────────────────────────────
  // Returns a validated int, or null on failure / out-of-range.
  // Blood sugar valid range: 20–600 mg/dL.
  static int? parse(String input) {
    final raw = _parseNumber(input);
    if (raw == 'No number detected') return null;

    final n = int.tryParse(raw);
    if (n == null) return null;
    if (n < 20 || n > 600) return null; // range guard

    return n;
  }

  // Exposed for UI that still needs the raw string (e.g. debug display).
  static String parseRaw(String input) => _parseNumber(input);
}