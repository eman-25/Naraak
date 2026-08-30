// lib/screens/help_support_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/naraak_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  String _category = 'General Inquiry';
  bool _isSubmitted = false;

  final _categories = const [
    'General Inquiry',
    'Service Evaluation',
    'Submit a Complaint',
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  bool _submitting = false;

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    final repository = context.read<NaraakRepository>();
    try {
      await repository.api.submitSupportMessage(
        patientId: repository.requirePatientId,
        category: _category,
        subject: _subjectController.text.trim(),
        message: _messageController.text.trim(),
      );
      if (mounted) setState(() => _isSubmitted = true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(repository.friendlyError(error, arabic: false))),
        );
      }
    }
    if (mounted) setState(() => _submitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _InlinePageHeading(title: 'Help & Support'),
          const SizedBox(height: 28),
          const Text('FREQUENTLY ASKED QUESTIONS',
              style: AppTextStyles.overline),
          const SizedBox(height: 10),
          const AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _InlinePageHeading(title: 'Help & Support'),
                const SizedBox(height: 28),
                _FaqTile(
                  question: 'How do I book an appointment?',
                  answer:
                      'Go to Services > Book Appointment, choose a health center and doctor, then pick an available time slot.',
                ),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 1)),
                _FaqTile(
                  question: 'How do I check my request status?',
                  answer:
                      'Open Services > Pending Requests to see the live status of every request you have submitted.',
                ),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 1)),
                _FaqTile(
                  question: 'Can I manage appointments for a family member?',
                  answer:
                      'Yes — add them under Profile > Family Members & Dependents, then switch to their profile to act on their behalf.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('CONTACT US', style: AppTextStyles.overline),
          const SizedBox(height: 10),
          const AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _InlinePageHeading(title: 'Help & Support'),
                const SizedBox(height: 28),
                ListTile(
                  leading:
                      Icon(Icons.phone_outlined, color: AppColors.primaryTeal),
                  title: Text('Call Center'),
                  subtitle: Text('80008080 (Sun–Thu, 7 AM–2 PM)'),
                ),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 1)),
                ListTile(
                  leading:
                      Icon(Icons.email_outlined, color: AppColors.primaryTeal),
                  title: Text('Email'),
                  subtitle: Text('support@naraak.bh'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('SEND US A MESSAGE', style: AppTextStyles.overline),
          const SizedBox(height: 10),
          AppCard(
            child: _isSubmitted ? _buildSuccess() : _buildForm(),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InlinePageHeading(title: 'Help & Support'),
          const SizedBox(height: 28),
          const Text('Category', style: AppTextStyles.label),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: _category,
            items: _categories
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => setState(() => _category = v ?? _category),
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          const Text('Subject', style: AppTextStyles.label),
          const SizedBox(height: 6),
          TextFormField(
            controller: _subjectController,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Please enter a subject' : null,
          ),
          const SizedBox(height: 16),
          const Text('Message', style: AppTextStyles.label),
          const SizedBox(height: 6),
          TextFormField(
            controller: _messageController,
            maxLines: 4,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Please enter a message' : null,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: AppButton(
                label: 'Submit',
                isLoading: _submitting,
                onPressed: _submitting ? null : _submit),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Column(
      children: [
        const Icon(Icons.check_circle, size: 56, color: AppColors.success),
        const SizedBox(height: 12),
        const Text('Message Sent', style: AppTextStyles.h3),
        const SizedBox(height: 6),
        const Text(
          'Our support team will get back to you. You can track this under Pending Requests.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySecondary,
        ),
      ],
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;
  const _FaqTile({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(question, style: AppTextStyles.body),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: [Text(answer, style: AppTextStyles.bodySecondary)],
    );
  }
}

class _InlinePageHeading extends StatelessWidget {
  const _InlinePageHeading({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: 4),
        Text(title, style: AppTextStyles.h2),
      ],
    );
  }
}
