import 'package:flutter/material.dart';
import '../../../core/enums/enums.dart';

class SystemDashboardPlaceholder extends StatelessWidget {
  final SystemKey systemKey;

  const SystemDashboardPlaceholder({super.key, required this.systemKey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${systemKey.slug} - لوحة النظام'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.dashboard_outlined, size: 56),
              const SizedBox(height: 12),
              Text(
                'تم تجهيز هيكل النظام: ${systemKey.slug}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'سيتم إضافة صفحات CRUD/الخرائط/التقارير ضمن هذا النظام تدريجيًا.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
