import '../models/medicine_model.dart';

class ParsedPrescription {
  final List<ParsedMedicine> medicines;
  final double overallConfidence;
  final String cleanedText;
  final bool parsedSuccessfully;

  const ParsedPrescription({
    required this.medicines,
    required this.overallConfidence,
    required this.cleanedText,
    required this.parsedSuccessfully,
  });
}

class ParsedMedicine {
  String name;
  String? dosage;
  String? frequency;
  String? timing;
  int? durationDays;
  double confidence;

  ParsedMedicine({
    required this.name,
    this.dosage,
    this.frequency,
    this.timing,
    this.durationDays,
    required this.confidence,
  });

  MedicineModel toMedicineModel(String userId) => MedicineModel(
        userId: userId,
        name: name,
        dosage: dosage,
        frequency: frequency,
        timing: timing,
        durationDays: durationDays,
      );
}

class PrescriptionParser {
  static const double _wName = 0.4;
  static const double _wDosage = 0.2;
  static const double _wFrequency = 0.2;
  static const double _wTiming = 0.1;
  static const double _wDuration = 0.1;

  static final RegExp _dosageRx = RegExp(
    r'(\d+(?:\.\d+)?)\s*(mg|mcg|g|ml|tablet[s]?|tab[s]?|cap[s]?|capsule[s]?)',
    caseSensitive: false,
  );

  static final RegExp _numScheduleRx = RegExp(
    r'\b([01])\s*[-–—]\s*([01])\s*[-–—]\s*([01])\b',
  );

  static final RegExp _freqAbbrRx = RegExp(
    r'\b(OD|BD|TDS|QID|SOS|PRN|HS|AC|PC)\b',
    caseSensitive: false,
  );

  static final RegExp _freqNaturalRx = RegExp(
    r'\b(once\s+daily|twice\s+daily|thrice\s+daily|three\s+times\s+a?\s*day|four\s+times\s+a?\s*day|every\s+\d+\s+hours?)\b',
    caseSensitive: false,
  );

  static final RegExp _timingRx = RegExp(
    r'\b(after\s+food|before\s+food|with\s+food|empty\s+stomach|with\s+water|at\s+bedtime|before\s+sleep|morning|night|evening)\b',
    caseSensitive: false,
  );

  static final RegExp _durationRx = RegExp(
    r'\b(?:for\s+)?(\d+)\s*(days?|weeks?|months?)\b',
    caseSensitive: false,
  );

  static final RegExp _nameCandidateRx = RegExp(
    r'^([A-Z][a-zA-Z0-9\s\-\/\.]+)',
  );

  static const Set<String> _stopWords = {
    'date',
    'patient',
    'name',
    'age',
    'sex',
    'male',
    'female',
    'doctor',
    'dr',
    'clinic',
    'hospital',
    'address',
    'phone',
    'rx',
    'rp',
    'signature',
    'sig',
    'tab',
    'caps',
    'inj',
    'diagnosis',
    'advice',
    'follow',
    'up',
    'next',
    'visit',
    'blood',
    'pressure',
    'sugar',
    'test',
    'report',
  };

  ParsedPrescription parse(String rawText) {
    final cleaned = _cleanText(rawText);
    final lines = _splitIntoLines(cleaned);
    final medicines = _parseLines(lines);

    final overall = medicines.isEmpty
        ? 0.0
        : medicines.map((m) => m.confidence).reduce((a, b) => a + b) /
            medicines.length;

    return ParsedPrescription(
      medicines: medicines,
      overallConfidence: overall,
      cleanedText: cleaned,
      parsedSuccessfully: medicines.isNotEmpty,
    );
  }

  String _cleanText(String raw) {
    return raw
        .replaceAll('—', '-')
        .replaceAll('–', '-')
        .replaceAll('\u2010', '-')
        .replaceAll(RegExp(r'mg\.'), 'mg')
        .replaceAll(RegExp(r'\bmgs\b', caseSensitive: false), 'mg')
        .replaceAll(RegExp(r'[ \t]{2,}'), ' ')
        .replaceAll(RegExp(r'(?<!\d)\.(?!\d)'), ' ')
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .trim();
  }

