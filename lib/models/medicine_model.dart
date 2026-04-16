/// Canonical medicine model used throughout the app and persisted to Supabase.
class MedicineModel {
  final String? id;
  final String userId;
  final String name;
  final String? dosage;
  final String? frequency;
  final String? timing;
  final int? durationDays;
  final DateTime? createdAt;

  const MedicineModel({
    this.id,
    required this.userId,
    required this.name,
    this.dosage,
    this.frequency,
    this.timing,
    this.durationDays,
    this.createdAt,
  });

  factory MedicineModel.fromJson(Map<String, dynamic> json) => MedicineModel(
        id: json['id'] as String?,
        userId: json['user_id'] as String,
        name: json['name'] as String,
        dosage: json['dosage'] as String?,
        frequency: json['frequency'] as String?,
        timing: json['timing'] as String?,
        durationDays: json['duration_days'] as int?,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'name': name,
        'dosage': dosage,
        'frequency': frequency,
        'timing': timing,
        'duration_days': durationDays,
      };

  MedicineModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? dosage,
    String? frequency,
    String? timing,
    int? durationDays,
    DateTime? createdAt,
  }) =>
      MedicineModel(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        dosage: dosage ?? this.dosage,
        frequency: frequency ?? this.frequency,
        timing: timing ?? this.timing,
        durationDays: durationDays ?? this.durationDays,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  String toString() =>
      'MedicineModel(name: $name, dosage: $dosage, frequency: $frequency, '
      'timing: $timing, duration: $durationDays days)';
}

typedef Medicine = MedicineModel;
