import 'onboarding_data.dart';

// Mapping keeps existing OnboardingData field names intact by translating them
// to Supabase column names here instead of renaming any variables.
class OnboardingDataMapper {
  static Map<String, dynamic> toSupabaseJson(OnboardingData data) {
    return <String, dynamic>{
      'is_tech_proficient': data.isTechProficient,
      'diabetes_type': data.diabetesType,
      'glucose_unit': data.glucoseUnit,
      'carbs_unit': data.carbsUnit,
      'insulin_therapy': data.insulinTherapy,
      'target_range_high': data.targetRangeHigh,
      'target_range_low': data.targetRangeLow,
    };
  }

  static OnboardingData fromSupabaseJson(Map<String, dynamic> json) {
    return OnboardingData(
      isTechProficient: json['is_tech_proficient'] as bool?,
      diabetesType: json['diabetes_type'] as String?,
      glucoseUnit: json['glucose_unit'] as String?,
      carbsUnit: json['carbs_unit'] as String?,
      insulinTherapy: json['insulin_therapy'] as String?,
      targetRangeHigh: json['target_range_high'] as String?,
      targetRangeLow: json['target_range_low'] as String?,
    );
  }
}
