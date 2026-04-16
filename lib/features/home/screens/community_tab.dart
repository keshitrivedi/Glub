import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import 'create_post_screen.dart';

class CommunityTab extends StatelessWidget {
  const CommunityTab({super.key});

  @override
  Widget build(BuildContext context) {
    final posts = [
      _Post(name: 'Elena R.', role: 'Type 1 • 11min', tag: 'POT', body: 'My low-glycemic smoothie recipe that actually tastes like dessert! 😍', comments: 42, likes: 128),
      _Post(name: 'Marcus K.', role: 'Type 2 • 1hr ago', tag: null, body: 'Finally kept my glucose in the target range for 7 days straight. Celebrating with a long walk! 🚶', comments: 59, likes: 312),
      _Post(name: 'Sophie L.', role: 'Support • 6hr ago', tag: null, body: 'Anyone else struggling with late-night cravings during high-stress weeks? 😮', comments: 56, likes: 94),
    ];

    return SafeArea(
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(child: Text('Glub', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: AppColors.textDark))),
                const SizedBox(height: 24),
                const Text('Community Feed', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const Text('Share your journey, find support, and celebrate every small victory with your botanical family.', style: TextStyle(fontSize: 13, color: AppColors.textDark)),
                const SizedBox(height: 20),

                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All Spaces', 'Nutrition', 'Daily Win']
                        .asMap()
                        .entries
                        .map((e) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _FilterChip(label: e.value, selected: e.key == 0),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text('Trending Now', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textDark)),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                      child: const Text('See all →', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.primaryGreen)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...posts.map((p) => _buildPostCard(p)),
                const SizedBox(height: 16),

                // Expert guide
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.lightGreen,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.textDark.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('✦ GLUB EXPERT GUIDE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textDark.withOpacity(0.5), letterSpacing: 1)),
                      const SizedBox(height: 6),
                      const Text('Mastering CGM: 5 Tips for Data Accuracy', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textDark)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const CircleAvatar(radius: 10, backgroundColor: AppColors.inputBackground),
                          const SizedBox(width: 4),
                          const CircleAvatar(radius: 10, backgroundColor: AppColors.primaryGreen),
                          const SizedBox(width: 8),
                          Text('Verified by specialists', style: TextStyle(fontSize: 12, color: AppColors.textDark.withOpacity(0.55))),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
          // FAB
          Positioned(
            bottom: 28,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      fullscreenDialog: true,
                      builder: (_) => const CreatePostScreen(),
                    ),
                  );
                },
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: AppColors.white,
                elevation: 4,
                child: const Icon(Icons.add, size: 28),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(_Post post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.textDark.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 18, backgroundColor: AppColors.inputBackground, child: Text(post.name[0], style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark))),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.name, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textDark)),
                    Text(post.role, style: TextStyle(fontSize: 12, color: AppColors.textDark.withOpacity(0.55))),
                  ],
                ),
              ),
              if (post.tag != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.primaryGreen.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                  child: Text(post.tag!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: AppColors.primaryGreen)),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(post.body, style: const TextStyle(color: AppColors.textDark, fontSize: 14, height: 1.4)),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.chat_bubble_outline, size: 16, color: AppColors.textDark),
              const SizedBox(width: 4),
              Text('${post.comments} comments', style: TextStyle(fontSize: 12, color: AppColors.textDark.withOpacity(0.6))),
              const SizedBox(width: 16),
              const Icon(Icons.favorite_outline, size: 16, color: AppColors.textDark),
              const SizedBox(width: 4),
              Text('${post.likes}', style: TextStyle(fontSize: 12, color: AppColors.textDark.withOpacity(0.6))),
            ],
          ),
        ],
      ),
    );
  }
}

class _Post {
  final String name, role, body;
  final String? tag;
  final int comments, likes;
  const _Post({required this.name, required this.role, required this.body, this.tag, required this.comments, required this.likes});
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  const _FilterChip({required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? AppColors.primaryGreen : AppColors.lightGreen,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? AppColors.primaryGreen : AppColors.textDark.withOpacity(0.2)),
      ),
      child: Text(label, style: TextStyle(color: selected ? AppColors.white : AppColors.textDark, fontWeight: FontWeight.w700, fontSize: 13)),
    );
  }
}
