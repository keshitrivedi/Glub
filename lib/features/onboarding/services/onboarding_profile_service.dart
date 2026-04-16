import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../config/supabase_config.dart';
import '../models/onboarding_data.dart';

class OnboardingProfileService {
  const OnboardingProfileService();

  Future<String?> upsertOnboardingProfile(OnboardingData data) async {
    final existingProfileId = data.profileId?.trim();
    final fallbackProfileId = SupabaseConfig.profileId.trim();

    final profileId = (existingProfileId != null && existingProfileId.isNotEmpty)
        ? existingProfileId
        : (fallbackProfileId.isNotEmpty ? fallbackProfileId : _generateProfileId());

    data.profileId = profileId;

    if (!SupabaseConfig.isConfigured) {
      return profileId;
    }

    await Supabase.instance.client.from('onboarding_profiles').upsert(
      {
        'profile_id': profileId,
        'is_tech_proficient': data.isTechProficient,
        'diabetes_type': data.diabetesType,
        'glucose_unit': data.glucoseUnit,
        'carbs_unit': data.carbsUnit,
        'insulin_therapy': data.insulinTherapy,
        'target_range_high': data.targetRangeHigh,
        'target_range_low': data.targetRangeLow,
      },
      onConflict: 'profile_id',
    );

    return profileId;
  }

  String _generateProfileId() {
    final random = Random();
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final suffix = random.nextInt(1000000).toString().padLeft(6, '0');
    return 'profile_$stamp$suffix';
  }
}
