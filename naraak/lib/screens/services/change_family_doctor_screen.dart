import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// STUB — screen scaffold only. Wire up a Mock*Service + Provider here
/// following the pattern in booking_appointment_screen.dart /
/// vaccination_records_screen.dart once this service's mock data is ready
/// (Phase 6 §5.2 Mock Data Coverage table).
class ChangeFamilyDoctorScreen extends StatelessWidget {
  const ChangeFamilyDoctorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Family Doctor')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.construction, size: 48, color: AppColors.neutralGray),
              const SizedBox(height: 16),
              Text('Change Family Doctor', style: AppTextStyles.h3, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                'Screen scaffold ready — mock service pending.',
                style: AppTextStyles.bodySecondary,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
