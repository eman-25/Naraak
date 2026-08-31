import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../data/naraak_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_button.dart' show AppButtonVariant;
import '../../widgets/naraak_card.dart';
import '../../widgets/naraak_button.dart';
import '../../widgets/naraak_app_bar.dart';
import '../../widgets/responsive_page_frame.dart';
import '../../widgets/service_hero.dart';

class PhcResearchApplicationScreen extends StatefulWidget {
  const PhcResearchApplicationScreen({super.key});

  @override
  State<PhcResearchApplicationScreen> createState() => _PhcResearchApplicationScreenState();
}

class _PhcResearchApplicationScreenState extends State<PhcResearchApplicationScreen> {
  int _currentStep = 1;

  // Step 1: Applicant State — Phase 3 §30: Student | Employee | Delegate.
  String _selectedRole = 'Student';
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _institutionController;

  // Step 2: Supervisor State
  final TextEditingController _supervisorNameController = TextEditingController();
  final TextEditingController _supervisorEmailController = TextEditingController();
  final TextEditingController _supervisorPhoneController = TextEditingController();

  // Step 3: Research State
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _objectiveController = TextEditingController();
  String? _selectedHealthCenter;
  final TextEditingController _durationController = TextEditingController();
  String? _selectedStudyType;

  // Step 4: Documents State
  String? _proposalFileName;
  String? _ethicsFileName;
  String? _toolsFileName;
  String? _supportingFileName;

  // Step 5: Review / Consent State
  bool _isConfirmed = false;
  bool _isSubmitted = false;
  bool _isSubmitting = false;

  final List<String> _healthCenters = [
    'Naim Health Center',
    'Hoora Health Center',
    'Bilad Al Qadeem Health Center',
    'Juffair Health Center',
    'Sitra Health Center',
    'All Primary Care Centers',
  ];

  final List<String> _studyTypes = [
    'Observational Study',
    'Clinical Trial / Interventional',
    'Cross-Sectional Survey',
    'Retrospective Data Analysis',
    'Qualitative Study',
  ];

