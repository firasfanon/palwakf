import 'package:flutter/material.dart';
import 'package:waqf/core/constants/app_constants.dart';

class UnsavedChangesBanner extends StatelessWidget {
  final VoidCallback onSave;
  final VoidCallback onReset;

  const UnsavedChangesBanner({
    super.key,
    required this.onSave,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: BoxDecoration(
        color: AppConstants.warning.withValues(alpha:0.1),
        border: Border(
          bottom: BorderSide(color: AppConstants.warning.withValues(alpha:0.3)),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: AppConstants.warning),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تغييرات غير محفوظة',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppConstants.warning,
                  ),
                ),
                Text(
                  'لديك تغييرات غير محفوظة. تأكد من حفظها قبل المغادرة.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppConstants.warning,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onSave,
            child: const Text('حفظ الآن'),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: onReset,
            child: const Text('تراجع'),
          ),
        ],
      ),
    );
  }
}