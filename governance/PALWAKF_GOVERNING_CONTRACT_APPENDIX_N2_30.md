# ملحق العقد الحاكم — N2.30

## قاعدة Schema Inventory Contract
كل عمليات إدخال قرارات ملكية الجداول يجب أن تستخدم الأعمدة الحقيقية:
- source_schema
- object_name
- object_type
- current_owner_system
- recommended_owner_system
- classification
- decision
- action_status
- risk_level
- dependency_status
- rls_status
- rpc_usage_status
- flutter_usage_status
- no_auto_drop
- notes_ar

يُمنع استخدام `schema_name`, `table_name`, `notes`, أو `action_required` ضد الجدول مباشرة.

## قاعدة Safe Execution
أي نقل أو حذف أو إعادة توزيع لجداول public/core/gis/media/services لا ينفذ إلا بعد:
1. dependency audit
2. RLS migration
3. RPC compatibility wrappers
4. Flutter repository migration
5. rollback plan
6. Browser UAT
7. SQL read-only UAT

## Public Schema Rule
public يبقى wrappers/views/RPC/compatibility فقط قدر الإمكان. أي جدول تشغيلي في public يعتبر transitional بعقد موثق.
