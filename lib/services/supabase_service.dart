import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/onboarding/models/onboarding_data.dart';
import '../features/onboarding/models/onboarding_data_mapper.dart';
import '../models/logged_medicine.dart';
import 'supabase_config.dart';

SupabaseClient get supabaseClient => Supabase.instance.client;

class SupabaseResult<T> {
  final T? data;
  final String? errorMessage;

  const SupabaseResult._({this.data, this.errorMessage});

  bool get isSuccess => errorMessage == null;

  factory SupabaseResult.success(T data) {
    return SupabaseResult._(data: data);
  }

  factory SupabaseResult.failure(String message) {
    return SupabaseResult._(errorMessage: message);
  }
}

class SupabaseService {
  final SupabaseClient? _clientOverride;

  SupabaseService({SupabaseClient? client}) : _clientOverride = client;

  SupabaseClient get _client => _clientOverride ?? supabaseClient;

  Future<SupabaseResult<Map<String, dynamic>>> createBloodSugarLog({
    required int bloodSugar,
    required bool tookInsulin,
    required String unit,
    DateTime? loggedAt,
  }) async {
    if (!isSupabaseConfigured) {
      return SupabaseResult.failure(
        'Supabase is not configured. Provide SUPABASE_URL and SUPABASE_ANON_KEY.',
      );
    }

    try {
      final payload = <String, dynamic>{
        'blood_sugar': bloodSugar,
        'took_insulin': tookInsulin,
        'unit': unit,
        'logged_at': (loggedAt ?? DateTime.now()).toIso8601String(),
      };

      final result = await _client
          .from('blood_sugar_logs')
          .insert(payload)
          .select()
          .single();

      return SupabaseResult.success(result);
    } on PostgrestException catch (e) {
      return SupabaseResult.failure(e.message);
    } on AuthException catch (e) {
      return SupabaseResult.failure(e.message);
    }
  }

Future<SupabaseResult<Map<String, dynamic>>> saveMedicineLog({
    required String profileId,
    required LoggedMedicine medicine,
  }) async {
    if (!isSupabaseConfigured) {
      return SupabaseResult.failure('Supabase is not configured.');
    }
    try {
      final result = await _client
          .from('medicine_logs')
          .insert({
            'profile_id': profileId,
            'medicine_name': medicine.medicineName,
            'company': medicine.company,
            'medicine_type': medicine.medicineType,
            'oral_timing': medicine.oralTiming,
            'dose_unit': medicine.doseUnit,
            'insulin_profile': medicine.insulinProfile,
            'injection_site': medicine.injectionSite,
            'quantity': medicine.quantity,
            'dose_time': medicine.doseTime,
            'days': medicine.days,
            'take_with_food': medicine.takeWithFood,
            'check_bg_before_dose': medicine.checkBgBeforeDose,
            'override_target_glucose': medicine.overrideTargetGlucose,
            'target_low': medicine.targetLow,
            'target_high': medicine.targetHigh,
            'notes': medicine.notes,
          })
          .select()
          .single();
      return SupabaseResult.success(result);
    } on PostgrestException catch (e) {
      return SupabaseResult.failure(e.message);
    } on AuthException catch (e) {
      return SupabaseResult.failure(e.message);
    }
  }

  Future<SupabaseResult<List<Map<String, dynamic>>>> fetchMedicineLogs({
    required String profileId,
  }) async {
    if (!isSupabaseConfigured) {
      return SupabaseResult.failure('Supabase is not configured.');
    }
    try {
      final result = await _client
          .from('medicine_logs')
          .select()
          .eq('profile_id', profileId)
          .order('created_at', ascending: false);
      return SupabaseResult.success(
        (result as List<dynamic>).cast<Map<String, dynamic>>(),
      );
    } on PostgrestException catch (e) {
      return SupabaseResult.failure(e.message);
    } on AuthException catch (e) {
      return SupabaseResult.failure(e.message);
    }
  }

  Future<SupabaseResult<List<Map<String, dynamic>>>> fetchBloodSugarLogs({
    int limit = 50,
  }) async {
    if (!isSupabaseConfigured) {
      return SupabaseResult.failure(
        'Supabase is not configured. Provide SUPABASE_URL and SUPABASE_ANON_KEY.',
      );
    }

    try {
      final result = await _client
          .from('blood_sugar_logs')
          .select()
          .order('logged_at', ascending: false)
          .limit(limit);

      return SupabaseResult.success(
        (result as List<dynamic>).cast<Map<String, dynamic>>(),
      );
    } on PostgrestException catch (e) {
      return SupabaseResult.failure(e.message);
    } on AuthException catch (e) {
      return SupabaseResult.failure(e.message);
    }
  }

  Future<SupabaseResult<Map<String, dynamic>>> updateBloodSugarLog({
    required int id,
    required Map<String, dynamic> updates,
  }) async {
    if (!isSupabaseConfigured) {
      return SupabaseResult.failure(
        'Supabase is not configured. Provide SUPABASE_URL and SUPABASE_ANON_KEY.',
      );
    }

    try {
      final result = await _client
          .from('blood_sugar_logs')
          .update(updates)
          .eq('id', id)
          .select()
          .single();

      return SupabaseResult.success(result);
    } on PostgrestException catch (e) {
      return SupabaseResult.failure(e.message);
    } on AuthException catch (e) {
      return SupabaseResult.failure(e.message);
    }
  }

  Future<SupabaseResult<bool>> deleteBloodSugarLog({required int id}) async {
    if (!isSupabaseConfigured) {
      return SupabaseResult.failure(
        'Supabase is not configured. Provide SUPABASE_URL and SUPABASE_ANON_KEY.',
      );
    }

    try {
      await _client.from('blood_sugar_logs').delete().eq('id', id);
      return SupabaseResult.success(true);
    } on PostgrestException catch (e) {
      return SupabaseResult.failure(e.message);
    } on AuthException catch (e) {
      return SupabaseResult.failure(e.message);
    }
  }

  Future<SupabaseResult<Map<String, dynamic>>> upsertOnboardingProfile({
    required String profileId,
    required OnboardingData data,
  }) async {
    if (!isSupabaseConfigured) {
      return SupabaseResult.failure(
        'Supabase is not configured. Provide SUPABASE_URL and SUPABASE_ANON_KEY.',
      );
    }

    try {
      final payload = OnboardingDataMapper.toSupabaseJson(data)
        ..['profile_id'] = profileId;

      final result = await _client
          .from('onboarding_profiles')
          .upsert(payload)
          .select()
          .single();

      return SupabaseResult.success(result);
    } on PostgrestException catch (e) {
      return SupabaseResult.failure(e.message);
    } on AuthException catch (e) {
      return SupabaseResult.failure(e.message);
    }
  }

  Future<SupabaseResult<OnboardingData?>> fetchOnboardingProfile({
    required String profileId,
  }) async {
    if (!isSupabaseConfigured) {
      return SupabaseResult.failure(
        'Supabase is not configured. Provide SUPABASE_URL and SUPABASE_ANON_KEY.',
      );
    }

    try {
      final result = await _client
          .from('onboarding_profiles')
          .select()
          .eq('profile_id', profileId)
          .maybeSingle();

      if (result == null) {
        return SupabaseResult.success(null);
      }

      return SupabaseResult.success(
        OnboardingDataMapper.fromSupabaseJson(result),
      );
    } on PostgrestException catch (e) {
      return SupabaseResult.failure(e.message);
    } on AuthException catch (e) {
      return SupabaseResult.failure(e.message);
    }
  }
}
