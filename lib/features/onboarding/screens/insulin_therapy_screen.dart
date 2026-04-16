import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../models/onboarding_data.dart';
import 'ranges_screen.dart';

class InsulinTherapyScreen extends StatelessWidget {
  final OnboardingData data;

  const InsulinTherapyScreen({super.key, required this.data});

  final List<String> options = const [
    'Pen / Syringe',
    'Pump',
    'No Insulin',
  ];

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Text(
                'What is your insulin therapy?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: options.map((option) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ElevatedButton(
                        onPressed: () {
                          data.insulinTherapy = option;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RangesScreen(data: data),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.background,
                          foregroundColor: AppColors.textDark,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(color: AppColors.textDark.withOpacity(0.1)),
                          ),
                          elevation: 0,
                        ),
                        child: Center(
                          child: Text(
                            option,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
