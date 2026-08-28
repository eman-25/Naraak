import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_top_bar.dart';

class MedicalReportsScreen extends StatefulWidget {
  const MedicalReportsScreen({super.key});

  @override
  State<MedicalReportsScreen> createState() => _MedicalReportsScreenState();
}

class _MedicalReportsScreenState extends State<MedicalReportsScreen> {
  int _currentStep = 1;

  // Form selections
  String? _selectedRequestType;
  String _selectedCategory = 'Laboratory';
  String? _selectedDoctor;
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _doctorSearchController = TextEditingController();

  // Mock list of doctors previously visited
  final List<Map<String, String>> _visitedDoctors = [
    {
      'name': 'Dr. Salman Al-Khalifa',
      'specialty': 'Family Medicine • Naim Health Center',
      'lastVisited': 'Last visited: 12 Oct 2026',
    },
    {
      'name': 'Dr. Fatima Al-Aali',
      'specialty': 'General Medicine • Naim Health Center',
      'lastVisited': 'Last visited: 8 Sep 2026',
    },
    {
      'name': 'Dr. Maryam Yusuf',
      'specialty': 'Pediatrics • Naim Health Center',
      'lastVisited': 'Last visited: 3 Aug 2026',
    },
  ];

  final List<String> _requestTypes = [
    'General Medical Report',
    'Laboratory Diagnostic Report',
    'Radiology / Imaging Report',
    'Sick Leave Certificate Validation',
  ];

  final List<String> _categories = [
    'Laboratory',
    'Radiology',
    'Consultation Note',
    'General Certificate',
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    _doctorSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProfileProvider>().profile;

    return Scaffold(
      appBar: const AppTopBar(title: 'Request a Medical Report'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Step Progress Indicator Header
            _buildStepperHeader(),
            const SizedBox(height: 16),

            // Step Content
            if (_currentStep == 1) _buildStepOne(profile),
            if (_currentStep == 2) _buildStepTwo(profile),
            if (_currentStep == 3) _buildStepThree(),
          ],
        ),
      ),
    );
  }

  // --- STEP 1: Details ---
  Widget _buildStepOne(dynamic profile) {
    final filteredDoctors = _visitedDoctors.where((doc) {
      final query = _doctorSearchController.text.toLowerCase();
      return doc['name']!.toLowerCase().contains(query);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Applicant Details Section
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Applicant Details', style: AppTextStyles.h3),
              const SizedBox(height: 12),
              const Text('Personal Number', style: AppTextStyles.caption),
              const SizedBox(height: 4),
              _buildReadOnlyField(profile?.cpr ?? '990422345'),
              const SizedBox(height: 12),
              const Text('Full Name', style: AppTextStyles.caption),
              const SizedBox(height: 4),
              _buildReadOnlyField(profile?.fullName ?? 'Eman Al-Khalifa'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Request Details Section
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Request Details', style: AppTextStyles.h3),
              const SizedBox(height: 12),

              // Request Type Dropdown
              const Text('Request Type *', style: AppTextStyles.caption),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                value: _selectedRequestType,
                hint: const Text('Select request type'),
                items: _requestTypes
                    .map((type) =>
                        DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedRequestType = val),
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),

              // Category Dropdown
              const Text('Category *', style: AppTextStyles.caption),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories
                    .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) =>
                    setState(() => _selectedCategory = val ?? 'Laboratory'),
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),

              // Consultant Name Search & List
              const Text('Consultant Name *', style: AppTextStyles.caption),
              const SizedBox(height: 4),
              TextField(
                controller: _doctorSearchController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Search by doctor name',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),

              // Visited Doctors Selection Box
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                      color: AppColors.neutralGray.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: filteredDoctors.map((doc) {
                    final isSelected = _selectedDoctor == doc['name'];
                    return Column(
                      children: [
                        ListTile(
                          selected: isSelected,
                          selectedTileColor: AppColors.secondaryIce,
                          title: Text(doc['name']!,
                              style: AppTextStyles.body
                                  .copyWith(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                              '${doc['specialty']!}\n${doc['lastVisited']!}',
                              style: AppTextStyles.caption),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle,
                                  color: AppColors.primaryTeal)
                              : null,
                          onTap: () =>
                              setState(() => _selectedDoctor = doc['name']),
                        ),
                        if (doc != filteredDoctors.last)
                          const Divider(height: 1),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Only doctors you have visited appear here',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 16),

              // Reason Text Area
              const Text('Reason for Report Request *',
                  style: AppTextStyles.caption),
              const SizedBox(height: 4),
              TextField(
                controller: _reasonController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Describe why you need this report...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Action Button
        SizedBox(
          width: double.infinity,
          child: AppButton(
            label: 'Next',
            onPressed: _canProceedStepOne()
                ? () => setState(() => _currentStep = 2)
                : null,
          ),
        ),
      ],
    );
  }

  // --- STEP 2: Review ---
  Widget _buildStepTwo(dynamic profile) {
    return Column(
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Review Request Summary', style: AppTextStyles.h2),
              const Divider(height: 24),
              _buildSummaryRow('Applicant CPR', profile?.cpr ?? '990422345'),
              _buildSummaryRow(
                  'Applicant Name', profile?.fullName ?? 'Eman Al-Khalifa'),
              _buildSummaryRow('Request Type', _selectedRequestType ?? '-'),
              _buildSummaryRow('Category', _selectedCategory),
              _buildSummaryRow('Attending Doctor', _selectedDoctor ?? '-'),
              _buildSummaryRow('Reason', _reasonController.text),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Back',
                isOutlined: true,
                onPressed: () => setState(() => _currentStep = 1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                label: 'Confirm & Submit',
                onPressed: () => setState(() => _currentStep = 3),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- STEP 3: Confirm ---
  Widget _buildStepThree() {
    return AppCard(
      child: Column(
        children: [
          const Icon(Icons.check_circle, size: 64, color: AppColors.success),
          const SizedBox(height: 16),
          const Text('Request Submitted', style: AppTextStyles.h2),
          const SizedBox(height: 8),
          const Text(
            'Your medical report request has been sent to the respective consultant for processing.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 20),
          _buildReadOnlyField('Reference ID: NRK-REP-2026-889'),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: 'Back to Services',
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---
  Widget _buildStepperHeader() {
    return Row(
      children: [
        _buildStepItem(1, 'Details'),
        _buildStepLine(active: _currentStep >= 2),
        _buildStepItem(2, 'Review'),
        _buildStepLine(active: _currentStep >= 3),
        _buildStepItem(3, 'Confirm'),
      ],
    );
  }

  Widget _buildStepItem(int stepNumber, String label) {
    final isActive = _currentStep >= stepNumber;
    final isCurrent = _currentStep == stepNumber;

    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? AppColors.primaryTeal : Colors.transparent,
            border: Border.all(
              color: isActive ? AppColors.primaryTeal : AppColors.neutralGray,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              '$stepNumber',
              style: TextStyle(
                color: isActive ? Colors.white : AppColors.neutralGray,
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
            color: isCurrent ? AppColors.primaryTeal : AppColors.neutralGray,
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
        color: active
            ? AppColors.primaryTeal
            : AppColors.neutralGray.withValues(alpha: 0.3),
      ),
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

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  bool _canProceedStepOne() {
    return _selectedRequestType != null &&
        _selectedDoctor != null &&
        _reasonController.text.trim().isNotEmpty;
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : 'EK';
  }
}
