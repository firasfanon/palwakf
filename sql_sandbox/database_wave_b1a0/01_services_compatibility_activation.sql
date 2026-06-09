-- Database Wave B-1A.0
-- Services Compatibility Activation
-- Scope: read-only public compatibility facades for service catalog legacy objects.
-- Non-breaking: does not move, delete, rename, or mutate legacy service tables.
-- Sovereign boundary: no waqf, waqf_assets, awqaf_system, cases, billing, media, or locations mutation.

begin;

create or replace view public.v_services_catalog_compat_v1 as
with src as (
  select to_jsonb(s) as raw_payload
  from public.services as s
)
select
  coalesce(
    raw_payload ->> 'service_key',
    raw_payload ->> 'service_id',
    raw_payload ->> 'id',
    raw_payload ->> 'code',
    raw_payload ->> 'slug',
    md5(raw_payload::text)
  )::text as service_key,
  coalesce(
    raw_payload ->> 'title_ar',
    raw_payload ->> 'name_ar',
    raw_payload ->> 'service_name_ar',
    raw_payload ->> 'title',
    raw_payload ->> 'name',
    raw_payload ->> 'label_ar'
  )::text as title_ar,
  coalesce(
    raw_payload ->> 'title_en',
    raw_payload ->> 'name_en',
    raw_payload ->> 'service_name_en',
    raw_payload ->> 'label_en'
  )::text as title_en,
  coalesce(
    raw_payload ->> 'description_ar',
    raw_payload ->> 'summary_ar',
    raw_payload ->> 'description',
    raw_payload ->> 'summary'
  )::text as description_ar,
  coalesce(
    raw_payload ->> 'description_en',
    raw_payload ->> 'summary_en'
  )::text as description_en,
  coalesce(
    raw_payload ->> 'category_key',
    raw_payload ->> 'category',
    raw_payload ->> 'service_type',
    raw_payload ->> 'type_key'
  )::text as category_key,
  coalesce(
    raw_payload ->> 'route_path',
    raw_payload ->> 'path',
    raw_payload ->> 'url',
    raw_payload ->> 'link'
  )::text as route_path,
  case
    when lower(coalesce(raw_payload ->> 'is_active', raw_payload ->> 'active', raw_payload ->> 'enabled', 'true')) in ('true', '1', 'yes', 'published', 'active') then true
    else false
  end as is_active,
  case
    when coalesce(raw_payload ->> 'display_order', raw_payload ->> 'sort_order', raw_payload ->> 'order_index', raw_payload ->> 'order') ~ '^[0-9]+$'
      then coalesce(raw_payload ->> 'display_order', raw_payload ->> 'sort_order', raw_payload ->> 'order_index', raw_payload ->> 'order')::integer
    else null
  end as display_order,
  'public.services'::text as legacy_source,
  'platform_services'::text as target_owner_schema,
  'service_center'::text as owner_system,
  raw_payload
from src;

create or replace view public.v_service_types_compat_v1 as
with src as (
  select to_jsonb(t) as raw_payload
  from public.servicetypes as t
)
select
  coalesce(raw_payload ->> 'type_key', raw_payload ->> 'service_type_key', raw_payload ->> 'id', raw_payload ->> 'code', raw_payload ->> 'slug', md5(raw_payload::text))::text as type_key,
  coalesce(raw_payload ->> 'title_ar', raw_payload ->> 'name_ar', raw_payload ->> 'title', raw_payload ->> 'name', raw_payload ->> 'label_ar')::text as title_ar,
  coalesce(raw_payload ->> 'title_en', raw_payload ->> 'name_en', raw_payload ->> 'label_en')::text as title_en,
  case
    when lower(coalesce(raw_payload ->> 'is_active', raw_payload ->> 'active', raw_payload ->> 'enabled', 'true')) in ('true', '1', 'yes', 'published', 'active') then true
    else false
  end as is_active,
  'public.servicetypes'::text as legacy_source,
  'platform_services'::text as target_owner_schema,
  'service_center'::text as owner_system,
  raw_payload
from src;

