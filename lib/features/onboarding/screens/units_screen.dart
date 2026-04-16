import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../models/onboarding_data.dart';
import 'insulin_therapy_screen.dart';

class UnitsScreen extends StatefulWidget {
  final OnboardingData data;

  const UnitsScreen({super.key, required this.data});

  @override
  State<UnitsScreen> createState() => _UnitsScreenState();
}

class _UnitsScreenState extends State<UnitsScreen> {
  String selectedGlucose = 'mg/dL';
  String selectedCarbs = 'g';

  void _onNext() {
    widget.data.glucoseUnit = selectedGlucose;
    widget.data.carbsUnit = selectedCarbs;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InsulinTherapyScreen(data: widget.data),
      ),
    );
  }

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
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.lightGreen,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Please select units that are right for you. Ask your healthcare professional.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          'Glucose',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 15),
                        _buildToggle(
                          options: ['mg/dL', 'mmol/L'],
                          selected: selectedGlucose,
                          onChanged: (val) => setState(() => selectedGlucose = val),
                        ),
                        const SizedBox(height: 40),
                        const Text(
                          'Carbs',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 15),
                        _buildToggle(
                          options: ['g', 'CP', 'ex'],
                          selected: selectedCarbs,
                          onChanged: (val) => setState(() => selectedCarbs = val),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: IconButton(
                  onPressed: _onNext,
                  icon: const Icon(Icons.arrow_forward_ios),
                  color: AppColors.primaryGreen,
                  iconSize: 30,
                  padding: const EdgeInsets.all(15),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.lightGreen,
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

  Widget _buildToggle({
    required List<String> options,
    required String selected,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      children: options.map((option) {
        final isSelected = option == selected;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: () => onChanged(option),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.lightGreen : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryGreen
                      : AppColors.textDark.withValues(alpha: 51),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
