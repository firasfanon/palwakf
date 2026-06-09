-- Mega Batch N2.21 — Core Org Units Wrapper Realignment
-- DDL-only compatibility realignment. No DML against sovereign waqf/waqf_assets/awqaf_system.
-- Goal: public.org_units remains a compatibility VIEW, but its source is core.org_units, not any public cache.

create or replace view public.org_units as
select
  id,
  unit_type,
  parent_id,
  governorate_id,
  code,
  slug,
  name_ar,
  name_en,
  is_active,
  sort_order,
  created_at,
  updated_at
from core.org_units;

comment on view public.org_units is
  'Compatibility wrapper over core.org_units. Source-of-truth is core.org_units. Do not repoint this view to public caches.';

comment on table public.pwf_org_units_cache is
  'Deprecated compatibility cache. Not a source-of-truth for PalWakf organizational units. Use core.org_units via public RPC/views.';

comment on table public.org_units_cache is
  'Deprecated compatibility cache. Not a source-of-truth for PalWakf organizational units. Use core.org_units via public RPC/views.';

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
