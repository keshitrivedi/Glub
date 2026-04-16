import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../models/medicine_model.dart';
import '../../../services/ocr_service.dart';
import '../../../services/prescription_parser.dart';

enum _ScanState { idle, scanning, parsing, confirming, saving }

class PrescriptionScannerScreen extends StatefulWidget {
  const PrescriptionScannerScreen({super.key});

  @override
  State<PrescriptionScannerScreen> createState() =>
      _PrescriptionScannerScreenState();
}

class _PrescriptionScannerScreenState extends State<PrescriptionScannerScreen> {
  final OcrService _ocrService = OcrService();
  final PrescriptionParser _parser = PrescriptionParser();
  final SupabaseClient _supabase = Supabase.instance.client;

  _ScanState _state = _ScanState.idle;
  String? _rawOcrText;
  String? _errorMessage;
  ParsedPrescription? _parsed;
  final List<_MedicineFormControllers> _controllers = [];

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    _ocrService.dispose();
    super.dispose();
  }

  Future<void> _startScan({required bool fromCamera}) async {
    setState(() {
      _state = _ScanState.scanning;
      _errorMessage = null;
    });

    final ocrResult =
        await _ocrService.scanPrescription(fromCamera: fromCamera);

    if (!ocrResult.success) {
      _handleError(ocrResult.error ?? 'Unknown scan error');
      return;
    }

    setState(() => _state = _ScanState.parsing);
    _rawOcrText = ocrResult.text;

    final parsed = _parser.parse(_rawOcrText!);

    if (!parsed.parsedSuccessfully) {
      for (final controller in _controllers) {
        controller.dispose();
      }

      setState(() {
        _state = _ScanState.confirming;
        _parsed = parsed;
        _controllers.clear();
        _addBlankController();
      });
      return;
    }

    _buildControllersFrom(parsed.medicines);
    setState(() {
      _state = _ScanState.confirming;
      _parsed = parsed;
    });
  }

  void _buildControllersFrom(List<ParsedMedicine> medicines) {
    for (final controller in _controllers) {
      controller.dispose();
    }
    _controllers
      ..clear()
      ..addAll(medicines.map(_MedicineFormControllers.fromParsed));
  }

  void _addBlankController() {
    _controllers.add(_MedicineFormControllers.blank());
  }

  void _removeController(int index) {
    _controllers[index].dispose();
    setState(() => _controllers.removeAt(index));
  }

  Future<void> _saveToSupabase() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      _handleError('You must be logged in to save medicines.');
      return;
    }

    setState(() => _state = _ScanState.saving);

    try {
      final rows = _controllers
          .where((c) => c.nameController.text.trim().isNotEmpty)
          .map((c) => c.toMedicineModel(user.id).toJson())
          .toList();

      if (rows.isEmpty) {
        _handleError('Please enter at least one medicine name.');
        return;
      }

      await _supabase.from('medicines').insert(rows);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${rows.length} medicine(s) saved successfully!'),
          backgroundColor: Colors.green.shade700,
        ),
      );
      Navigator.of(context).pop(true);
    } on PostgrestException catch (e) {
      _handleError('Database error: ${e.message}');
    } catch (e) {
      _handleError('Save failed: $e');
    }
  }

  void _handleError(String message) {
    setState(() {
      _state = _ScanState.idle;
      _errorMessage = message;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        action: const SnackBarAction(
          label: 'Settings',
          onPressed: openAppSettings,
          textColor: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        title: const Text(
          'Scan Prescription',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        elevation: 0,
      ),
      body: _buildBody(),
      bottomNavigationBar:
          _state == _ScanState.confirming ? _buildBottomBar() : null,
    );
  }

  Widget _buildBody() {
    switch (_state) {
      case _ScanState.idle:
        return _buildIdleView();
      case _ScanState.scanning:
      case _ScanState.parsing:
        return _buildLoadingView();
      case _ScanState.confirming:
        return _buildConfirmationView();
      case _ScanState.saving:
        return _buildLoadingView(label: 'Saving medicines...');
    }
  }

  Widget _buildIdleView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDisclaimerCard(),
          const SizedBox(height: 32),
          _ScanOptionButton(
            icon: Icons.camera_alt_rounded,
            label: 'Take a Photo',
            subtitle: 'Use your camera to scan',
            onTap: () => _startScan(fromCamera: true),
          ),
          const SizedBox(height: 16),
          _ScanOptionButton(
            icon: Icons.photo_library_rounded,
            label: 'Choose from Gallery',
            subtitle: 'Pick an existing photo',
            onTap: () => _startScan(fromCamera: false),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDisclaimerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFCC02), width: 1.5),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFE65100),
            size: 28,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'This is an AI-assisted scan. Always verify with the actual prescription and consult your doctor.',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF5D4037),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingView({String label = 'Scanning...'}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFF1565C0),
            strokeWidth: 3,
          ),
          const SizedBox(height: 20),
          Text(
            label,
            style: const TextStyle(fontSize: 18, color: Color(0xFF1565C0)),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationView() {
    final parseSucceeded = _parsed?.parsedSuccessfully ?? false;
    final confidence = _parsed?.overallConfidence ?? 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDisclaimerCard(),
          const SizedBox(height: 16),
          if (parseSucceeded) _ConfidenceBanner(confidence: confidence),
          if (!parseSucceeded && _rawOcrText != null) ...[
            const SizedBox(height: 8),
            _RawOcrCard(text: _rawOcrText!),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Medicines Detected',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: () => setState(_addBlankController),
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ..._controllers.asMap().entries.map((entry) {
            final idx = entry.key;
            final controller = entry.value;
            return _MedicineEditCard(
              key: ValueKey(idx),
              controllers: controller,
              index: idx,
              onRemove: () => _removeController(idx),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1565C0),
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          onPressed: _saveToSupabase,
          child: const Text('Save Medicines'),
        ),
      ),
    );
  }
}

