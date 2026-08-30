import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/naraak_repository.dart';
import '../../providers/clinical_data_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/form_section.dart';
import '../../widgets/naraak_app_bar.dart';
import '../../widgets/naraak_button.dart';
import '../../widgets/progress_stepper.dart';
import '../../widgets/responsive_page_frame.dart';
import '../../widgets/state_views.dart';

class RequestMedicalReportScreen extends StatefulWidget {
  const RequestMedicalReportScreen({super.key});
  @override
  State<RequestMedicalReportScreen> createState() => _RequestMedicalReportScreenState();
}

class _RequestMedicalReportScreenState extends State<RequestMedicalReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reason = TextEditingController();
  String? _category;
  String? _consultantId;
  List<Map<String, dynamic>> _consultants = [];
  bool _loading = true;
  bool _reviewing = false;
  bool _submitting = false;
  String? _reference;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    final provider = context.read<ClinicalDataProvider>();
    await provider.loadReports();
    if (!mounted) return;
    final categories = provider.reports.map((report) => report.category).toSet();
    if (categories.isEmpty) {
      setState(() {
        _loading = false;
        _loadError = provider.errorMessage ?? 'No eligible visits were found.';
      });
      return;
    }
    _category = categories.first;
    try {
      _consultants = await provider.loadConsultants(_category!);
    } catch (error) {
      _loadError = provider.errorMessage ?? 'Could not load visited consultants.';
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _categoryChanged(String? value) async {
    if (value == null) return;
    setState(() {
      _category = value;
      _consultantId = null;
      _loading = true;
    });
    try {
      final values = await context.read<ClinicalDataProvider>().loadConsultants(value);
      if (mounted) setState(() => _consultants = values);
    } catch (_) {
      if (mounted) setState(() => _loadError = 'Could not load visited consultants.');
    }
    if (mounted) setState(() => _loading = false);
  }

  void _review() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _reviewing = true);
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final repository = context.read<NaraakRepository>();
    final profile = context.read<UserProfileProvider>().profile;
    try {
      final response = await repository.api.requestMedicalReport(
        patientId: repository.requirePatientId,
        category: _category!,
        consultantId: _consultantId!,
        reason: _reason.text.trim(),
        contactNumber: profile?.mobileNumber ?? '',
      );
      final data = Map<String, dynamic>.from(repository.data(response) as Map);
      if (mounted) setState(() => _reference = data['referenceNumber'] as String);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(repository.friendlyError(error, arabic: Localizations.localeOf(context).languageCode == 'ar'))),
        );
      }
    }
    if (mounted) setState(() => _submitting = false);
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  String _consultantName() {
    for (final consultant in _consultants) {
      if (consultant['consultantId'] == _consultantId) {
        return consultant['consultantName'] as String;
      }
    }
    return 'Not selected';
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProfileProvider>().profile;
    final categories = context.watch<ClinicalDataProvider>().reports.map((report) => report.category).toSet().toList();

    return Scaffold(
      appBar: const NaraakAppBar(title: 'Request a Medical Report'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
              ? ErrorState(title: 'Could not prepare request', message: _loadError!, actionLabel: 'Try Again', onAction: _load)
              : ResponsivePageFrame(
                  maxWidth: 820,
                  child: _reference != null
                      ? SuccessState(
                          title: 'Request submitted',
                          message: 'Your medical report request reference is ' + _reference! + '. You can track it from Pending Requests.',
                          actionLabel: 'Back to Medical Reports',
                          onAction: () => Navigator.pop(context),
                        )
                      : Form(
                          key: _formKey,
                          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                            ProgressStepper(
                              steps: const ['Details', 'Review', 'Submitted'],
                              currentStep: _reviewing ? 1 : 0,
                            ),
                            const SizedBox(height: 24),
                            if (!_reviewing)
                              FormSection(
                                title: 'Report request details',
                                description: 'Choose a previous visit and explain why the report is needed.',
                                children: [
                                  Text(profile?.fullName ?? 'Patient', style: AppTextStyles.h3),
                                  const SizedBox(height: 3),
                                  Text('CPR: ' + (profile?.cpr ?? 'Not available'), style: AppTextStyles.bodySecondary),
                                  const SizedBox(height: 18),
                                  DropdownButtonFormField<String>(
                                    initialValue: _category,
                                    decoration: const InputDecoration(labelText: 'Report category'),
                                    items: categories.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                                    onChanged: _categoryChanged,
                                    validator: (value) => value == null ? 'Select a report category' : null,
                                  ),
                                  const SizedBox(height: 14),
                                  DropdownButtonFormField<String>(
                                    initialValue: _consultantId,
                                    decoration: const InputDecoration(labelText: 'Visited consultant'),
                                    items: _consultants.map((value) => DropdownMenuItem(value: value['consultantId'] as String, child: Text(value['consultantName'] as String))).toList(),
                                    onChanged: (value) => setState(() => _consultantId = value),
                                    validator: (value) => value == null ? 'Select a consultant' : null,
                                  ),
                                  const SizedBox(height: 14),
                                  TextFormField(
                                    controller: _reason,
                                    maxLines: 4,
                                    decoration: const InputDecoration(labelText: 'Reason for report', hintText: 'Explain what the report is needed for'),
                                    validator: (value) => value == null || value.trim().isEmpty ? 'Enter a reason' : null,
                                  ),
                                  const SizedBox(height: 22),
                                  NaraakButton(label: 'Review Request', icon: Icons.arrow_forward_rounded, onPressed: _review),
                                ],
                              )
                            else
                              FormSection(
                                title: 'Review your request',
                                description: 'Confirm the details before submitting.',
                                children: [
                                  _ReviewRow(label: 'Category', value: _category!),
                                  _ReviewRow(label: 'Consultant', value: _consultantName()),
                                  _ReviewRow(label: 'Reason', value: _reason.text.trim()),
                                  _ReviewRow(label: 'Contact', value: profile?.mobileNumber ?? 'Not available'),
                                  const SizedBox(height: 18),
                                  Row(children: [
                                    Expanded(child: NaraakButton(label: 'Back', onPressed: () => setState(() => _reviewing = false))),
                                    const SizedBox(width: 12),
                                    Expanded(child: NaraakButton(label: 'Submit Request', isLoading: _submitting, onPressed: _submitting ? null : _submit)),
                                  ]),
                                ],
                              ),
                          ]),
                        ),
                ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 110, child: Text(label, style: AppTextStyles.bodySecondary)),
          Expanded(child: Text(value, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700))),
        ]),
      );
}
