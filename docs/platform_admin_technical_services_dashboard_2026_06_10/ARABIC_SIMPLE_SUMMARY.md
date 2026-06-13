# Platform Admin Technical Services Dashboard — Arabic Summary

## طبيعة الدفعة

هذه دفعة **تطوير واجهات إدارية محكومة** داخل لوحة تحكم المنصة.

ليست دفعة SQL، وليست تنفيذًا فعليًا للنسخ الاحتياطي أو الاستعادة أو وضع الصيانة الإنتاجي.

## ما تم تنفيذه

تمت إضافة مركز خدمات تقنية جديد تحت:

- `/admin/platform/technical-services`
- `/admin/platform/technical-services/backup`
- `/admin/platform/technical-services/maintenance`
- `/admin/platform/technical-services/health`
- `/admin/platform/technical-services/deployment`
- `/admin/platform/technical-services/audit`

وتم ربطها مع:

- GoRouter
- AppRoutes
- AdminRouteAccessContracts
- Sidebar / AdminPanelRegistry
- Dashboard quick access hub

## الخدمات التقنية المضافة

1. النسخ الاحتياطي والاستعادة — readiness فقط.
2. وضع الصيانة ونوافذ التشغيل — تخطيط وجدولة فقط.
3. صحة النظام ومؤشرات التشغيل — قراءة ومراقبة فقط.
4. النشر والإصدارات — توثيق Vercel/Flutter/Dart فقط.
5. السجلات والتدقيق التقني — تجميع متطلبات audit دون حذف سجلات.

## حدود الأمان

- لا backup export من Flutter.
- لا restore من Flutter.
- لا service_role في الواجهة.
- لا DDL/DML.
- لا تعديل بيانات سيادية.
- لا production approval.
- لا تفعيل maintenance mode فعلي دون backend contract مستقل.

## المؤجل

- Backend contract لتفعيل maintenance mode.
- Audit tables لطلبات backup/restore/deployment.
- Health RPCs read-only.
- CI/CD integration مستقل.
- Approval workflow + rollback records.
