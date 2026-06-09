import 'package:flutter/material.dart';

class DocumentRbacPolicyPanel extends StatelessWidget {
  const DocumentRbacPolicyPanel({super.key});

  @override
  Widget build(BuildContext context) {
    const rows = [
      ('مشاهد الوثائق', 'قراءة الوثائق المصرح بها فقط'),
      ('مدخل الوثائق', 'رفع الملفات وإنشاء jobs'),
      ('مراجع الوثائق', 'مراجعة الحقول والروابط والمقاطع غير المؤكدة'),
      ('مدير مركز الوثائق', 'إعادة المعالجة وإدارة إعدادات المحرك'),
      ('مشرف سيادي', 'اعتماد الربط النهائي مع waqf_assets وباقي الأنظمة'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows.map((row) {
        return ListTile(
          dense: true,
          leading: const Icon(Icons.verified_user_outlined),
          title: Text(row.$1),
          subtitle: Text(row.$2),
        );
      }).toList(),
    );
  }
}
