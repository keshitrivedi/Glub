import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../settings/widgets/prescription_scanner_screen.dart';
import '../../health/screens/blood_sugar_levels_screen.dart';
import '../../health/screens/medicine_logging_screen.dart';
import '../models/onboarding_data.dart';
import '../../exercises/screens/exercise_selection_screen.dart';

class ActionSelectionScreen extends StatelessWidget {
  final OnboardingData data;

  const ActionSelectionScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset('assets/images/logo.png'),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'glub',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 50),
                ],
              ),
              const SizedBox(height: 40),
              _buildActionButton(
                context: context,
                label: 'Medicine',
                onTap: () => _navigateToMedicine(context),
              ),
              const SizedBox(height: 24),
              _buildActionButton(
                context: context,
                label: 'Scan Prescription',
                onTap: () => _navigateToPrescriptionScanner(context),
              ),
              const SizedBox(height: 24),
              _buildActionButton(
                context: context,
                label: 'Logging',
                onTap: () => _navigateToBloodSugarLogging(context),
              ),
              const SizedBox(height: 24),
              _buildActionButton(
                context: context,
                label: 'Exercises',
                onTap: () => _navigateToExercises(context),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.primaryGreen,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 24,
              color: AppColors.white,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToMedicine(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => MedicineLoggingScreen(data: data),
      ),
      (Route<dynamic> route) => false,
    );
  }

  void _navigateToExercises(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const ExerciseSelectionScreen(),
      ),
      (Route<dynamic> route) => false,
    );
  }

  void _navigateToBloodSugarLogging(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => BloodSugarLevelsScreen(data: data),
      ),
      (Route<dynamic> route) => false,
    );
  }

  void _navigateToPrescriptionScanner(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PrescriptionScannerScreen(),
      ),
    );
  }
}
