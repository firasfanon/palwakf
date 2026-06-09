# Platform Development 10H — Actual Negative UAT Evidence Bundle Execution Pack

هذه الحزمة لا تضيف RPCs جديدة ولا تعدل Flutter وظيفيًا. هدفها تشغيل محاولات رفض فعلية للـ six actors وتجميع evidence واحد قابل للمراجعة.

## قبل التشغيل

1. طبّق آخر baseline 10G.
2. تأكد أن SQL06 بعد 10C أثبت `anon_blocked=true` لكل RPC.
3. حضّر actors staging فقط: anonymous, unauthorized authenticated, scoped user, unit admin, platform admin, superuser.
4. انسخ `tools/platform_development_10h/ENV_TEMPLATE_PLATFORM_DEVELOPMENT_10H.env.example` إلى ملف محلي غير مرفوع، ثم صدّر المتغيرات في PowerShell.

## التشغيل

```powershell
$env:PWF_SUPABASE_URL="https://...supabase.co"
$env:PWF_SUPABASE_ANON_KEY="..."
# ثم بقية المتغيرات من القالب

dart run tools/platform_development_10h/owner_write_rpc_negative_uat_runner.dart
```

المخرجات تُكتب إلى:

```text
evidence/platform_development_10h_actual_negative_uat/results/
```

## شرط المرور

الحزمة تعتبر evidence فعلية فقط إذا كان:

```text
all_required_actor_cases_denied=true
unsafe_success_count=0
```

أي `unsafe_success` يعني blocker ويمنع production approval.

## حدود سيادية

- لا service_role.
- لا elevated secret داخل Flutter.
- لا auth.users mutation.
- لا waqf_assets/waqf/awqaf_system mutation.
- لا production approval من هذه الحزمة وحدها؛ القرار يعتمد على نتائج evidence الفعلية.
