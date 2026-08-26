import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_profile_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_button.dart';

/// Single-user demo login — SCOPE LIMIT: no real eKey authentication.
/// Enter any CPR number to continue; this is a dummy-data prototype only.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cprController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _cprController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600)); // simulated eKey call

    if (!mounted) return;
    setState(() => _isLoading = false);

    final provider = context.read<UserProfileProvider>();
    provider.login(_cprController.text.trim());

    Navigator.pushReplacementNamed(context, '/profile-setup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 44,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.favorite, color: AppColors.bahrainAccent, size: 40),
                ),
                const SizedBox(height: 16),
                Text('Naraak', style: AppTextStyles.h1.copyWith(color: Colors.white)),
                const SizedBox(height: 4),
                Text(
                  'Primary Healthcare Portal',
                  style: AppTextStyles.body.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _cprController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppColors.neutralDark),
                  decoration: const InputDecoration(
                    labelText: 'CPR Number',
                    hintText: 'e.g. 990422345',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter your CPR number to continue';
                    }
                    if (value.trim().length < 9) {
                      return 'CPR number looks too short';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                AppButton(
                  label: 'Log in with eKey (Demo)',
                  isLoading: _isLoading,
                  onPressed: _handleLogin,
                ),
                const SizedBox(height: 16),
                Text(
                  'eKey is Bahrain\'s national digital identity system.\n'
                  'This demo does not perform real authentication.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(color: Colors.white60),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}