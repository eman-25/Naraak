import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/naraak_logo.dart';

class NaraakSplashScreen extends StatefulWidget {
  const NaraakSplashScreen({super.key});

  @override
  State<NaraakSplashScreen> createState() => _NaraakSplashScreenState();
}

class _NaraakSplashScreenState extends State<NaraakSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    Future<void>.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/logo-animation');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.surface,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 40, 28, 32),
            child: Column(
              children: [
                const Spacer(),
                const NaraakLogo(size: 168),
                const SizedBox(height: 24),
                Text('نرعاك', style: AppTextStyles.h1),
                const SizedBox(height: 4),
                Text('NARAAK',
                    style: AppTextStyles.h2.copyWith(letterSpacing: 5)),
                const Spacer(),
                Text(
                  'Connecting care, for a healthier you.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodySecondary,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 34,
                  height: 34,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
