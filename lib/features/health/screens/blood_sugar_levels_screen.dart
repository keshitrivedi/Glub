import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../services/voice_service.dart';
import '../../../utils/number_parser.dart';
import '../../onboarding/models/onboarding_data.dart';

class BloodSugarLevelsScreen extends StatefulWidget {
  final OnboardingData data;

  const BloodSugarLevelsScreen({super.key, required this.data});

  @override
  State<BloodSugarLevelsScreen> createState() =>
      _BloodSugarLevelsScreenState();
}

class _BloodSugarLevelsScreenState extends State<BloodSugarLevelsScreen>
    with SingleTickerProviderStateMixin {
  late final VoiceService _voiceService;

  int? _bloodSugar;
  bool _isListening = false;

  bool? _tookInsulin; // true = Yes, false = No

  bool _logComplete = false;
  bool _isLoggingInProgress = false;
  late final AnimationController _tickController;

  @override
  void initState() {
    super.initState();
    _voiceService = VoiceService();
    _voiceService.addListener(_onVoiceUpdate);
    _tickController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
        setState(() {
          _logComplete = true;
          _isLoggingInProgress = false;
        });
        }
      });
  }

  @override
  void dispose() {
    _voiceService.removeListener(_onVoiceUpdate);
    _tickController.dispose();
    super.dispose();
  }

  void _onVoiceUpdate() {
    final raw = _voiceService.rawText;
    setState(() {
      _isListening = _voiceService.isListening;
      _bloodSugar = _parseBloodSugar(raw);
    });
  }

  int? _parseBloodSugar(String rawText) {
    if (rawText.trim().isEmpty) return null;

    final parsedRaw = NumberParser.parseRaw(rawText);
    if (parsedRaw == 'No number detected') return null;

    final n = int.tryParse(parsedRaw);
    if (n == null) return null;

    // Accept a wide range since the user said "whatever number we say".
    // (Still guards obviously-wrong negatives.)
    if (n <= 0 || n > 1000) return null;
    return n;
  }

  void _toggleMic() {
    _voiceService.listen(onResult: (_) {});
  }

  void _retryBloodSugar() {
    _voiceService.reset();
    setState(() {
      _bloodSugar = null;
    });
  }

  void _onLogPressed() async {
    if (_bloodSugar == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please speak your blood sugar reading.')),
      );
      return;
    }
    if (_tookInsulin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select whether you took insulin doses.')),
      );
      return;
    }

    setState(() {
      _logComplete = false;
      _isLoggingInProgress = true;
    });
    _tickController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final unit = widget.data.glucoseUnit ?? 'mg/dL';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 8),
              _buildHeader(),
              const SizedBox(height: 24),
              const Text(
                'Log in your blood sugar levels & insulin doses.',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.lightGreen,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        _buildBloodSugarSection(unit),
                        const SizedBox(height: 16),
                        const Divider(height: 1, color: Color(0x99334B3C)),
                        const SizedBox(height: 16),
                        _buildInsulinSection(),
                        const SizedBox(height: 18),
                        _buildBottomLogBar(),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        const Expanded(
          child: Center(
            child: Text(
              'Glub',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
        ),
        // Keeps the title centered.
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildBloodSugarSection(String unit) {
    final displayedValue = _bloodSugar?.toString() ?? '--';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Row(
          children: [
            Text(
              'Blood Sugar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            Spacer(),
          ],
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: _toggleMic,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            height: 74,
            decoration: BoxDecoration(
              color: _isListening
                  ? AppColors.inputBackground.withValues(alpha: 166)
                  : AppColors.inputBackground,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.textDark.withValues(alpha: 38),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedScale(
                  scale: _isListening ? 1.08 : 1.0,
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    Icons.mic,
                    size: 36,
                    color:
                        _isListening ? AppColors.primaryGreen : AppColors.textDark,
                  ),
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: AppColors.textDark),
                    tooltip: 'Retry / edit',
                    onPressed: _retryBloodSugar,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Text(
            '$displayedValue $unit',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInsulinSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Did you take your insulin doses?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ChoiceButton(
                label: 'Yes',
                selected: _tookInsulin == true,
                icon: Icons.check_circle,
                onTap: () => setState(() => _tookInsulin = true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ChoiceButton(
                label: 'No',
                selected: _tookInsulin == false,
                icon: Icons.radio_button_unchecked,
                onTap: () => setState(() => _tookInsulin = false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomLogBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '< Back',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            onPressed: (_logComplete || _isLoggingInProgress) ? null : _onLogPressed,
            child: AnimatedBuilder(
              animation: _tickController,
              builder: (context, child) {
                final t = _tickController.value;
                final visible = _logComplete || t > 0.0;

                if (!visible && !_logComplete) {
                  return const Text(
                    'Log in',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  );
                }

                final opacity = t.clamp(0.0, 1.0);
                final scale = 0.75 + (0.25 * opacity);
                final rotate = (1 - opacity) * 0.25;

                return Transform.rotate(
                  angle: rotate,
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.scale(
                      scale: scale,
                      child: const Icon(Icons.check_circle, size: 22),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  final String label;
  final bool selected;
  final IconData icon;
  final VoidCallback onTap;

  const _ChoiceButton({
    required this.label,
    required this.selected,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.inputBackground.withValues(alpha: 230)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.textDark.withValues(
              alpha: selected ? 38 : 20,
            ),
          ),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 18,
                  color: selected
                      ? AppColors.primaryGreen
                      : AppColors.textDark.withValues(alpha: 115)),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: selected ? AppColors.primaryGreen : AppColors.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

