import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../voice/screens/speech_screen.dart';

class ActionSelectionScreen extends StatelessWidget {
  const ActionSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // The background color from the image seems to be a light green,
    // we use a close match but you can also use AppColors.background if preferred for consistency.
    const Color screenBackground = Color(0xFFC1D690); 

    return Scaffold(
      backgroundColor: screenBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar with Logo and Title
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
                      child: Image.asset(
                        'assets/images/logo.png',
                      ),
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
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 50), // To balance the row and keep 'glub' truly centered
                ],
              ),
              const SizedBox(height: 40),
              
              // Medicine Button
              Expanded(
                child: _buildActionButton(
                  context: context,
                  label: 'Medicine',
                  onTap: () => _navigateToVoice(context),
                ),
              ),
              const SizedBox(height: 24),
              
              // Logging Button
              Expanded(
                child: _buildActionButton(
                  context: context,
                  label: 'Logging',
                  onTap: () => _navigateToVoice(context),
                ),
              ),
              const SizedBox(height: 24),
              
              // Exercises Button
              Expanded(
                child: _buildActionButton(
                  context: context,
                  label: 'Exercises',
                  onTap: () => _navigateToVoice(context),
                ),
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
        decoration: BoxDecoration(
          color: const Color(0xFF38513B), // Dark Green matching the image
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

  void _navigateToVoice(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const SpeechScreen()),
      (Route<dynamic> route) => false,
    );
  }
}