  List<String> _splitIntoLines(String text) {
    return text
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.length > 2)
        .toList();
  }

  List<ParsedMedicine> _parseLines(List<String> lines) {
    final result = <ParsedMedicine>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final context = i + 1 < lines.length ? '$line\n${lines[i + 1]}' : line;

      final name = _extractName(line);
      if (name == null) continue;

      final dosage = _extractDosage(context);
      final frequency = _extractFrequency(context);
      final timing = _extractTiming(context);
      final duration = _extractDuration(context);

      result.add(
        ParsedMedicine(
          name: name,
          dosage: dosage,
          frequency: frequency,
          timing: timing,
          durationDays: duration,
          confidence: _calcConfidence(
            hasDosage: dosage != null,
            hasFrequency: frequency != null,
            hasTiming: timing != null,
            hasDuration: duration != null,
          ),
        ),
      );
    }

    return result;
  }

  String? _extractName(String line) {
    final match = _nameCandidateRx.firstMatch(line);
    if (match == null) return null;

    var candidate = match.group(1)!.trim();
    candidate = candidate.replaceAll(_dosageRx, '').trim();

    if (_stopWords.contains(candidate.toLowerCase())) return null;
    if (candidate.length < 3) return null;

    return _toTitleCase(candidate);
  }

  String? _extractDosage(String text) {
    final match = _dosageRx.firstMatch(text);
    if (match == null) return null;

    final value = match.group(1)!;
    final unit = match.group(2)!.toLowerCase();
    final expanded = {
          'tab': 'tablet',
          'tabs': 'tablet',
          'cap': 'capsule',
          'caps': 'capsule',
        }[unit] ??
        unit;

    return '$value $expanded';
  }

  String? _extractFrequency(String text) {
    final numMatch = _numScheduleRx.firstMatch(text);
    if (numMatch != null) {
      return _decodeNumericSchedule(
        numMatch.group(1)!,
        numMatch.group(2)!,
        numMatch.group(3)!,
      );
    }

    final abbrMatch = _freqAbbrRx.firstMatch(text);
    if (abbrMatch != null) {
      return _decodeFreqAbbr(abbrMatch.group(1)!.toUpperCase());
    }

    final natMatch = _freqNaturalRx.firstMatch(text);
    if (natMatch != null) {
      return _toTitleCase(natMatch.group(1)!.replaceAll(RegExp(r'\s+'), ' '));
    }

    return null;
  }

  String? _extractTiming(String text) {
    final match = _timingRx.firstMatch(text);
    return match != null ? _toTitleCase(match.group(1)!) : null;
  }

  int? _extractDuration(String text) {
    final match = _durationRx.firstMatch(text);
    if (match == null) return null;

    final value = int.tryParse(match.group(1)!) ?? 0;
    final unit = match.group(2)!.toLowerCase();
    if (unit.startsWith('week')) return value * 7;
    if (unit.startsWith('month')) return value * 30;
    return value;
  }

  String _decodeNumericSchedule(String m, String a, String e) {
    final parts = <String>[];
    if (m == '1') parts.add('Morning');
    if (a == '1') parts.add('Afternoon');
    if (e == '1') parts.add('Evening');

    final count = int.parse(m) + int.parse(a) + int.parse(e);
    switch (count) {
      case 1:
        return '${parts.join(' / ')} (Once daily)';
      case 2:
        return '${parts.join(' / ')} (Twice daily)';
      case 3:
        return 'Morning / Afternoon / Evening (Thrice daily)';
      default:
        return parts.join(' / ');
    }
  }

  String _decodeFreqAbbr(String abbr) {
    const map = {
      'OD': 'Once daily',
      'BD': 'Twice daily',
      'TDS': 'Thrice daily',
      'QID': 'Four times daily',
      'SOS': 'As needed',
      'PRN': 'As needed',
      'HS': 'At bedtime',
      'AC': 'Before food',
      'PC': 'After food',
    };

    return map[abbr] ?? abbr;
  }

  double _calcConfidence({
    required bool hasDosage,
    required bool hasFrequency,
    required bool hasTiming,
    required bool hasDuration,
  }) {
    var score = _wName;
    if (hasDosage) score += _wDosage;
    if (hasFrequency) score += _wFrequency;
    if (hasTiming) score += _wTiming;
    if (hasDuration) score += _wDuration;
    return score;
  }

  String _toTitleCase(String value) => value
      .split(' ')
      .map(
        (word) => word.isEmpty
            ? ''
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
      )
      .join(' ');
}
