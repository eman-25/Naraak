// lib/screens/privacy_security_screen.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_card.dart';
import '../widgets/app_top_bar.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool _biometricLogin = true;
  bool _autoLock = true;
  bool _shareWithHealthCenter = true;

  void _changePin() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change PIN'),
        content: const Text(
            'Enter your current PIN and choose a new one to secure your account.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PIN updated.')),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _downloadData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text(
              'Your data export request has been submitted. You will be notified when it is ready.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'Privacy & Security'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('LOGIN & ACCESS', style: AppTextStyles.overline),
          const SizedBox(height: 10),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Biometric / Face ID Login'),
                  subtitle: const Text('Use fingerprint or face to sign in'),
                  value: _biometricLogin,
                  onChanged: (v) => setState(() => _biometricLogin = v),
                ),
                const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 1)),
                SwitchListTile(
                  title: const Text('Auto-Lock'),
                  subtitle: const Text('Lock the app after 5 minutes idle'),
                  value: _autoLock,
                  onChanged: (v) => setState(() => _autoLock = v),
                ),
                const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 1)),
                ListTile(
                  title: const Text('Change PIN'),
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: AppColors.ink300),
                  onTap: _changePin,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('DATA', style: AppTextStyles.overline),
          const SizedBox(height: 10),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Share Records With My Health Center'),
                  subtitle: const Text(
                      'Lets your assigned PHC view appointment and request history'),
                  value: _shareWithHealthCenter,
                  onChanged: (v) => setState(() => _shareWithHealthCenter = v),
                ),
                const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 1)),
                ListTile(
                  title: const Text('Download My Data'),
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: AppColors.ink300),
                  onTap: _downloadData,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
