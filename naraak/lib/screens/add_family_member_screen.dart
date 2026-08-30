import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;
import 'package:provider/provider.dart';
import '../models/family_member.dart';
import '../providers/family_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/form_section.dart';
import '../widgets/naraak_app_bar.dart';
import '../widgets/naraak_button.dart';
import '../widgets/responsive_page_frame.dart';
import '../widgets/state_views.dart';

class AddFamilyMemberScreen extends StatefulWidget {
  const AddFamilyMemberScreen({super.key});
  @override
  State<AddFamilyMemberScreen> createState() => _AddFamilyMemberScreenState();
}

class _AddFamilyMemberScreenState extends State<AddFamilyMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _cpr = TextEditingController();
  String _relation = 'Spouse';
  DateTime? _expiry;
  String? _block;
  bool _verifying = false;
  bool _added = false;
  static const _relations = ['Spouse', 'Child', 'Parent'];
  static const _blocks = ['Block 301 - Manama', 'Block 302 - Manama', 'Block 308 - Qudaibiya', 'Block 318 - Hoora', 'Block 321 - Juffair', 'Block 404 - Sanabis', 'Block 602 - Sitra'];

  @override
  void dispose() {
    _name.dispose();
    _cpr.dispose();
    super.dispose();
  }

  Future<void> _pickExpiry() async {
    final now = DateTime.now();
    final value = await showDatePicker(context: context, initialDate: DateTime(now.year + 2), firstDate: now, lastDate: DateTime(now.year + 15));
    if (value != null) setState(() => _expiry = value);
  }

  Future<void> _verifyAndAdd() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_expiry == null || _block == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_expiry == null ? 'Select the ID card expiry date.' : 'Select a block.')));
      return;
    }
    setState(() => _verifying = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    final cpr = _cpr.text.trim();
    context.read<FamilyProvider>().addMember(FamilyMember(
      id: 'm-' + DateTime.now().millisecondsSinceEpoch.toString(),
      fullName: _name.text.trim(),
      relation: _relation,
      age: 0,
      cprMasked: cpr.length >= 4 ? cpr.substring(0, 4) + '***' + cpr.substring(cpr.length - 2) : cpr,
      healthCenter: _block!,
    ));
    setState(() {
      _verifying = false;
      _added = true;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const NaraakAppBar(title: 'Add Family Member'),
    body: ResponsivePageFrame(
      maxWidth: 760,
      child: _added
          ? SuccessState(
              title: 'Family member linked',
              message: _name.text.trim() + ' was verified and added to your family.',
              actionLabel: 'Back to Family',
              onAction: () => Navigator.pop(context),
            )
          : Form(
              key: _formKey,
              child: FormSection(
                title: 'Verify family member',
                description: 'Enter their identity details to simulate relationship verification.',
                children: [
                  TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(labelText: 'Full name'),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Enter their full name' : null,
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: _relation,
                    decoration: const InputDecoration(labelText: 'Relation'),
                    items: _relations.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                    onChanged: (value) => setState(() => _relation = value ?? _relation),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _cpr,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(labelText: 'CPR number', hintText: 'e.g. 990422345'),
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.isEmpty) return 'Enter their CPR number';
                      if (text.length < 9) return 'CPR number looks too short';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  InkWell(
                    onTap: _pickExpiry,
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'ID card expiry date'),
                      child: Text(
                        _expiry == null ? 'Select date' : _expiry!.day.toString() + '/' + _expiry!.month.toString() + '/' + _expiry!.year.toString(),
                        style: AppTextStyles.body.copyWith(color: _expiry == null ? AppColors.ink500 : null),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: _block,
                    decoration: const InputDecoration(labelText: 'Residential block'),
                    items: _blocks.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                    onChanged: (value) => setState(() => _block = value),
                  ),
                  const SizedBox(height: 22),
                  NaraakButton(
                    label: 'Verify and Add',
                    icon: Icons.verified_user_outlined,
                    isLoading: _verifying,
                    onPressed: _verifying ? null : _verifyAndAdd,
                  ),
                ],
              ),
            ),
    ),
  );
}
