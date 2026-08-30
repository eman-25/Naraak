import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/naraak_repository.dart';
import '../../providers/clinical_data_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/form_section.dart';
import '../../widgets/naraak_app_bar.dart';
import '../../widgets/naraak_button.dart';
import '../../widgets/progress_stepper.dart';
import '../../widgets/responsive_page_frame.dart';
import '../../widgets/state_views.dart';

/// Phase 3 §20: Category → Consultant → Details → Review. Category is a
/// fixed specialty grid (not derived from the patient's report history —
/// that would hide specialties they haven't visited yet), Consultant is a
/// dedicated searchable screen sourced from real visits (never free text).
class RequestMedicalReportScreen extends StatefulWidget {
  const RequestMedicalReportScreen({super.key});
  @override
  State<RequestMedicalReportScreen> createState() =>
      _RequestMedicalReportScreenState();
}

const _categories = [
  ('General Clinic', Icons.local_hospital_rounded),
  ('Dental', Icons.medical_information_rounded),
  ('Cardiology', Icons.favorite_rounded),
  ('Orthopedics', Icons.personal_injury_rounded),
  ('Dermatology', Icons.spa_rounded),
  ('ENT', Icons.hearing_rounded),
];

class _RequestMedicalReportScreenState
    extends State<RequestMedicalReportScreen> {
  int _step = 0; // 0 category, 1 consultant, 2 details, 3 review
  final _reason = TextEditingController();
  late final TextEditingController _contact;
  String? _category;
  String? _consultantId;
  List<Map<String, dynamic>> _consultants = [];
  bool _loadingConsultants = false;
  bool _submitting = false;
  String? _reference;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    final profile = context.read<UserProfileProvider>().profile;
    _contact = TextEditingController(text: profile?.mobileNumber ?? '');
  }

  Future<void> _selectCategory(String category) async {
    setState(() {
      _category = category;
      _consultantId = null;
      _loadingConsultants = true;
      _loadError = null;
      _step = 1;
    });
    try {
      final values =
          await context.read<ClinicalDataProvider>().loadConsultants(category);
      if (mounted) setState(() => _consultants = values);
    } catch (_) {
      if (mounted) {
        setState(() => _loadError = 'Could not load visited consultants.');
      }
    }
    if (mounted) setState(() => _loadingConsultants = false);
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    final repository = context.read<NaraakRepository>();
    try {
      final response = await repository.api.requestMedicalReport(
        patientId: repository.requirePatientId,
        category: _category!,
        consultantId: _consultantId!,
        reason: _reason.text.trim(),
        contactNumber: _contact.text.trim(),
      );
      final data = Map<String, dynamic>.from(repository.data(response) as Map);
      if (mounted) setState(() => _reference = data['referenceNumber'] as String);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(repository.friendlyError(error,
                arabic: Localizations.localeOf(context).languageCode == 'ar')),
          ),
        );
      }
    }
    if (mounted) setState(() => _submitting = false);
  }

  @override
  void dispose() {
    _reason.dispose();
    _contact.dispose();
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

  void _handleBack() {
    if (_step == 0) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _step -= 1);
  }

  bool get _hasUnsavedChanges => _reference == null && _step > 0;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final leave = await confirmUnsavedChanges(context);
        if (leave && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
      appBar: NaraakAppBar(
        title: 'Request a Medical Report',
        onBack: _reference == null ? _handleBack : null,
      ),
      body: ResponsivePageFrame(
        maxWidth: 820,
        child: _reference != null
            ? SuccessState(
                title: 'Request submitted',
                message:
                    'Your medical report request reference is $_reference. You can track it from Pending Requests.',
                actionLabel: 'Back to Medical Reports',
                onAction: () => Navigator.pop(context),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ProgressStepper(
                    steps: const ['Category', 'Consultant', 'Details', 'Review'],
                    currentStep: _step,
                  ),
                  const SizedBox(height: 24),
                  switch (_step) {
                    0 => _CategoryStep(onSelected: _selectCategory),
                    1 => _ConsultantStep(
                        loading: _loadingConsultants,
                        error: _loadError,
                        consultants: _consultants,
                        selectedId: _consultantId,
                        onRetry: () => _selectCategory(_category!),
                        onSelected: (id) => setState(() {
                          _consultantId = id;
                          _step = 2;
                        }),
                      ),
                    2 => _DetailsStep(
                        reasonController: _reason,
                        contactController: _contact,
                        onNext: () {
                          if (_reason.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Enter a reason for the report.')),
                            );
                            return;
                          }
                          setState(() => _step = 3);
                        },
                      ),
                    _ => FormSection(
                        title: 'Review your request',
                        description: 'Confirm the details before submitting.',
                        children: [
                          _ReviewRow(label: 'Category', value: _category ?? '—'),
                          _ReviewRow(
                              label: 'Consultant', value: _consultantName()),
                          _ReviewRow(
                              label: 'Reason', value: _reason.text.trim()),
                          _ReviewRow(
                              label: 'Contact', value: _contact.text.trim()),
                          const SizedBox(height: 18),
                          Row(children: [
                            Expanded(
                              child: NaraakButton(
                                label: 'Back',
                                onPressed: () => setState(() => _step = 2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: NaraakButton(
                                label: 'Submit Request',
                                isLoading: _submitting,
                                onPressed: _submitting ? null : _submit,
                              ),
                            ),
                          ]),
                        ],
                      ),
                  },
                ],
              ),
      ),
      ),
    );
  }
}

