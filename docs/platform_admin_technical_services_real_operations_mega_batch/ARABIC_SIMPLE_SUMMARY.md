# Platform Admin Technical Services — Real Operations Mega Batch

## طبيعة الدفعة

هذه دفعة تطوير حقيقية شاملة، وليست باتش واجهة فقط.

تتضمن:

- جداول تشغيل تقنية داخل `platform_technical`.
- RLS وسياسات قراءة.
- RPCs آمنة عبر `public`.
- ربط Flutter/Riverpod مع RPCs.
- نماذج تسجيل طلب backup، وجدولة maintenance، وتسجيل release، وتحديث health snapshot.
- عرض live metrics وrequests وaudit events.

## الحدود

لا تنفذ هذه الدفعة:

- backup export فعلي.
- restore فعلي.
- إغلاق الموقع تلقائيًا.
- deploy من Flutter.
- service_role في Flutter.
- mutation على `waqf.waqf_assets`.

## المسارات

- `/admin/platform/technical-services`
- `/admin/platform/technical-services/backup`
- `/admin/platform/technical-services/maintenance`
- `/admin/platform/technical-services/health`
- `/admin/platform/technical-services/deployment`
- `/admin/platform/technical-services/audit`

## SQL order

1. `00_READ_ME_FIRST.sql`
2. `01_PREFLIGHT_existing_surface_read_only.sql`
3. `02_APPLY_schema_tables_rls.sql`
4. `03_APPLY_rpc_contracts.sql`
5. `04_SEED_initial_health_release_records.sql`
6. `05_VERIFY_backend_contract_read_only.sql`
7. `06_AUTHENTICATED_RPC_SMOKE_TEMPLATE.sql`
8. `07_FINAL_GATE_read_only.sql`
