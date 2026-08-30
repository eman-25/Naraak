import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/naraak_logo.dart';

class LogoAnimationScreen extends StatefulWidget {
  const LogoAnimationScreen({super.key});

  @override
  State<LogoAnimationScreen> createState() => _LogoAnimationScreenState();
}

class _LogoAnimationScreenState extends State<LogoAnimationScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..forward();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Navigator.pushReplacementNamed(context, '/welcome');
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
    final reveal = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, .58, curve: Curves.easeOutCubic),
    );
    final words = CurvedAnimation(
      parent: _controller,
      curve: const Interval(.58, .9, curve: Curves.easeOut),
    );
    final pulse = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(1), weight: 72),
      TweenSequenceItem(tween: Tween(begin: 1, end: 1.06), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 1.06, end: 1), weight: 18),
    ]).animate(_controller);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.surface,
      body: SafeArea(
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    for (final size in const [220.0, 174.0])
                      Opacity(
                        opacity: ((1 - _controller.value) * .22).clamp(0, .22),
                        child: Container(
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: .35),
                            ),
                          ),
                        ),
                      ),
                    ClipRect(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        heightFactor: reveal.value,
                        child: ScaleTransition(
                          scale: pulse,
                          child: const NaraakLogo(size: 142),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                FadeTransition(
                  opacity: words,
                  child: Column(
                    children: [
                      Text('نرعاك', style: AppTextStyles.h1),
                      const SizedBox(height: 4),
                      Text('NARAAK',
                          style: AppTextStyles.h2.copyWith(letterSpacing: 5)),
                    ],
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
