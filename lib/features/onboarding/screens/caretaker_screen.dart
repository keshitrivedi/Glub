import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../models/onboarding_data.dart';
import 'diabetes_type_screen.dart';

class CaretakerScreen extends StatelessWidget {
  final OnboardingData data;

  const CaretakerScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Glub',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Text(
                'Please give the device to your\ncaretaker to log the details for\nyou',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 50),
              Center(
                child: Image.asset(
                  'assets/images/smiley.png',
                  width: 120,
                  height: 120,
                ),
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DiabetesTypeScreen(data: data),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.inputBackground,
                  foregroundColor: AppColors.textDark,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: AppColors.textDark.withValues(alpha: 128),
                    ),
                  ),
                  elevation: 0,
                ),
                child: const Text('Okay', style: TextStyle(fontSize: 16)),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
