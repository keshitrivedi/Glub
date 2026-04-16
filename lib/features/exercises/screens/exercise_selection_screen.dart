import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../theme/app_colors.dart';
import 'exercise_video_screen.dart';

class ExerciseSelectionScreen extends StatelessWidget {
  const ExerciseSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Row (matches screenshot: title left, mic + mode right)
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Exercise',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const Spacer(),
                  const IconButton(
                    onPressed: null, // purely decorative for now
                    icon: Icon(Icons.mic, color: AppColors.textDark),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                      color: Colors.black87,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.dark_mode,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _ExerciseCard(
                        topBackground: const LinearGradient(
                          colors: [
                            Color(0xFF1E4A53),
                            Color(0xFF204A3A),
                          ],
                        ),
                        topIconAsset: 'assets/images/smiley.svg',
                        title: 'Morning Stretch',
                        subtitle: 'Light movement to start your day',
                        buttonLabel: 'Start Now',
                        buttonIcon: Icons.play_arrow_rounded,
                        youtubeVideoId: 'VIDEO_ID_MORNING_STRETCH',
                        onButtonPressed: (videoId) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ExerciseVideoScreen(
                                title: 'Morning Stretch',
                                videoId: videoId,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 18),
                      _ExerciseCard(
                        topBackground: const LinearGradient(
                          colors: [
                            Color(0xFF2E5B3A),
                            Color(0xFF2A3F55),
                          ],
                        ),
                        topIconAsset: 'assets/images/smiley.svg',
                        title: 'Brisk Walk',
                        subtitle: '15 minutes in nature for energy',
                        buttonLabel: 'Record Walk',
                        buttonIcon: Icons.directions_walk_rounded,
                        youtubeVideoId: 'VIDEO_ID_BRISK_WALK',
                        onButtonPressed: (videoId) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ExerciseVideoScreen(
                                title: 'Brisk Walk',
                                videoId: videoId,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final LinearGradient topBackground;
  final String topIconAsset;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final IconData buttonIcon;
  final String youtubeVideoId;
  final ValueChanged<String> onButtonPressed;

  const _ExerciseCard({
    required this.topBackground,
    required this.topIconAsset,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.buttonIcon,
    required this.youtubeVideoId,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: AppColors.lightGreen,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 165,
            decoration: BoxDecoration(
              gradient: topBackground,
            ),
            child: Center(
              child: Opacity(
                opacity: 0.95,
                child: SvgPicture.asset(
                  topIconAsset,
                  width: 96,
                  height: 96,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.25,
                    color: AppColors.textDark.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => onButtonPressed(youtubeVideoId),
                    icon: Icon(buttonIcon, size: 20),
                    label: Text(
                      buttonLabel,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