create or replace view public.v_service_providers_compat_v1 as
with src as (
  select to_jsonb(p) as raw_payload
  from public.serviceproviders as p
)
select
  coalesce(raw_payload ->> 'provider_key', raw_payload ->> 'provider_id', raw_payload ->> 'id', raw_payload ->> 'code', raw_payload ->> 'slug', md5(raw_payload::text))::text as provider_key,
  coalesce(raw_payload ->> 'title_ar', raw_payload ->> 'name_ar', raw_payload ->> 'provider_name_ar', raw_payload ->> 'title', raw_payload ->> 'name', raw_payload ->> 'label_ar')::text as title_ar,
  coalesce(raw_payload ->> 'title_en', raw_payload ->> 'name_en', raw_payload ->> 'provider_name_en', raw_payload ->> 'label_en')::text as title_en,
  coalesce(raw_payload ->> 'contact_phone', raw_payload ->> 'phone', raw_payload ->> 'mobile')::text as contact_phone,
  coalesce(raw_payload ->> 'contact_email', raw_payload ->> 'email')::text as contact_email,
  case
    when lower(coalesce(raw_payload ->> 'is_active', raw_payload ->> 'active', raw_payload ->> 'enabled', 'true')) in ('true', '1', 'yes', 'published', 'active') then true
    else false
  end as is_active,
  'public.serviceproviders'::text as legacy_source,
  'platform_services_or_facilities'::text as target_owner_schema,
  'service_center'::text as owner_system,
  raw_payload
from src;

create or replace view public.v_service_points_compat_v1 as
with src as (
  select to_jsonb(p) as raw_payload
  from public.servicepoints as p
)
select
  coalesce(raw_payload ->> 'point_key', raw_payload ->> 'service_point_key', raw_payload ->> 'point_id', raw_payload ->> 'id', raw_payload ->> 'code', raw_payload ->> 'slug', md5(raw_payload::text))::text as point_key,
  coalesce(raw_payload ->> 'title_ar', raw_payload ->> 'name_ar', raw_payload ->> 'point_name_ar', raw_payload ->> 'title', raw_payload ->> 'name', raw_payload ->> 'label_ar')::text as title_ar,
  coalesce(raw_payload ->> 'title_en', raw_payload ->> 'name_en', raw_payload ->> 'point_name_en', raw_payload ->> 'label_en')::text as title_en,
  coalesce(raw_payload ->> 'address_ar', raw_payload ->> 'address', raw_payload ->> 'location_ar')::text as address_ar,
  coalesce(raw_payload ->> 'address_en', raw_payload ->> 'location_en')::text as address_en,
  coalesce(raw_payload ->> 'governorate_key', raw_payload ->> 'governorate', raw_payload ->> 'governorate_id')::text as governorate_key,
  coalesce(raw_payload ->> 'lgu_key', raw_payload ->> 'lgu_id', raw_payload ->> 'locality_id')::text as lgu_key,
  case
    when lower(coalesce(raw_payload ->> 'is_active', raw_payload ->> 'active', raw_payload ->> 'enabled', 'true')) in ('true', '1', 'yes', 'published', 'active') then true
    else false
  end as is_active,
  'public.servicepoints'::text as legacy_source,
  'platform_services_or_facilities_or_gis'::text as target_owner_schema,
  'service_center'::text as owner_system,
  raw_payload
from src;

create or replace view public.v_home_services_compat_v1 as
with src as (
  select to_jsonb(h) as raw_payload
  from public.home_services as h
)
select
  coalesce(raw_payload ->> 'home_service_key', raw_payload ->> 'service_key', raw_payload ->> 'service_id', raw_payload ->> 'id', raw_payload ->> 'code', raw_payload ->> 'slug', md5(raw_payload::text))::text as home_service_key,
  coalesce(raw_payload ->> 'title_ar', raw_payload ->> 'name_ar', raw_payload ->> 'service_name_ar', raw_payload ->> 'title', raw_payload ->> 'name', raw_payload ->> 'label_ar')::text as title_ar,
  coalesce(raw_payload ->> 'title_en', raw_payload ->> 'name_en', raw_payload ->> 'service_name_en', raw_payload ->> 'label_en')::text as title_en,
  coalesce(raw_payload ->> 'description_ar', raw_payload ->> 'summary_ar', raw_payload ->> 'description', raw_payload ->> 'summary')::text as description_ar,
  coalesce(raw_payload ->> 'route_path', raw_payload ->> 'path', raw_payload ->> 'url', raw_payload ->> 'link')::text as route_path,
  case
    when lower(coalesce(raw_payload ->> 'is_active', raw_payload ->> 'active', raw_payload ->> 'enabled', 'true')) in ('true', '1', 'yes', 'published', 'active') then true
    else false
  end as is_active,
  case
    when coalesce(raw_payload ->> 'display_order', raw_payload ->> 'sort_order', raw_payload ->> 'order_index', raw_payload ->> 'order') ~ '^[0-9]+$'
      then coalesce(raw_payload ->> 'display_order', raw_payload ->> 'sort_order', raw_payload ->> 'order_index', raw_payload ->> 'order')::integer
    else null
  end as display_order,
  'public.home_services'::text as legacy_source,
  'platform_services_or_platform_content'::text as target_owner_schema,
  'service_center'::text as owner_system,
  raw_payload
