import 'package:flutter/material.dart';

class PwfUnitPublicGovernancePanel extends StatelessWidget {
  final String orgUnitId;
  final String unitNameAr;

  const PwfUnitPublicGovernancePanel({
    super.key,
    required this.orgUnitId,
    required this.unitNameAr,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'حوكمة النشر العام',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('الوحدة: $unitNameAr'),
            const SizedBox(height: 4),
            Text(
              'معرّف الوحدة: $orgUnitId',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