class _CategoryStep extends StatelessWidget {
  final ValueChanged<String> onSelected;
  const _CategoryStep({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FormSection(
      title: 'Select category / specialty',
      description: 'Choose the specialty for your medical report.',
      children: [
        LayoutBuilder(builder: (context, constraints) {
          final columns = constraints.maxWidth > 560 ? 3 : 2;
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _categories.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.05,
            ),
            itemBuilder: (context, i) {
              final (name, icon) = _categories[i];
              return InkWell(
                onTap: () => onSelected(name),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface2 : AppColors.ink050,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color:
                            isDark ? AppColors.darkOutline : AppColors.outline),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primaryTeal
                              .withValues(alpha: isDark ? 0.22 : 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: AppColors.primaryTeal, size: 22),
                      ),
                      const SizedBox(height: 10),
                      Text(name,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body
                              .copyWith(fontWeight: FontWeight.w700, fontSize: 12.5)),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }
}

class _ConsultantStep extends StatefulWidget {
  final bool loading;
  final String? error;
  final List<Map<String, dynamic>> consultants;
  final String? selectedId;
  final VoidCallback onRetry;
  final ValueChanged<String> onSelected;
  const _ConsultantStep({
    required this.loading,
    required this.error,
    required this.consultants,
    required this.selectedId,
    required this.onRetry,
    required this.onSelected,
  });

  @override
  State<_ConsultantStep> createState() => _ConsultantStepState();
}

class _ConsultantStepState extends State<_ConsultantStep> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (widget.loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (widget.error != null) {
      return ErrorState(
        title: 'Could not load consultants',
        message: widget.error!,
        actionLabel: 'Retry',
        onAction: widget.onRetry,
      );
    }
    final filtered = widget.consultants
        .where((c) => (c['consultantName'] as String)
            .toLowerCase()
            .contains(_query.toLowerCase()))
        .toList();

    return FormSection(
      title: 'Select consultant',
      description: 'Only consultants from your previous visits are shown.',
      children: [
        TextField(
          onChanged: (v) => setState(() => _query = v),
          decoration: InputDecoration(
            hintText: 'Search consultant...',
            prefixIcon: const Icon(Icons.search_rounded, size: 20),
            filled: true,
            fillColor: isDark ? AppColors.darkSurface2 : AppColors.ink050,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 14),
        if (filtered.isEmpty)
          const EmptyState(
            title: 'No consultants found',
            message:
                'You have not visited a consultant in this specialty yet.',
          )
        else
          for (final consultant in filtered)
            _ConsultantTile(
              name: consultant['consultantName'] as String,
              gender: consultant['gender'] as String? ?? '',
              selected: consultant['consultantId'] == widget.selectedId,
              onTap: () =>
                  widget.onSelected(consultant['consultantId'] as String),
            ),
      ],
    );
  }
}

class _ConsultantTile extends StatelessWidget {
  final String name;
  final String gender;
  final bool selected;
  final VoidCallback onTap;
  const _ConsultantTile({
    required this.name,
    required this.gender,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            color: selected
                ? AppColors.primaryTeal.withValues(alpha: isDark ? 0.2 : 0.08)
                : (isDark ? AppColors.darkSurface2 : Colors.white),
            border: Border.all(
              color: selected
                  ? AppColors.primaryTeal
                  : (isDark ? AppColors.darkOutline : AppColors.outline),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor:
                    AppColors.primaryTeal.withValues(alpha: isDark ? 0.24 : 0.12),
                child: Icon(
                  gender.toLowerCase() == 'female'
                      ? Icons.face_3_rounded
                      : Icons.face_6_rounded,
                  size: 18,
                  color: AppColors.primaryTeal,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(name,
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
              ),
              Icon(
                selected ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
                color: selected ? AppColors.primaryTeal : AppColors.ink300,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailsStep extends StatelessWidget {
  final TextEditingController reasonController;
  final TextEditingController contactController;
  final VoidCallback onNext;
  const _DetailsStep({
    required this.reasonController,
    required this.contactController,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return FormSection(
      title: 'Request details',
      description: 'Tell us why the report is needed and where to reach you.',
      children: [
        TextField(
          controller: reasonController,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Reason for report',
            hintText: 'Explain what the report is needed for',
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: contactController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(labelText: 'Contact number'),
        ),
        const SizedBox(height: 22),
        NaraakButton(
            label: 'Review Request',
            icon: Icons.arrow_forward_rounded,
            onPressed: onNext),
      ],
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
