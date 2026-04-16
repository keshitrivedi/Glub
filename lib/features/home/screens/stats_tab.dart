import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class StatsTab extends StatelessWidget {
  const StatsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Center(child: Text('Glub', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: AppColors.textDark))),
            const SizedBox(height: 24),
            const Text('Stats', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const Text('All your numbers at one place.', style: TextStyle(fontSize: 14, color: AppColors.textDark)),
            const SizedBox(height: 20),

            // Weekly Trend Card
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('WEEKLY TREND', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1, color: AppColors.textDark)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text('104', style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                      const SizedBox(width: 8),
                      const Text('mg/dL Avg', style: TextStyle(fontSize: 13, color: AppColors.textDark)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('Stable', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w700, fontSize: 13)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 100,
                    child: CustomPaint(
                      painter: _BarChartPainter(),
                      size: Size.infinite,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN']
                        .map((d) => Text(d, style: TextStyle(fontSize: 10, color: AppColors.textDark.withOpacity(0.5), fontWeight: FontWeight.w600)))
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Range card
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Range', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textDark, fontSize: 15)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('84–142', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                      const SizedBox(width: 8),
                      Text('in target range (mg/dL)', style: TextStyle(fontSize: 13, color: AppColors.textDark.withOpacity(0.6))),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: 0.72,
                      minHeight: 10,
                      backgroundColor: AppColors.inputBackground,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('72% in range', style: TextStyle(fontSize: 12, color: AppColors.textDark.withOpacity(0.6), fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Variability card
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Variability', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textDark, fontSize: 15)),
                  const SizedBox(height: 4),
                  const Text('12%', style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  Text('Low fluctuation levels', style: TextStyle(fontSize: 13, color: AppColors.textDark.withOpacity(0.6))),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Export card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Export Medical Report', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white)),
                  const SizedBox(height: 6),
                  Text(
                    'Generate a comprehensive PDF including full glucose readings, insulin dosing, and activity summaries for your next consultation.',
                    style: TextStyle(fontSize: 13, color: AppColors.white.withOpacity(0.85)),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.white,
                      foregroundColor: AppColors.primaryGreen,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    icon: const Icon(Icons.download_rounded, size: 18),
                    label: const Text('Download PDF Report', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.textDark.withOpacity(0.1)),
      ),
      child: child,
    );
  }
}

class _BarChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final values = [0.6, 0.8, 0.55, 0.9, 0.75, 0.5, 0.65];
    final barWidth = size.width / (values.length * 2 - 1);
    final gap = barWidth;
    final paintNormal = Paint()
      ..color = const Color(0xFF8BAF78)
      ..style = PaintingStyle.fill;
    final paintHigh = Paint()
      ..color = AppColors.primaryGreen
      ..style = PaintingStyle.fill;

    for (int i = 0; i < values.length; i++) {
      final x = i * (barWidth + gap);
      final h = size.height * values[i];
      final rect = Rect.fromLTWH(x, size.height - h, barWidth, h);
      final r = 6.0;
      final rr = RRect.fromRectAndRadius(rect, Radius.circular(r));
      canvas.drawRRect(rr, i == 3 ? paintHigh : paintNormal);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
