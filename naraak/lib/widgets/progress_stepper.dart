import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';

class ProgressStepper extends StatelessWidget {
  const ProgressStepper({
    super.key,
    required this.steps,
    required this.currentStep,
  });

  final List<String> steps;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Semantics(
      label:
          'Step ${currentStep + 1} of ${steps.length}: ${steps[currentStep]}',
      child: Row(
        children: [
          for (var index = 0; index < steps.length; index++) ...[
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      if (index > 0)
                        Expanded(
                          child: Divider(
                            color: index <= currentStep
                                ? primary
                                : Theme.of(context).dividerColor,
                            thickness: 2,
                          ),
                        ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: index <= currentStep
                              ? primary
                              : Theme.of(context).colorScheme.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: primary, width: 2),
                        ),
                        child: index < currentStep
                            ? const Icon(Icons.check_rounded,
                                color: Colors.white, size: 18)
                            : Text(
                                '${index + 1}',
                                style: AppTextStyles.caption.copyWith(
                                  color: index == currentStep
                                      ? Colors.white
                                      : primary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      ),
                      if (index < steps.length - 1)
                        Expanded(
                          child: Divider(
                            color: index < currentStep
                                ? primary
                                : Theme.of(context).dividerColor,
                            thickness: 2,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Text(
                    steps[index],
                    style: AppTextStyles.caption.copyWith(
                      color: index == currentStep ? primary : null,
                      fontWeight: index == currentStep
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
