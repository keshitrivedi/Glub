import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../models/onboarding_data.dart';
import 'diabetes_type_screen.dart';
import 'caretaker_screen.dart';

class TechProficiencyScreen extends StatelessWidget {
  final OnboardingData data;

  const TechProficiencyScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Text(
                'Would you consider yourself\nto be tech proficient?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  data.isTechProficient = true;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DiabetesTypeScreen(data: data),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.white,
                  foregroundColor: AppColors.textDark,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: AppColors.textDark.withOpacity(0.5)),
                  ),
                  elevation: 0,
                ),
                child: const Text('Yes', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  data.isTechProficient = false;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CaretakerScreen(data: data),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.white,
                  foregroundColor: AppColors.textDark,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: AppColors.textDark.withOpacity(0.5)),
                  ),
                  elevation: 0,
                ),
                child: const Text('No', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 40),
              const Text(
                'Click yes if you can log your\nown details.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textDark,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
