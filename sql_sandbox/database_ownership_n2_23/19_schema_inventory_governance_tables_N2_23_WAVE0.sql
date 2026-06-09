-- Mega Batch N2.23 — Wave 0: Schema Inventory Governance Foundation
-- Safe DDL + governance seed only. No table moves. No deletes.
-- No DML against waqf, waqf_assets, awqaf_system.

create schema if not exists platform;

create table if not exists platform.schema_inventory_decisions (
  id uuid primary key default gen_random_uuid(),
  batch_key text not null default 'N2.23',
  source_schema text not null,
  object_name text not null,
  object_type text not null default 'table',
  current_owner_system text,
  recommended_owner_system text,
  classification text not null,
  decision text not null,
  action_status text not null default 'planned',
  risk_level text not null default 'medium',
  dependency_status text not null default 'not_checked',
  rls_status text not null default 'not_checked',
  rpc_usage_status text not null default 'not_checked',
  flutter_usage_status text not null default 'not_checked',
  no_auto_drop boolean not null default true,
  notes_ar text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint schema_inventory_decisions_unique unique (batch_key, source_schema, object_name)
);

create index if not exists idx_schema_inventory_decisions_source
  on platform.schema_inventory_decisions(source_schema, object_name);

create index if not exists idx_schema_inventory_decisions_classification
  on platform.schema_inventory_decisions(classification, action_status, risk_level);

alter table platform.schema_inventory_decisions enable row level security;

comment on table platform.schema_inventory_decisions is
  'Governance register for database schema ownership, quarantine, and realignment decisions. This table records decisions only; it does not authorize automatic deletion or movement.';

comment on column platform.schema_inventory_decisions.no_auto_drop is
  'Safety flag. True means the object must not be deleted automatically; manual approval and dependency evidence are required.';

insert into platform.schema_inventory_decisions (
  batch_key, source_schema, object_name, object_type,
  current_owner_system, recommended_owner_system,
  classification, decision, action_status, risk_level,
  dependency_status, rls_status, rpc_usage_status, flutter_usage_status,
  no_auto_drop, notes_ar
) values
('N2.23','public','org_units','view','public compatibility','core','compatibility_wrapper','realign_to_core_view','ready_for_sql','high','checked_partially','not_applicable','checked_partially','direct_usage_found_before_patch',true,'إبقاء view توافقية فوق core.org_units مع unit_type::text'),
('N2.23','public','pwf_org_units_cache','table','legacy cache','core','cache_deprecate','quarantine_after_dependency_zero','planned','high','required','required','required','required',true,'ليس مصدر حقيقة للوحدات التنظيمية'),
('N2.23','public','org_units_cache','table','legacy cache','core','cache_deprecate','quarantine_after_dependency_zero','planned','high','required','required','required','required',true,'ليس مصدر حقيقة للوحدات التنظيمية'),
('N2.23','public','locations','table','unknown','gis','source_conflict','locations_audit_required','planned','medium','required','required','required','required',true,'تعارض محتمل مع gis.locations؛ لا تصحيح قبل Audit'),
('N2.23','core','stg_community_waqf_excel_raw','table','core staging','staging_archive','staging_archive_candidate','archive_after_dependencies','planned','medium','required','required','required','required',true,'جدول staging لا ينقل قبل فحص الاعتمادات'),
('N2.23','core','stg_community_waqf_excel_raw_v2','table','core staging','staging_archive','staging_archive_candidate','archive_after_dependencies','planned','medium','required','required','required','required',true,'جدول staging لا ينقل قبل فحص الاعتمادات'),
('N2.23','core','stg_community_waqf_legacy_import','table','core staging','staging_archive','legacy_archive_candidate','archive_after_dependencies','planned','medium','required','required','required','required',true,'استيراد legacy لا ينقل قبل فحص الاعتمادات'),
('N2.23','public','user_system_roles','table','public transitional RBAC','platform','transitional_contract','keep_until_rbac_migration','active','high','required','required','required','direct_usage_confirmed',true,'جدول RBAC انتقالي لا يكسر في N2.23'),
('N2.23','public','user_system_permissions','table','public transitional RBAC','platform','transitional_contract','keep_until_rbac_migration','active','high','required','required','required','direct_usage_confirmed',true,'جدول RBAC انتقالي لا يكسر في N2.23')
on conflict (batch_key, source_schema, object_name) do update set
  current_owner_system = excluded.current_owner_system,
  recommended_owner_system = excluded.recommended_owner_system,
  classification = excluded.classification,
  decision = excluded.decision,
  action_status = excluded.action_status,
  risk_level = excluded.risk_level,
  dependency_status = excluded.dependency_status,
  rls_status = excluded.rls_status,
  rpc_usage_status = excluded.rpc_usage_status,
  flutter_usage_status = excluded.flutter_usage_status,
  no_auto_drop = excluded.no_auto_drop,
  notes_ar = excluded.notes_ar,
  updated_at = now();
