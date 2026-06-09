import 'package:flutter/material.dart';

/// Compile-safe platform shell for the Waqf Assets apply gate.
///
/// The operational write gate is intentionally blocked from this platform
/// runtime package until the governed Awqaf System package supplies its full
/// contracts/widgets through the approved join package. This page preserves
/// routing/analyzer stability without mutating `waqf`, `waqf_assets`,
/// `awqaf_system`, or `auth.users`.
class AwqafSystemWaqfAssetsApplyGatePage extends StatelessWidget {
  const AwqafSystemWaqfAssetsApplyGatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('بوابة تطبيق الأصول الوقفية')),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: const [
            _ApplyGateStatusCard(),
            SizedBox(height: 16),
            _ApplyGateChecklistCard(),
          ],
        ),
      ),
    );
  }
}

class _ApplyGateStatusCard extends StatelessWidget {
  const _ApplyGateStatusCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: const Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الحالة التشغيلية',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 12),
            Text(
              'هذه شاشة استقرار compile فقط داخل منصة PalWakf. تنفيذ target write إلى الأصول الوقفية يبقى محجوبًا حتى اعتماد حزمة Awqaf System التشغيلية الكاملة وأدلة التفويض والنسخ الاحتياطي.',
            ),
          ],
        ),
      ),
    );
  }
}

class _ApplyGateChecklistCard extends StatelessWidget {
  const _ApplyGateChecklistCard();

  @override
  Widget build(BuildContext context) {
    const items = [
      'لا يوجد service_role داخل Flutter.',
      'لا يوجد DML على auth.users.',
      'لا يوجد DML على waqf أو waqf_assets أو awqaf_system من هذه الشاشة.',
      'الربط التشغيلي الكامل يتطلب Join Package منفصلًا من Awqaf System.',
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ضوابط الحماية',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_outline, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(item)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
