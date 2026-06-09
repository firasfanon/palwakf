# PALWAKF_PLATFORM_GOVERNANCE_UPDATE — N2.30 Session Close

## قواعد الحوكمة

- `platform.schema_inventory_decisions` هو سجل قرارات ملكية الجداول.
- لا DML على سجلات الحوكمة قبل shape discovery.
- Wave B لا تبدأ بتنفيذ نقل؛ تبدأ باختيار Safe Migration Candidate.
- أي public table تشغيلي يجب أن يحمل classification وdecision وrisk_level وstatuses.
- أي جدول مرشح للنقل يجب أن يمر عبر Movement Gate.

## التصنيفات المعتمدة

```text
keep_in_schema
move_to_system_schema
public_wrapper_only
legacy_archive_candidate
staging_archive_candidate
cache_deprecate_then_archive
transitional_contract
manual_review
supabase_managed
```

## الحالة

N2.30 UAT passed، لكن Production غير معتمد.
