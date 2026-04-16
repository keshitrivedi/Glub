import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../models/onboarding_data.dart';
import '../../voice/screens/speech_screen.dart'; // Target navigation

class RangesScreen extends StatefulWidget {
  final OnboardingData data;

  const RangesScreen({super.key, required this.data});

  @override
  State<RangesScreen> createState() => _RangesScreenState();
}

class _RangesScreenState extends State<RangesScreen> {
  final TextEditingController highController = TextEditingController(text: '200');
  final TextEditingController targetLowController = TextEditingController(text: '70');
  final TextEditingController targetHighController = TextEditingController(text: '140');
  final TextEditingController lowController = TextEditingController(text: '70');

  void _finishSetup() {
    widget.data.targetRangeHigh = highController.text;
    widget.data.targetRangeLow = lowController.text;
    
    // Print data to show it's stored
    debugPrint('Onboarding Completed: ${widget.data.toString()}');

    // Navigate to SpeechScreen (main app screen) and clear history
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const SpeechScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  void dispose() {
    highController.dispose();
    targetLowController.dispose();
    targetHighController.dispose();
    lowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              const Text(
                'What are your ranges?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Your blood glucose target and limits should cover a full 24-hour period.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildRangeItem(
                      color: Colors.orange,
                      title: 'High limit',
                      controller1: highController,
                      unit: widget.data.glucoseUnit ?? 'mg/dL',
                    ),
                    const Divider(height: 30),
                    _buildTargetRangeItem(
                      color: Colors.green,
                      title: 'Target range',
                      controllerLow: targetLowController,
                      controllerHigh: targetHighController,
                      unit: widget.data.glucoseUnit ?? 'mg/dL',
                    ),
                    const Divider(height: 30),
                    _buildRangeItem(
                      color: Colors.red,
                      title: 'Low limit',
                      controller1: lowController,
                      unit: widget.data.glucoseUnit ?? 'mg/dL',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: ElevatedButton(
                  onPressed: _finishSetup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Finish Setup',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRangeItem({
    required Color color,
    required String title,
    required TextEditingController controller1,
    required String unit,
  }) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: TextField(
                      controller: controller1,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppColors.textDark.withOpacity(0.3)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(unit, style: const TextStyle(color: AppColors.textDark)),
                ],
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildTargetRangeItem({
    required Color color,
    required String title,
    required TextEditingController controllerLow,
    required TextEditingController controllerHigh,
    required String unit,
  }) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: TextField(
                      controller: controllerLow,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppColors.textDark.withOpacity(0.3)),
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('-', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(
                    width: 60,
                    child: TextField(
                      controller: controllerHigh,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppColors.textDark.withOpacity(0.3)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(unit, style: const TextStyle(color: AppColors.textDark)),
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}
