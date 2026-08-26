import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Simulated file-attach control shared by every service that requires a
/// supporting document (Fee Exemption proof of eligibility, Vaccination
/// missing-record report, PHC Research approval letter, etc.).
///
/// There's no real file picker in this demo build, so tapping the field
/// "attaches" a fixed fictional filename and runs it through [validate] —
/// enough to exercise the documented file type/size decision points
/// without a platform file-picker dependency.
///
/// [onAttached], [onCleared], and [onRejected] are kept separate (rather
/// than one nullable callback) so a failed validation attempt can never be
/// confused with the user deliberately clearing a valid attachment.
class UploadField extends StatelessWidget {
  final String label;
  final String? fileName;
  final String demoFileName;
  final String? Function(String fileName) validate;
  final ValueChanged<String> onAttached;
  final VoidCallback onCleared;
  final ValueChanged<String> onRejected;

  const UploadField({
    super.key,
    required this.label,
    required this.validate,
    required this.onAttached,
    required this.onCleared,
    required this.onRejected,
    this.fileName,
    this.demoFileName = 'supporting_document.pdf',
  });

  void _handleTap() {
    final error = validate(demoFileName);
    if (error != null) {
      onRejected(error);
      return;
    }
    onAttached(demoFileName);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        InkWell(
          onTap: _handleTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.secondaryIce,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  fileName != null ? Icons.check_circle : Icons.attach_file,
                  color: fileName != null ? AppColors.success : AppColors.primaryTeal,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    fileName ?? 'Tap to attach a file (demo)',
                    style: AppTextStyles.body,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (fileName != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 18, color: AppColors.neutralGray),
                    onPressed: onCleared,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text('Accepted: PDF, JPG, PNG — up to 5MB', style: AppTextStyles.caption),
      ],
    );
  }
}