class _MedicineFormControllers {
  final TextEditingController nameController;
  final TextEditingController dosageController;
  final TextEditingController frequencyController;
  final TextEditingController timingController;
  final TextEditingController durationController;

  _MedicineFormControllers({
    required this.nameController,
    required this.dosageController,
    required this.frequencyController,
    required this.timingController,
    required this.durationController,
  });

  factory _MedicineFormControllers.fromParsed(ParsedMedicine medicine) =>
      _MedicineFormControllers(
        nameController: TextEditingController(text: medicine.name),
        dosageController: TextEditingController(text: medicine.dosage ?? ''),
        frequencyController:
            TextEditingController(text: medicine.frequency ?? ''),
        timingController: TextEditingController(text: medicine.timing ?? ''),
        durationController: TextEditingController(
          text: medicine.durationDays != null ? '${medicine.durationDays}' : '',
        ),
      );

  factory _MedicineFormControllers.blank() => _MedicineFormControllers(
        nameController: TextEditingController(),
        dosageController: TextEditingController(),
        frequencyController: TextEditingController(),
        timingController: TextEditingController(),
        durationController: TextEditingController(),
      );

  MedicineModel toMedicineModel(String userId) => MedicineModel(
        userId: userId,
        name: nameController.text.trim(),
        dosage: dosageController.text.trim().isEmpty
            ? null
            : dosageController.text.trim(),
        frequency: frequencyController.text.trim().isEmpty
            ? null
            : frequencyController.text.trim(),
        timing: timingController.text.trim().isEmpty
            ? null
            : timingController.text.trim(),
        durationDays: int.tryParse(durationController.text.trim()),
      );

  void dispose() {
    nameController.dispose();
    dosageController.dispose();
    frequencyController.dispose();
    timingController.dispose();
    durationController.dispose();
  }
}

class _ScanOptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _ScanOptionButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF1565C0), size: 32),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _ConfidenceBanner extends StatelessWidget {
  final double confidence;

  const _ConfidenceBanner({required this.confidence});

  @override
  Widget build(BuildContext context) {
    final pct = (confidence * 100).round();
    final color = confidence >= 0.7
        ? Colors.green.shade600
        : confidence >= 0.4
            ? Colors.orange.shade700
            : Colors.red.shade600;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.analytics_outlined, color: color, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Parse confidence: $pct%',
              style: TextStyle(
                fontSize: 15,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              width: 80,
              height: 8,
              child: LinearProgressIndicator(
                value: confidence,
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RawOcrCard extends StatefulWidget {
  final String text;

  const _RawOcrCard({required this.text});

  @override
  State<_RawOcrCard> createState() => _RawOcrCardState();
}

class _RawOcrCardState extends State<_RawOcrCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5F5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFCE93D8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.text_snippet_outlined,
                color: Color(0xFF7B1FA2),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Raw OCR Text (auto-parse failed)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7B1FA2),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _expanded = !_expanded),
                child: Text(_expanded ? 'Hide' : 'Show'),
              ),
            ],
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SelectableText(
                widget.text,
                style: const TextStyle(fontSize: 13, height: 1.6),
              ),
            ),
        ],
      ),
    );
  }
}

class _MedicineEditCard extends StatelessWidget {
  final _MedicineFormControllers controllers;
  final int index;
  final VoidCallback onRemove;

  const _MedicineEditCard({
    super.key,
    required this.controllers,
    required this.index,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Medicine ${index + 1}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1565C0),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 22,
                  ),
                  tooltip: 'Remove',
                  onPressed: onRemove,
                ),
              ],
            ),
            const Divider(height: 8),
            const SizedBox(height: 4),
            _Field(
              label: 'Medicine Name *',
              controller: controllers.nameController,
              hint: 'e.g. Metformin',
              isRequired: true,
            ),
            _Field(
              label: 'Dosage',
              controller: controllers.dosageController,
              hint: 'e.g. 500 mg',
            ),
            _Field(
              label: 'Frequency',
              controller: controllers.frequencyController,
              hint: 'e.g. Twice daily',
            ),
            _Field(
              label: 'Timing',
              controller: controllers.timingController,
              hint: 'e.g. After food',
            ),
            _Field(
              label: 'Duration (days)',
              controller: controllers.durationController,
              hint: 'e.g. 7',
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final bool isRequired;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const _Field({
    required this.label,
    required this.controller,
    required this.hint,
    this.isRequired = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.grey),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Color(0xFF1565C0),
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            validator: isRequired
                ? (value) => (value == null || value.trim().isEmpty)
                    ? 'Name is required'
                    : null
                : null,
          ),
        ],
      ),
    );
  }
}
