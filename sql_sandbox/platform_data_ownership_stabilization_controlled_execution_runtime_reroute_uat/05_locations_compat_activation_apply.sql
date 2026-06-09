-- 05_locations_compat_activation_apply.sql
-- APPLY. Activates locations compatibility wrappers without changing gis/core/public legacy storage.
-- core remains administrative authority; gis remains geometry/spatial authority; public exposes compatibility only.

begin;

create or replace view public.v_locations_compat_v1 as
select
  coalesce(
    nullif(to_jsonb(l)->>'id',''),
    nullif(to_jsonb(l)->>'uuid',''),
    nullif(to_jsonb(l)->>'objectid',''),
    md5(to_jsonb(l)::text)
  )::text as id,
  coalesce(
    nullif(to_jsonb(l)->>'name_ar',''),
    nullif(to_jsonb(l)->>'arabic_name',''),
    nullif(to_jsonb(l)->>'name',''),
    nullif(to_jsonb(l)->>'location_name',''),
    'موقع بدون اسم'
  )::text as name_ar,
  nullif(coalesce(to_jsonb(l)->>'name_en', to_jsonb(l)->>'english_name'), '')::text as name_en,
  coalesce(
    nullif(to_jsonb(l)->>'location_type',''),
    nullif(to_jsonb(l)->>'type',''),
    'spatial_location'
  )::text as location_type,
  nullif(coalesce(to_jsonb(l)->>'governorate_key', to_jsonb(l)->>'governorate_code', to_jsonb(l)->>'governorate'), '')::text as governorate_key,
  nullif(coalesce(to_jsonb(l)->>'lgu_key', to_jsonb(l)->>'lgu_code', to_jsonb(l)->>'lgu'), '')::text as lgu_key,
  to_jsonb(l) as metadata,
  'gis.locations'::text as source_contract,
  'public.v_locations_compat_v1'::text as compatibility_contract
from gis.locations l;

create or replace function public.rpc_locations_compat_v1(
  p_search text default null,
  p_location_type text default null,
  p_limit integer default 50,
  p_offset integer default 0
)
returns table (
  id text,
  name_ar text,
  name_en text,
  location_type text,
  governorate_key text,
  lgu_key text,
  metadata jsonb,
  source_contract text,
  compatibility_contract text
)
language sql
stable
security invoker
as $$
  select
    v.id,
    v.name_ar,
    v.name_en,
    v.location_type,
    v.governorate_key,
    v.lgu_key,
    v.metadata,
    v.source_contract,
    v.compatibility_contract
  from public.v_locations_compat_v1 v
  where (p_location_type is null or v.location_type = p_location_type)
    and (
      p_search is null
      or v.name_ar ilike '%' || p_search || '%'
      or coalesce(v.name_en,'') ilike '%' || p_search || '%'
    )
  order by v.name_ar
  limit least(greatest(coalesce(p_limit, 50), 1), 200)
  offset greatest(coalesce(p_offset, 0), 0)
$$;

grant select on public.v_locations_compat_v1 to anon, authenticated;
grant execute on function public.rpc_locations_compat_v1(text,text,integer,integer) to anon, authenticated;

comment on view public.v_locations_compat_v1 is 'Compatibility wrapper over gis.locations. gis remains spatial authority; public is not sovereign storage.';
comment on function public.rpc_locations_compat_v1(text,text,integer,integer) is 'Read-only locations compatibility lookup over gis.locations.';

commit;

select
  'locations_compat_activation_result' as section,
  'public.v_locations_compat_v1' as contract_name,
  to_regclass('public.v_locations_compat_v1') is not null as present,
  (select count(*) from public.v_locations_compat_v1)::bigint as row_count
union all
select
  'locations_compat_activation_result',
  'public.rpc_locations_compat_v1(text,text,integer,integer)',
  to_regprocedure('public.rpc_locations_compat_v1(text,text,integer,integer)') is not null,
  null::bigint;
