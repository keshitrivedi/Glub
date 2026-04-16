import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class RecipesTab extends StatelessWidget {
  const RecipesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final recipes = [
      _Recipe(name: 'Quinoa Khichdi', time: '25 mins', kcal: 280, tag: 'FEATURED'),
      _Recipe(name: 'Palak Paneer (Low Carb)', time: '20 mins', kcal: 210, tag: null),
      _Recipe(name: 'Masala Cauliflower Rice', time: '20 mins', kcal: 195, tag: 'QUICK BREAKFAST'),
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Spacer(),
                const Text('Glub', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: AppColors.textDark)),
                const Spacer(),
                CircleAvatar(radius: 18, backgroundColor: AppColors.lightGreen, child: const Icon(Icons.person_outline, color: AppColors.textDark, size: 20)),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Authentic Indian\nMindful Flavors', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textDark, height: 1.15)),
            const SizedBox(height: 6),
            const Text('Discover diabetes-friendly variations of traditional classics.', style: TextStyle(fontSize: 13, color: AppColors.textDark)),
            const SizedBox(height: 20),

            // Search bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppColors.textDark.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: AppColors.textDark.withOpacity(0.45)),
                  const SizedBox(width: 10),
                  Expanded(child: Text('Search for recipes, ingredients...', style: TextStyle(color: AppColors.textDark.withOpacity(0.4), fontSize: 14))),
                  Icon(Icons.mic_outlined, color: AppColors.textDark.withOpacity(0.45)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['All Recipes', 'Low Carb', 'High Protein']
                    .asMap()
                    .entries
                    .map((e) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _Chip(label: e.value, selected: e.key == 0),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 20),

            ...recipes.map((r) => _buildRecipeCard(r)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeCard(_Recipe r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.lightGreen,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.textDark.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Container(
                  height: 160,
                  width: double.infinity,
                  color: AppColors.background,
                  child: Center(
                    child: Icon(Icons.restaurant, size: 64, color: AppColors.primaryGreen.withOpacity(0.35)),
                  ),
                ),
              ),
              Positioned(
                top: 0, left: 0, right: 0, bottom: 0,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, AppColors.primaryGreen.withOpacity(0.3)],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: const Icon(Icons.play_arrow_rounded, color: AppColors.primaryGreen, size: 24),
                ),
              ),
              Positioned(
                bottom: 12,
                right: 12,
                child: Icon(Icons.favorite_border, color: AppColors.white, size: 22),
              ),
              if (r.tag != null)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(r.tag!, style: const TextStyle(color: AppColors.white, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textDark)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: AppColors.textDark.withOpacity(0.55)),
                    const SizedBox(width: 4),
                    Text(r.time, style: TextStyle(fontSize: 12, color: AppColors.textDark.withOpacity(0.6))),
                    const SizedBox(width: 12),
                    Icon(Icons.local_fire_department_outlined, size: 14, color: AppColors.textDark.withOpacity(0.55)),
                    const SizedBox(width: 4),
                    Text('${r.kcal} kcal', style: TextStyle(fontSize: 12, color: AppColors.textDark.withOpacity(0.6))),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryGreen,
                      side: const BorderSide(color: AppColors.primaryGreen),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('View Full Recipe →', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
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

class _Recipe {
  final String name, time;
  final int kcal;
  final String? tag;
  const _Recipe({required this.name, required this.time, required this.kcal, this.tag});
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  const _Chip({required this.label, required this.selected});

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
