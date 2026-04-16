import '../models/onboarding_data.dart';

class OnboardingProfileService {
  const OnboardingProfileService();

  /// Saves onboarding data in-memory only.
  Future<String?> saveProfile(OnboardingData data) async {
    final profileId = data.profileId?.trim() ?? _generateProfileId();
    data.profileId = profileId;
    return profileId;
  }

  String _generateProfileId() {
    final stamp = DateTime.now().millisecondsSinceEpoch;
    return 'profile_$stamp';
  }
}
