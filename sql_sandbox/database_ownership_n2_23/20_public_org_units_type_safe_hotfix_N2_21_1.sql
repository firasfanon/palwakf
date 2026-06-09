-- Hotfix N2.21.1 — public.org_units Compatibility View Type Safety
-- Preserves public.org_units column order and types.
-- Fixes previous 42P16 error by casting core.org_units.unit_type to text.
-- No DML against waqf, waqf_assets, awqaf_system.

create or replace view public.org_units as
select
  u.id,
  u.unit_type::text as unit_type,
  u.parent_id,
  u.governorate_id,
  u.code,
  u.slug,
  u.name_ar,
  u.name_en,
  coalesce(u.is_active, true) as is_active,
  coalesce(u.sort_order, 0) as sort_order,
  u.created_at,
  u.updated_at
from core.org_units u;

comment on view public.org_units is
  'Compatibility wrapper over core.org_units. Source-of-truth is core.org_units. Column unit_type is intentionally exposed as text to preserve the existing public contract.';

comment on table public.pwf_org_units_cache is
  'Deprecated compatibility cache. Not a source-of-truth for PalWakf organizational units. Do not use for Dashboard/RBAC/Dynamic Registry. Candidate for quarantine after dependency zero.';

comment on table public.org_units_cache is
  'Deprecated compatibility cache. Not a source-of-truth for PalWakf organizational units. Candidate for quarantine after dependency zero.';

create or replace function public.rpc_org_units_core_lookup_v1(
  p_unit_ids uuid[] default null,
  p_only_active boolean default false,
  p_query text default null
)
returns table(
  id uuid,
  unit_type text,
  parent_id uuid,
  governorate_id uuid,
  code text,
  slug text,
  name_ar text,
  name_en text,
  login_key text,
  is_active boolean,
  sort_order integer,
  created_at timestamptz,
  updated_at timestamptz
)
language sql
stable
security definer
set search_path to 'public','core','pg_temp'
as $$
  select
    u.id,
    u.unit_type::text as unit_type,
    u.parent_id,
    u.governorate_id,
    u.code,
    u.slug,
    u.name_ar,
    u.name_en,
    to_jsonb(u) ->> 'login_key' as login_key,
    coalesce(u.is_active, true) as is_active,
    coalesce(u.sort_order, 0) as sort_order,
    u.created_at,
    u.updated_at
  from core.org_units u
  where
    (p_unit_ids is null or cardinality(p_unit_ids) = 0 or u.id = any(p_unit_ids))
    and (not p_only_active or coalesce(u.is_active, true) is true)
    and (
      p_query is null
      or btrim(p_query) = ''
      or coalesce(u.name_ar, '') ilike '%' || btrim(p_query) || '%'
      or coalesce(u.name_en, '') ilike '%' || btrim(p_query) || '%'
      or coalesce(u.slug, '') ilike '%' || btrim(p_query) || '%'
      or coalesce(u.code, '') ilike '%' || btrim(p_query) || '%'
    )
  order by coalesce(u.sort_order, 0), coalesce(u.name_ar, '');
$$;

comment on function public.rpc_org_units_core_lookup_v1(uuid[], boolean, text) is
  'Core-backed organizational unit lookup for Dashboard/Users/RBAC. Avoids direct Flutter reads from core and avoids public cache sources.';

grant execute on function public.rpc_org_units_core_lookup_v1(uuid[], boolean, text) to anon, authenticated;
