-- N2.22 DRAFT ONLY — do not run without approval.
-- Purpose: create governance registers for schema inventory decisions.

create schema if not exists platform;

create table if not exists platform.schema_inventory_decisions (
  id uuid primary key default gen_random_uuid(),
  schema_name text not null,
  object_name text not null,
  object_type text not null,
  current_owner_system text,
  recommended_owner_system text,
  classification text not null,
  decision text not null default 'pending_review',
  risk_level text not null default 'medium',
  dependency_count integer,
  flutter_usage_count integer,
  action_required text,
  migration_wave text,
  migration_sql_ref text,
  rollback_sql_ref text,
  approved_by uuid,
  approved_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(schema_name, object_name, object_type)
);

comment on table platform.schema_inventory_decisions is
  'Governed register for PalWakf database object ownership, quarantine, migration, and deletion decisions.';