from src;

create or replace function public.rpc_services_catalog_compat_v1()
returns table (
  service_key text,
  title_ar text,
  title_en text,
  description_ar text,
  description_en text,
  category_key text,
  route_path text,
  is_active boolean,
  display_order integer,
  legacy_source text,
  target_owner_schema text,
  owner_system text,
  raw_payload jsonb
)
language sql
stable
as $$
  select
    service_key,
    title_ar,
    title_en,
    description_ar,
    description_en,
    category_key,
    route_path,
    is_active,
    display_order,
    legacy_source,
    target_owner_schema,
    owner_system,
    raw_payload
  from public.v_services_catalog_compat_v1
  order by display_order nulls last, title_ar nulls last, service_key;
$$;

create or replace function public.rpc_home_services_compat_v1()
returns table (
  home_service_key text,
  title_ar text,
  title_en text,
  description_ar text,
  route_path text,
  is_active boolean,
  display_order integer,
  legacy_source text,
  target_owner_schema text,
  owner_system text,
  raw_payload jsonb
)
language sql
stable
as $$
  select
    home_service_key,
    title_ar,
    title_en,
    description_ar,
    route_path,
    is_active,
    display_order,
    legacy_source,
    target_owner_schema,
    owner_system,
    raw_payload
  from public.v_home_services_compat_v1
  order by display_order nulls last, title_ar nulls last, home_service_key;
$$;

comment on view public.v_services_catalog_compat_v1 is 'Wave B-1A.0 service catalog compatibility facade. Read-only facade over public.services; no sovereign extraction.';
comment on view public.v_service_types_compat_v1 is 'Wave B-1A.0 service taxonomy compatibility facade. Read-only facade over public.servicetypes.';
comment on view public.v_service_providers_compat_v1 is 'Wave B-1A.0 service providers compatibility facade. Owner decision still requires platform_services/facilities mapping.';
comment on view public.v_service_points_compat_v1 is 'Wave B-1A.0 service points compatibility facade. Owner decision still requires platform_services/facilities/GIS mapping.';
comment on view public.v_home_services_compat_v1 is 'Wave B-1A.0 home services compatibility facade. Homepage coupling must be validated before runtime reroute.';
comment on function public.rpc_services_catalog_compat_v1() is 'Wave B-1A.0 read-only service catalog compatibility RPC.';
comment on function public.rpc_home_services_compat_v1() is 'Wave B-1A.0 read-only home services compatibility RPC.';

do $$
begin
  if exists (select 1 from pg_roles where rolname = 'anon') then
    execute 'grant select on public.v_services_catalog_compat_v1 to anon';
    execute 'grant select on public.v_service_types_compat_v1 to anon';
    execute 'grant select on public.v_service_providers_compat_v1 to anon';
    execute 'grant select on public.v_service_points_compat_v1 to anon';
    execute 'grant select on public.v_home_services_compat_v1 to anon';
    execute 'grant execute on function public.rpc_services_catalog_compat_v1() to anon';
    execute 'grant execute on function public.rpc_home_services_compat_v1() to anon';
  end if;

  if exists (select 1 from pg_roles where rolname = 'authenticated') then
    execute 'grant select on public.v_services_catalog_compat_v1 to authenticated';
    execute 'grant select on public.v_service_types_compat_v1 to authenticated';
    execute 'grant select on public.v_service_providers_compat_v1 to authenticated';
    execute 'grant select on public.v_service_points_compat_v1 to authenticated';
    execute 'grant select on public.v_home_services_compat_v1 to authenticated';
    execute 'grant execute on function public.rpc_services_catalog_compat_v1() to authenticated';
    execute 'grant execute on function public.rpc_home_services_compat_v1() to authenticated';
  end if;
end $$;

notify pgrst, 'reload schema';

commit;