  @override
  void initState() {
    super.initState();
    final profile = context.read<UserProfileProvider>().profile;
    _emailController = TextEditingController(text: 'eman.alkhalifa@gmail.com');
    _phoneController =
        TextEditingController(text: profile?.mobileNumber ?? '+973 39912345');
    _institutionController =
        TextEditingController(text: 'University of Bahrain');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _institutionController.dispose();
    _supervisorNameController.dispose();
    _supervisorEmailController.dispose();
    _supervisorPhoneController.dispose();
    _titleController.dispose();
    _objectiveController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NaraakAppBar(title: 'Research Application'),
      body: ResponsivePageFrame(
        maxWidth: 900,
        child: _isSubmitted
            ? _buildSuccessCard()
            : Column(
                children: [
                  const ServiceHero(
                    imageAsset:
                        'assets/images/Primary healthcare research applications.jpg',
                    icon: Icons.biotech_rounded,
                    accent: Color(0xFF7C6FE0),
                    title: 'PHC Research Application',
                    description:
                        'Apply to conduct research studies at PHC centers.',
                  ),
                  const SizedBox(height: 20),
                  _buildStepperHeader(),
                  const SizedBox(height: 16),
                  if (_currentStep == 1) _buildStepOne(),
                  if (_currentStep == 2) _buildStepSupervisor(),
                  if (_currentStep == 3) _buildStepTwo(),
                  if (_currentStep == 4) _buildStepThree(),
                  if (_currentStep == 5) _buildStepReview(),
                ],
              ),
      ),
    );
  }

  // --- STEP 1: Applicant Details ---
  Widget _buildStepOne() {
    return Column(
      children: [
        // Role Switcher Toggle
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.secondaryIce,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(child: _buildRoleTab('Student')),
              Expanded(child: _buildRoleTab('Employee')),
              Expanded(child: _buildRoleTab('Delegate')),
            ],
          ),
        ),
        const SizedBox(height: 16),

        NaraakCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Applicant Type', style: AppTextStyles.caption),
              const SizedBox(height: 4),
              _buildReadOnlyField(_selectedRole),
              const SizedBox(height: 16),
              const Text('Reference Number', style: AppTextStyles.caption),
              const SizedBox(height: 4),
              _buildReadOnlyField('NRK-RES-2026-088'),
              const SizedBox(height: 16),
              const Text('Email *', style: AppTextStyles.caption),
              const SizedBox(height: 4),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              const Text('Mobile Number *', style: AppTextStyles.caption),
              const SizedBox(height: 4),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              const Text('Institution Name *', style: AppTextStyles.caption),
              const SizedBox(height: 4),
              TextFormField(
                controller: _institutionController,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: NaraakButton(
            label: 'Next',
            onPressed: () => setState(() => _currentStep = 2),
          ),
        ),
      ],
    );
  }

  // --- STEP 2: Supervisor Details ---
  Widget _buildStepSupervisor() {
    return Column(
      children: [
        NaraakCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Supervisor Name *', style: AppTextStyles.caption),
              const SizedBox(height: 4),
              TextFormField(
                controller: _supervisorNameController,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              const Text('Supervisor Email *', style: AppTextStyles.caption),
              const SizedBox(height: 4),
              TextFormField(
                controller: _supervisorEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              const Text('Supervisor Phone *', style: AppTextStyles.caption),
              const SizedBox(height: 4),
              TextFormField(
                controller: _supervisorPhoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: NaraakButton(
                label: 'Back',
                variant: AppButtonVariant.secondary,
                onPressed: () => setState(() => _currentStep = 1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: NaraakButton(
                label: 'Next',
                onPressed: () => setState(() => _currentStep = 3),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- STEP 3: Research Details ---
  Widget _buildStepTwo() {
    return Column(
      children: [
        NaraakCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Research Title *', style: AppTextStyles.caption),
              const SizedBox(height: 4),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Enter research title...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Research Objective *', style: AppTextStyles.caption),
              const SizedBox(height: 4),
              TextFormField(
                controller: _objectiveController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText:
                      'Describe the objectives of your scientific study...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Target Health Centers *',
                  style: AppTextStyles.caption),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                value: _selectedHealthCenter,
                hint: const Text('Select Health Centers'),
                items: _healthCenters
                    .map((center) =>
                        DropdownMenuItem(value: center, child: Text(center)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedHealthCenter = val),
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              const Text('Expected Duration (Months) *',
                  style: AppTextStyles.caption),
              const SizedBox(height: 4),
              TextFormField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'e.g. 6',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Study Type *', style: AppTextStyles.caption),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                value: _selectedStudyType,
                hint: const Text('Select Study Type'),
                items: _studyTypes
                    .map((type) =>
                        DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedStudyType = val),
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: NaraakButton(
                label: 'Back',
                variant: AppButtonVariant.secondary,
                onPressed: () => setState(() => _currentStep = 2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: NaraakButton(
                label: 'Next',
                onPressed: () => setState(() => _currentStep = 4),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- STEP 3: Documents ---
  Widget _buildStepThree() {
    return Column(
      children: [
        NaraakCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUploadBox(
                label: 'Research Proposal *',
                sublabel: 'PDF (Max 10MB)',
                fileName: _proposalFileName,
                onTap: () =>
                    setState(() => _proposalFileName = 'Research_Proposal.pdf'),
              ),
              const SizedBox(height: 16),
              _buildUploadBox(
                label: 'Ethics Approval *',
                sublabel: 'PDF (Max 5MB)',
                fileName: _ethicsFileName,
                onTap: () =>
                    setState(() => _ethicsFileName = 'Ethics_Approval.pdf'),
              ),
              const SizedBox(height: 16),
              _buildUploadBox(
                label: 'Data Collection Tools',
                sublabel: 'PDF, DOCX (Max 5MB)',
                fileName: _toolsFileName,
                onTap: () =>
                    setState(() => _toolsFileName = 'Survey_Form.docx'),
              ),
              const SizedBox(height: 16),
              _buildUploadBox(
                label: 'Supporting Documents',
                sublabel: 'Any Format (Max 10MB)',
                fileName: _supportingFileName,
                onTap: () =>
                    setState(() => _supportingFileName = 'Support_Letter.pdf'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: NaraakButton(
                label: 'Back',
                variant: AppButtonVariant.secondary,
                onPressed: () => setState(() => _currentStep = 3),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: NaraakButton(
                label: 'Next',
                onPressed: () => setState(() => _currentStep = 5),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- STEP 5: Review & Consent ---
  Widget _buildStepReview() {
    return Column(
      children: [
        NaraakCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Review your application', style: AppTextStyles.h3),
              const SizedBox(height: 4),
              Text('Confirm the details before submitting.',
                  style: AppTextStyles.bodySecondary),
              const SizedBox(height: 16),
              _reviewRow('Applicant Type', _selectedRole),
              _reviewRow('Institution', _institutionController.text),
              _reviewRow('Supervisor', _supervisorNameController.text.isEmpty
                  ? '—'
                  : _supervisorNameController.text),
              _reviewRow('Research Title',
                  _titleController.text.isEmpty ? '—' : _titleController.text),
              _reviewRow('Health Center', _selectedHealthCenter ?? '—'),
              _reviewRow('Study Type', _selectedStudyType ?? '—'),
              _reviewRow(
                  'Documents',
                  [
                    _proposalFileName,
                    _ethicsFileName,
                    _toolsFileName,
                    _supportingFileName
                  ].whereType<String>().length.toString() +
                      ' attached'),
              const SizedBox(height: 8),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _isConfirmed,
                onChanged: (val) => setState(() => _isConfirmed = val ?? false),
                title: const Text(
                  'I confirm all submitted information is accurate and complete',
                  style: AppTextStyles.bodySecondary,
                ),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: NaraakButton(
                label: 'Back',
                variant: AppButtonVariant.secondary,
                onPressed: () => setState(() => _currentStep = 4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: NaraakButton(
                label: 'Submit Application',
                isLoading: _isSubmitting,
                onPressed: (_isConfirmed && !_isSubmitting) ? _submit : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _reviewRow(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 120, child: Text(label, style: AppTextStyles.bodySecondary)),
            Expanded(
                child: Text(value,
                    style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700))),
          ],
        ),
      );

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    final repository = context.read<NaraakRepository>();
    try {
      await repository.api.submitResearchApplication(
        patientId: repository.requirePatientId,
        applicantType: _selectedRole,
        applicantDetails: {
          'email': _emailController.text,
          'phone': _phoneController.text,
          'institution': _institutionController.text,
        },
        supervisorDetails: {
          'name': _supervisorNameController.text,
          'email': _supervisorEmailController.text,
          'phone': _supervisorPhoneController.text,
        },
        researchDetails: {
          'title': _titleController.text,
          'objective': _objectiveController.text,
          'healthCenter': _selectedHealthCenter,
          'duration': _durationController.text,
          'studyType': _selectedStudyType,
        },
        supportingDocuments: [
          _proposalFileName,
          _ethicsFileName,
          _toolsFileName,
          _supportingFileName
        ].whereType<String>().toList(),
      );
      if (mounted) setState(() => _isSubmitted = true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(repository.friendlyError(error, arabic: false))),
        );
      }
    }
    if (mounted) setState(() => _isSubmitting = false);
  }

  // --- Success State ---
  Widget _buildSuccessCard() {
    return NaraakCard(
      child: Column(
        children: [
          const Icon(Icons.check_circle, size: 64, color: AppColors.success),
          const SizedBox(height: 16),
          const Text('Application Submitted', style: AppTextStyles.h2),
          const SizedBox(height: 8),
          const Text(
            'Your PHC Research Application (NRK-RES-2026-088) has been successfully submitted to the Primary Health Care Ethics Committee.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 20),
          _buildReadOnlyField('Applicant Role: $_selectedRole'),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: NaraakButton(
              label: 'Back to Services',
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helpers ---
  Color get _themeColor => context.watch<AppSettingsProvider>().palette.primary;

  Widget _buildRoleTab(String title) {
    final isSelected = _selectedRole == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = title),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? _themeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.neutralGray,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepperHeader() {
    return Row(
      children: [
        _buildStepItem(1, 'Applicant'),
        _buildStepLine(active: _currentStep >= 2),
        _buildStepItem(2, 'Supervisor'),
        _buildStepLine(active: _currentStep >= 3),
        _buildStepItem(3, 'Research'),
        _buildStepLine(active: _currentStep >= 4),
        _buildStepItem(4, 'Documents'),
        _buildStepLine(active: _currentStep >= 5),
        _buildStepItem(5, 'Review'),
      ],
    );
  }

  Widget _buildStepItem(int stepNumber, String label) {
    final isDone = _currentStep > stepNumber;
    final isCurrent = _currentStep == stepNumber;

    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (isDone || isCurrent) ? _themeColor : Colors.transparent,
            border: Border.all(
              color:
                  (isDone || isCurrent) ? _themeColor : AppColors.neutralGray,
              width: 2,
            ),
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text(
                    '$stepNumber',
                    style: TextStyle(
                      color: isCurrent ? Colors.white : AppColors.neutralGray,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isCurrent ? _themeColor : AppColors.neutralGray,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine({required bool active}) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8).copyWith(bottom: 16),
        color:
            active ? _themeColor : AppColors.neutralGray.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildUploadBox({
    required String label,
    required String sublabel,
    String? fileName,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.secondaryIce.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _themeColor.withValues(alpha: 0.4),
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.cloud_upload_outlined, color: _themeColor, size: 28),
                const SizedBox(height: 6),
                Text(
                  fileName ?? 'Drag & Drop or browse',
                  style: AppTextStyles.body.copyWith(
                    color: _themeColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(sublabel, style: AppTextStyles.caption),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.secondaryIce,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.neutralGray.withValues(alpha: 0.3)),
      ),
      child: Text(text,
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold)),
    );
  }

}
