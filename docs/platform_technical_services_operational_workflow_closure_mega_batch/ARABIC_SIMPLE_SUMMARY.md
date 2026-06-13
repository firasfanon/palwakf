# Platform Technical Services — Operational Workflow Closure Mega Batch

## ما أضيف

- دورة حياة للطلبات التقنية: approve/reject/start/complete/fail/cancel.
- تسجيل backup metadata دون export.
- اعتماد/إلغاء/إكمال نافذة صيانة.
- RPC عامة للقراءة لحالة الصيانة.
- RPC لتصفية Audit Events.
- امتدادات Flutter/Riverpod لاستدعاء workflow.

## الحدود

لا backup/restore فعلي، لا إغلاق تلقائي، لا deploy من Flutter، لا service_role، لا تعديل بيانات سيادية.
