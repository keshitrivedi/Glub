import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../onboarding/models/onboarding_data.dart';

class HomeTab extends StatefulWidget {
  final OnboardingData data;
  const HomeTab({super.key, required this.data});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final TextEditingController _sugarController = TextEditingController();
  final TextEditingController _insulinController = TextEditingController();

  final List<_LogEntry> _recentLogs = [
    _LogEntry(time: '6:13 AM', label: 'Fasting Blood Sugar', value: '102', unit: 'mg/dL', icon: Icons.water_drop_outlined),
    _LogEntry(time: 'Yesterday, 10:45 PM', label: 'Bedtime sugar', value: '148', unit: 'mg/dL', icon: Icons.nightlight_outlined),
  ];

  @override
  void dispose() {
    _sugarController.dispose();
    _insulinController.dispose();
    super.dispose();
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void _saveEntry(String type, String value) {
    if (value.trim().isEmpty) return;
    final unit = type == 'Blood Sugar' ? 'mg/dL' : 'units';
    setState(() {
      _recentLogs.insert(
        0,
        _LogEntry(
          time: _formattedNow(),
          label: type,
          value: value.trim(),
          unit: unit,
          icon: type == 'Blood Sugar' ? Icons.water_drop_outlined : Icons.vaccines_outlined,
        ),
      );
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$type logged: $value $unit'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  String _formattedNow() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : now.hour;
    final amPm = now.hour >= 12 ? 'PM' : 'AM';
    final min = now.minute.toString().padLeft(2, '0');
    return 'Today, $hour:$min $amPm';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.arrow_back, color: Colors.transparent), // spacer
                const Spacer(),
                const Text('Glub', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: AppColors.textDark)),
                const Spacer(),
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.lightGreen,
                  child: const Icon(Icons.person_outline, color: AppColors.textDark, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              '${_greeting()}, Priya.',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            const SizedBox(height: 4),
            const Text(
              'Log your readings like the good girl you are.',
              style: TextStyle(fontSize: 14, color: AppColors.textDark, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              _dateLabel(),
              style: TextStyle(fontSize: 13, color: AppColors.textDark.withOpacity(0.55), fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            // Blood Sugar Card
            _buildLogCard(
              title: 'Log Blood Sugar',
              subtitle: 'Stay within your range',
              controller: _sugarController,
              hint: 'Enter value',
              unit: 'mg/dL',
              suffix: 'mg/dL',
              onSave: () => _saveEntry('Blood Sugar', _sugarController.text),
            ),
            const SizedBox(height: 16),
            // Insulin Card
            _buildLogCard(
              title: 'Log Insulin',
              subtitle: 'Track your units carefully',
              controller: _insulinController,
              hint: 'Enter value',
              unit: 'units',
              suffix: 'units',
              onSave: () => _saveEntry('Insulin', _insulinController.text),
            ),
            const SizedBox(height: 28),
            // Recent Logs
            Row(
              children: [
                const Text('Recent Logs', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textDark)),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                  child: const Text('SEE HISTORY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryGreen, letterSpacing: 0.5)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_recentLogs.isEmpty)
              const Center(child: Text('No logs yet.', style: TextStyle(color: AppColors.textDark)))
            else
              ..._recentLogs.take(5).map((log) => _buildLogEntry(log)),
          ],
        ),
      ),
    );
  }

  Widget _buildLogCard({
    required String title,
    required String subtitle,
    required TextEditingController controller,
    required String hint,
    required String unit,
    required String suffix,
    required VoidCallback onSave,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.textDark.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textDark)),
              const Spacer(),
              Icon(Icons.edit_outlined, color: AppColors.textDark.withOpacity(0.5), size: 18),
            ],
          ),
          Text(subtitle, style: TextStyle(fontSize: 13, color: AppColors.textDark.withOpacity(0.6))),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.mic_outlined, color: AppColors.textDark, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: controller,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: hint,
                            isDense: true,
                            hintStyle: TextStyle(color: AppColors.textDark.withOpacity(0.4), fontSize: 15),
                          ),
                          style: const TextStyle(fontSize: 15, color: AppColors.textDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  elevation: 0,
                ),
                child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogEntry(_LogEntry log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(log.icon, size: 18, color: AppColors.primaryGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(log.time, style: TextStyle(fontSize: 11, color: AppColors.textDark.withOpacity(0.55), fontWeight: FontWeight.w600)),
                Text(log.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark)),
              ],
            ),
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(text: log.value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                TextSpan(text: '\n${log.unit}', style: TextStyle(fontSize: 11, color: AppColors.textDark.withOpacity(0.55))),
              ],
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  String _dateLabel() {
    final now = DateTime.now();
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    const days = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
    final weekday = days[now.weekday - 1];
    return '$weekday, ${now.day} ${months[now.month - 1]}';
  }
}

class _LogEntry {
  final String time;
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  const _LogEntry({required this.time, required this.label, required this.value, required this.unit, required this.icon});
}
