class OnboardingData {
  String? profileId;
  bool? isTechProficient;
  String? diabetesType;
  String? glucoseUnit;
  String? carbsUnit;
  String? insulinTherapy;
  String? targetRangeHigh;
  String? targetRangeLow;

  OnboardingData({
    this.profileId,
    this.isTechProficient,
    this.diabetesType,
    this.glucoseUnit,
    this.carbsUnit,
    this.insulinTherapy,
    this.targetRangeHigh,
    this.targetRangeLow,
  });

  @override
  String toString() {
    return 'OnboardingData(profileId: $profileId, isTechProficient: $isTechProficient, diabetesType: $diabetesType, glucoseUnit: $glucoseUnit, carbsUnit: $carbsUnit, insulinTherapy: $insulinTherapy, targetRangeHigh: $targetRangeHigh, targetRangeLow: $targetRangeLow)';
  }
}
