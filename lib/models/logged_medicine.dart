class LoggedMedicine {
  final String medicineName;
  final String company;
  final String medicineType;
  final String oralTiming;
  final String doseUnit;
  final String insulinProfile;
  final String injectionSite;
  final String quantity;
  final String doseTime;
  final List<String> days;
  final bool takeWithFood;
  final bool checkBgBeforeDose;
  final bool overrideTargetGlucose;
  final String targetLow;
  final String targetHigh;
  final String notes;

  const LoggedMedicine({
    required this.medicineName,
    required this.company,
    required this.medicineType,
    required this.oralTiming,
    required this.doseUnit,
    required this.insulinProfile,
    required this.injectionSite,
    required this.quantity,
    required this.doseTime,
    required this.days,
    required this.takeWithFood,
    required this.checkBgBeforeDose,
    required this.overrideTargetGlucose,
    required this.targetLow,
    required this.targetHigh,
    required this.notes,
  });
}

