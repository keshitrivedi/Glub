// main.dart
// After refactor: only app bootstrap lives here.
// SpeechScreen, VoiceService, and NumberParser have moved out.

import 'package:flutter/material.dart';
import 'features/voice/screens/speech_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Glub',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const SpeechScreen(),
    );
  }
}