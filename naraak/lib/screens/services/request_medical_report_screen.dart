import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/naraak_repository.dart';
import '../../providers/clinical_data_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_top_bar.dart';

class RequestMedicalReportScreen extends StatefulWidget {
  const RequestMedicalReportScreen({super.key});
  @override
  State<RequestMedicalReportScreen> createState() =>
      _RequestMedicalReportScreenState();
}

class _RequestMedicalReportScreenState
    extends State<RequestMedicalReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reason = TextEditingController();
  String? _category;
  String? _consultantId;
  List<Map<String, dynamic>> _consultants = [];
  bool _loading = true;
  bool _submitting = false;
  String? _reference;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final provider = context.read<ClinicalDataProvider>();
    await provider.loadReports();
    if (!mounted) return;
    final categories = provider.reports.map((r) => r.category).toSet();
    if (categories.isNotEmpty) {
      _category = categories.first;
      _consultants = await provider.loadConsultants(_category!);
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
    final values =
        await context.read<ClinicalDataProvider>().loadConsultants(value);
    if (mounted)
      setState(() {
        _consultants = values;
        _loading = false;
      });
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false) || _consultantId == null)
      return;
    setState(() => _submitting = true);
    final repository = context.read<NaraakRepository>();
    final profile = context.read<UserProfileProvider>().profile;
    try {
      final response = await repository.api.requestMedicalReport(
          patientId: repository.requirePatientId,
          category: _category!,
          consultantId: _consultantId!,
          reason: _reason.text,
          contactNumber: profile?.mobileNumber ?? '');
      final data = Map<String, dynamic>.from(repository.data(response) as Map);
      if (mounted)
        setState(() => _reference = data['referenceNumber'] as String);
    } catch (error) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(repository.friendlyError(error,
                arabic:
                    Localizations.localeOf(context).languageCode == 'ar'))));
    }
    if (mounted) setState(() => _submitting = false);
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProfileProvider>().profile;
    final categories = context
        .watch<ClinicalDataProvider>()
        .reports
        .map((r) => r.category)
        .toSet()
        .toList();
    return Scaffold(
        appBar: const AppTopBar(title: 'Request a Medical Report'),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _reference != null
                ? Center(
                    child: Padding(
                        padding: const EdgeInsets.all(24),
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.check_circle,
                              size: 64, color: Colors.green),
                          const SizedBox(height: 16),
                          const Text('Request submitted',
                              style: AppTextStyles.h2),
                          Text('Reference: $_reference'),
                          const SizedBox(height: 20),
                          AppButton(
                              label: 'Back to Services',
                              onPressed: () => Navigator.pop(context))
                        ])))
                : Form(
                    key: _formKey,
                    child:
                        ListView(padding: const EdgeInsets.all(20), children: [
                      Text(profile?.fullName ?? '', style: AppTextStyles.h2),
                      Text(profile?.cpr ?? '',
                          style: AppTextStyles.bodySecondary),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                          initialValue: _category,
                          decoration: const InputDecoration(
                              labelText: 'Report category'),
                          items: categories
                              .map((v) =>
                                  DropdownMenuItem(value: v, child: Text(v)))
                              .toList(),
                          onChanged: _categoryChanged),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                          initialValue: _consultantId,
                          decoration: const InputDecoration(
                              labelText: 'Visited consultant'),
                          items: _consultants
                              .map((v) => DropdownMenuItem(
                                  value: v['consultantId'] as String,
                                  child: Text(v['consultantName'] as String)))
                              .toList(),
                          onChanged: (v) => setState(() => _consultantId = v),
                          validator: (v) =>
                              v == null ? 'Select a consultant' : null),
                      const SizedBox(height: 14),
                      TextFormField(
                          controller: _reason,
                          maxLines: 4,
                          decoration: const InputDecoration(
                              labelText: 'Reason for report'),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? 'Enter a reason'
                              : null),
                      const SizedBox(height: 24),
                      AppButton(
                          label: _submitting ? 'Submitting…' : 'Submit request',
                          onPressed: _submitting ? null : _submit)
                    ])));
  }
}
