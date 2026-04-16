class OnboardingData {
  bool? isTechProficient;
  String? diabetesType;
  String? glucoseUnit;
  String? carbsUnit;
  String? insulinTherapy;
  String? targetRangeHigh;
  String? targetRangeLow;

  OnboardingData({
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
    return 'OnboardingData(isTechProficient: $isTechProficient, diabetesType: $diabetesType, glucoseUnit: $glucoseUnit, carbsUnit: $carbsUnit, insulinTherapy: $insulinTherapy, targetRangeHigh: $targetRangeHigh, targetRangeLow: $targetRangeLow)';
  }
}
