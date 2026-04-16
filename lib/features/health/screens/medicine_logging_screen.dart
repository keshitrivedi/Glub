import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../onboarding/models/onboarding_data.dart';
import '../../onboarding/screens/action_selection_screen.dart';

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

class MedicineLoggingScreen extends StatefulWidget {
  final OnboardingData data;

  const MedicineLoggingScreen({super.key, required this.data});

  @override
  State<MedicineLoggingScreen> createState() => _MedicineLoggingScreenState();
}

class _MedicineLoggingScreenState extends State<MedicineLoggingScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<LoggedMedicine> _loggedMedicines = <LoggedMedicine>[];
  static const List<String> _weekdayLabels = <String>[
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  late final TextEditingController _medicineNameController;
  late final TextEditingController _companyController;
  late final TextEditingController _quantityController;
  late final TextEditingController _notesController;

  late final TextEditingController _targetLowController;
  late final TextEditingController _targetHighController;

  String _medicineType = 'Oral';
  String _oralTiming = 'Any time';
  String _doseUnit = 'mg';

  // Insulin-specific fields
  String _insulinProfile = 'Bolus';
  String _injectionSite = 'Abdomen';

  TimeOfDay? _doseTime;
  final Set<int> _selectedDays = <int>{};

  bool _takeWithFood = false;
  bool _checkBgBeforeDose = true;
  bool _overrideTargetGlucose = false;

  @override
  void initState() {
    super.initState();
    _medicineNameController = TextEditingController();
    _companyController = TextEditingController();
    _quantityController = TextEditingController(text: '1');
    _notesController = TextEditingController();

    _targetLowController =
        TextEditingController(text: widget.data.targetRangeLow ?? '');
    _targetHighController =
        TextEditingController(text: widget.data.targetRangeHigh ?? '');

    _doseTime = TimeOfDay.now();
  }

  @override
  void dispose() {
    _medicineNameController.dispose();
    _companyController.dispose();
    _quantityController.dispose();
    _notesController.dispose();
    _targetLowController.dispose();
    _targetHighController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String lowDefault = widget.data.targetRangeLow ?? '';
    final String highDefault = widget.data.targetRangeHigh ?? '';

    // Keep controllers aligned if onboarding updated earlier.
    if (lowDefault.isNotEmpty && _targetLowController.text.isEmpty) {
      _targetLowController.text = lowDefault;
    }
    if (highDefault.isNotEmpty && _targetHighController.text.isEmpty) {
      _targetHighController.text = highDefault;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 8),
              _buildHeader(),
              const SizedBox(height: 18),
              const Text(
                'Log your medicines',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.lightGreen,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildSavedMedicinesSection(),
                          if (_loggedMedicines.isNotEmpty)
                            const SizedBox(height: 18),
                          _buildTextField(
                            label: 'Medicine name',
                            controller: _medicineNameController,
                            hint: 'e.g., Metformin',
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Please enter the medicine name.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          _buildTextField(
                            label: 'Company',
                            controller: _companyController,
                            hint: 'e.g., Merck',
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Please enter the company name.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          _buildDropdownField(
                            label: 'Medication type',
                            value: _medicineType,
                            items: const ['Oral', 'Insulin', 'Other'],
                            onChanged: (v) {
                              setState(() => _medicineType = v ?? 'Oral');
                            },
                          ),
                          const SizedBox(height: 14),
                          if (_medicineType == 'Oral') ...[
                            _buildDropdownField(
                              label: 'When to take (with meals)',
                              value: _oralTiming,
                              items: const [
                                'Before meals',
                                'After meals',
                                'With meals',
                                'Any time'
                              ],
                              onChanged: (v) {
                                setState(() => _oralTiming = v ?? 'Any time');
                              },
                            ),
                            const SizedBox(height: 14),
                          ],
                          if (_medicineType == 'Insulin') ...[
                            _buildDropdownField(
                              label: 'Insulin profile',
                              value: _insulinProfile,
                              items: const ['Basal', 'Bolus', 'Premixed'],
                              onChanged: (v) {
                                setState(() => _insulinProfile = v ?? 'Bolus');
                              },
                            ),
                            const SizedBox(height: 14),
                            _buildDropdownField(
                              label: 'Injection site',
                              value: _injectionSite,
                              items: const [
                                'Abdomen',
                                'Thigh',
                                'Arm',
                                'Other'
                              ],
                              onChanged: (v) {
                                setState(() => _injectionSite = v ?? 'Abdomen');
                              },
                            ),
                            const SizedBox(height: 14),
                          ],

                          const Divider(height: 26),

                          _buildDoseRow(),
                          const SizedBox(height: 14),

                          _buildTimePickerField(),
                          const SizedBox(height: 14),

                          _buildDaysOfWeekSelector(),
                          const SizedBox(height: 18),

                          _buildToggles(),
                          const SizedBox(height: 14),

                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  enabled: _overrideTargetGlucose,
                                  controller: _targetLowController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Target glucose low',
                                    hintText: widget.data.glucoseUnit != null
                                        ? 'e.g., ${widget.data.targetRangeLow}'
                                        : 'Optional',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  enabled: _overrideTargetGlucose,
                                  controller: _targetHighController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Target glucose high',
                                    hintText: widget.data.glucoseUnit != null
                                        ? 'e.g., ${widget.data.targetRangeHigh}'
                                        : 'Optional',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),
                          _buildCheckbox(
                            value: _overrideTargetGlucose,
                            onChanged: (v) =>
                                setState(() => _overrideTargetGlucose = v ?? false),
                            label: 'Override target glucose range',
                          ),

                          const SizedBox(height: 14),
                          _buildTextField(
                            label: 'Notes / instructions',
                            controller: _notesController,
                            hint: 'Any extra notes (e.g. before workout)',
                            maxLines: 3,
                          ),

                          const SizedBox(height: 18),
                          _buildBottomActions(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSavedMedicinesSection() {
    if (_loggedMedicines.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.textDark.withValues(alpha: 20),
          ),
        ),
        child: const Text(
          'No medicines added yet. Fill the form below, then tap "Add another medicine" to build your list.',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Text(
              'Added medicines',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const Spacer(),
            Text(
              '${_loggedMedicines.length} added',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textDark.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...List.generate(_loggedMedicines.length, (index) {
          final medicine = _loggedMedicines[index];
          return Container(
            margin: EdgeInsets.only(bottom: index == _loggedMedicines.length - 1 ? 0 : 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medicine.medicineName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${medicine.company} • ${medicine.quantity} ${medicine.doseUnit} • ${medicine.doseTime}',
                        style: TextStyle(
                          color: AppColors.textDark.withValues(alpha: 0.75),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        medicine.days.join(', '),
                        style: TextStyle(
                          color: AppColors.textDark.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _loggedMedicines.removeAt(index);
                    });
                  },
                  icon: const Icon(Icons.delete_outline),
                  color: AppColors.textDark,
                  tooltip: 'Remove medicine',
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        const Expanded(
          child: Center(
            child: Text(
              'Glub',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: items.map((e) {
        return DropdownMenuItem<String>(value: e, child: Text(e));
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDoseRow() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'How many (quantity)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
            validator: (v) {
              final parsed = int.tryParse(v?.trim() ?? '');
              if (parsed == null || parsed <= 0) {
                return 'Enter a quantity greater than 0.';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<String>(
            initialValue: _doseUnit,
            decoration: const InputDecoration(
              labelText: 'Dose unit',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
            ),
            items: const ['mg', 'units', 'mL'].map((e) {
              return DropdownMenuItem<String>(value: e, child: Text(e));
            }).toList(),
            onChanged: (v) {
              if (v == null) return;
              setState(() => _doseUnit = v);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimePickerField() {
    final String display =
        _doseTime == null ? '--:--' : _doseTime!.format(context);

    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: _doseTime ?? TimeOfDay.now(),
        );
        if (picked != null) setState(() => _doseTime = picked);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.inputBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.textDark.withValues(alpha: 38),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: AppColors.textDark),
            const SizedBox(width: 12),
            Text(
              'Time: $display',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const Spacer(),
            const Icon(Icons.edit, color: AppColors.textDark),
          ],
        ),
      ),
    );
  }

  Widget _buildDaysOfWeekSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Days of the week',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: List.generate(_weekdayLabels.length, (index) {
            final selected = _selectedDays.contains(index);
            return InkWell(
              onTap: () {
                setState(() {
                  if (selected) {
                    _selectedDays.remove(index);
                  } else {
                    _selectedDays.add(index);
                  }
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 52,
                height: 42,
                decoration: BoxDecoration(
                  color: selected ? AppColors.inputBackground : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected
                        ? AppColors.primaryGreen
                        : AppColors.textDark.withValues(alpha: 51),
                  ),
                ),
                child: Center(
                  child: Text(
                    _weekdayLabels[index],
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: selected ? AppColors.primaryGreen : AppColors.textDark,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildToggles() {
    return Column(
      children: [
        _buildCheckbox(
          value: _takeWithFood,
          onChanged: (v) => setState(() => _takeWithFood = v ?? false),
          label: 'Take with food',
        ),
        _buildCheckbox(
          value: _checkBgBeforeDose,
          onChanged: (v) =>
              setState(() => _checkBgBeforeDose = v ?? false),
          label: 'Check blood sugar before dose',
        ),
      ],
    );
  }

  Widget _buildCheckbox({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String label,
  }) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      value: value,
      onChanged: onChanged,
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
      ),
      activeColor: AppColors.primaryGreen,
      dense: true,
    );
  }

  LoggedMedicine _buildLoggedMedicine(BuildContext context) {
    final selectedDayLabels = _selectedDays.toList()
      ..sort();

    return LoggedMedicine(
      medicineName: _medicineNameController.text.trim(),
      company: _companyController.text.trim(),
      medicineType: _medicineType,
      oralTiming: _oralTiming,
      doseUnit: _doseUnit,
      insulinProfile: _insulinProfile,
      injectionSite: _injectionSite,
      quantity: _quantityController.text.trim(),
      doseTime: (_doseTime ?? TimeOfDay.now()).format(context),
      days: selectedDayLabels.map((i) => _weekdayLabels[i]).toList(),
      takeWithFood: _takeWithFood,
      checkBgBeforeDose: _checkBgBeforeDose,
      overrideTargetGlucose: _overrideTargetGlucose,
      targetLow: _targetLowController.text.trim(),
      targetHigh: _targetHighController.text.trim(),
      notes: _notesController.text.trim(),
    );
  }

  bool _validateMedicineForm() {
    final formOk = _formKey.currentState?.validate() ?? false;
    if (!formOk) return false;

    if (_doseTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time.')),
      );
      return false;
    }
    if (_selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one day.')),
      );
      return false;
    }
    return true;
  }

  void _resetFormForNextMedicine() {
    _medicineNameController.clear();
    _companyController.clear();
    _quantityController.text = '1';
    _notesController.clear();
    _targetLowController.text = widget.data.targetRangeLow ?? '';
    _targetHighController.text = widget.data.targetRangeHigh ?? '';
    _medicineType = 'Oral';
    _oralTiming = 'Any time';
    _doseUnit = 'mg';
    _insulinProfile = 'Bolus';
    _injectionSite = 'Abdomen';
    _doseTime = TimeOfDay.now();
    _selectedDays.clear();
    _takeWithFood = false;
    _checkBgBeforeDose = true;
    _overrideTargetGlucose = false;
    _formKey.currentState?.reset();
  }

  void _addAnotherMedicine() {
    if (!_validateMedicineForm()) return;

    final medicine = _buildLoggedMedicine(context);
    setState(() {
      _loggedMedicines.add(medicine);
      _resetFormForNextMedicine();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${medicine.medicineName} added to the list.')),
    );
  }

  void _saveAndContinue() {
    if (_medicineNameController.text.trim().isNotEmpty ||
        _companyController.text.trim().isNotEmpty ||
        _selectedDays.isNotEmpty) {
      if (!_validateMedicineForm()) return;
      final medicine = _buildLoggedMedicine(context);
      setState(() {
        _loggedMedicines.add(medicine);
        _resetFormForNextMedicine();
      });
    } else if (_loggedMedicines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add at least one medicine before continuing.'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Saved ${_loggedMedicines.length} medicine${_loggedMedicines.length == 1 ? '' : 's'}.',
        ),
      ),
    );

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => ActionSelectionScreen(data: widget.data),
      ),
      (route) => false,
    );
  }

  Widget _buildBottomActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => ActionSelectionScreen(data: widget.data),
              ),
              (route) => false,
            );
          },
          child: const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '< Back to actions',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 52,
          child: OutlinedButton.icon(
            onPressed: _addAnotherMedicine,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryGreen,
              side: const BorderSide(color: AppColors.primaryGreen),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            icon: const Icon(Icons.add),
            label: const Text(
              'Add another medicine',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            onPressed: _saveAndContinue,
            child: const Text(
              'Save medicines',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}

