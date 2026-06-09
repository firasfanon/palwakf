-- N2.21.1 DRAFT ONLY — public.org_units compatibility view type safety.
-- Run only after approval and dependency review.
-- Keeps existing public.org_units column names/order/types; unit_type remains text.

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
  u.is_active,
  coalesce(u.sort_order, 0) as sort_order,
  u.created_at,
  u.updated_at
from core.org_units u;

comment on view public.org_units is
  'Compatibility view over core.org_units. Do not use cache as source-of-truth. unit_type intentionally text for existing public contract.';

comment on table public.pwf_org_units_cache is
  'DEPRECATED after N2.22: not source-of-truth. Do not use for Dashboard/RBAC/Dynamic Registry. Pending archive after dependencies zero.';

comment on table public.org_units_cache is
  'DEPRECATED after N2.22: not source-of-truth. Pending archive after dependencies zero.';

create or replace function public.rpc_org_units_core_lookup_v1(p_query text default null, p_include_inactive boolean default true)
returns table(
  id uuid,
  unit_type text,
  parent_id uuid,
  governorate_id uuid,
  code text,
  slug text,
  name_ar text,
  name_en text,
  is_active boolean,
  sort_order integer,
  created_at timestamptz,
  updated_at timestamptz
)
language sql
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
    u.is_active,
    coalesce(u.sort_order, 0),
    u.created_at,
    u.updated_at
  from core.org_units u
  where (p_include_inactive or coalesce(u.is_active, true))
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
