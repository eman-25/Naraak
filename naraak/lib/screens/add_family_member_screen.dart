// lib/screens/add_family_member_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:provider/provider.dart';
import '../models/family_member.dart';
import '../providers/family_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_button.dart';
import '../widgets/app_card.dart';
import '../widgets/app_top_bar.dart';

/// Add Family Member — Phase 3 §2.6: verifying a new family member's
/// identity (CPR + card expiry + block) before linking them, as its own
/// page instead of a single-button dialog.
class AddFamilyMemberScreen extends StatefulWidget {
  const AddFamilyMemberScreen({super.key});

  @override
  State<AddFamilyMemberScreen> createState() => _AddFamilyMemberScreenState();
}

class _AddFamilyMemberScreenState extends State<AddFamilyMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cprController = TextEditingController();
  String _relation = 'Spouse';
  DateTime? _cardExpiry;
  String? _block;
  bool _isVerifying = false;

  static const _relations = ['Spouse', 'Child', 'Parent'];
  static const _blocks = [
    'Block 301 - Manama',
    'Block 302 - Manama',
    'Block 308 - Qudaibiya',
    'Block 318 - Hoora',
    'Block 321 - Juffair',
    'Block 404 - Sanabis',
    'Block 602 - Sitra',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _cprController.dispose();
    super.dispose();
  }

  Future<void> _pickExpiryDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year + 2),
      firstDate: now,
      lastDate: DateTime(now.year + 15),
    );
    if (picked != null) setState(() => _cardExpiry = picked);
  }

  Future<void> _handleVerifyAndAdd() async {
    if (!_formKey.currentState!.validate()) return;
    if (_cardExpiry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select the ID card expiry date.')),
      );
      return;
    }
    if (_block == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a block.')),
      );
      return;
    }

    setState(() => _isVerifying = true);
    await Future.delayed(
        const Duration(milliseconds: 700)); // simulated eKey verification
    if (!mounted) return;
    setState(() => _isVerifying = false);

    final cpr = _cprController.text.trim();
    context.read<FamilyProvider>().addMember(
          FamilyMember(
            id: 'm-${DateTime.now().millisecondsSinceEpoch}',
            fullName: _nameController.text.trim(),
            relation: _relation,
            age: 0,
            cprMasked: cpr.length >= 4
                ? '${cpr.substring(0, 4)}•••${cpr.substring(cpr.length - 2)}'
                : cpr,
            healthCenter: _block!,
          ),
        );

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Family member added.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'Add Family Member'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Full Name', style: AppTextStyles.label),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nameController,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Enter their full name'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  const Text('Relation', style: AppTextStyles.label),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _relation,
                    items: _relations
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _relation = v ?? _relation),
                  ),
                  const SizedBox(height: 16),
                  const Text('CPR Number', style: AppTextStyles.label),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _cprController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    decoration:
                        const InputDecoration(hintText: 'e.g. 990422345'),
                    validator: (v) {
                      final trimmed = v?.trim() ?? '';
                      if (trimmed.isEmpty) return 'Enter their CPR number';
                      if (trimmed.length < 9) {
                        return 'CPR number looks too short';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('ID Card Expiry Date', style: AppTextStyles.label),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: _pickExpiryDate,
                    borderRadius: BorderRadius.circular(10),
                    child: InputDecorator(
                      decoration: const InputDecoration(),
                      child: Text(
                        _cardExpiry == null
                            ? 'Select date'
                            : '${_cardExpiry!.day}/${_cardExpiry!.month}/${_cardExpiry!.year}',
                        style: AppTextStyles.body.copyWith(
                          color: _cardExpiry == null
                              ? AppColors.ink500
                              : AppColors.ink900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Block', style: AppTextStyles.label),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _block,
                    hint: const Text('Select block'),
                    items: _blocks
                        .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                        .toList(),
                    onChanged: (v) => setState(() => _block = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'These details verify the family relationship, matching how '
                'eKey confirms identity elsewhere in this app.',
                style: AppTextStyles.caption.copyWith(color: AppColors.ink500),
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Verify & Add (Demo)',
              isLoading: _isVerifying,
              onPressed: _isVerifying ? null : _handleVerifyAndAdd,
            ),
          ],
        ),
      ),
    );
  }
}
