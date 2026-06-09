-- PalWakf Admin Stabilization
-- Home Management Units: make dropdown unit-aware & slug-consistent.
--
-- Rationale:
-- - core.org_units.code != home_config.id (home_config uses slug)
-- - core.org_units.slug is the correct join key
--
-- Result:
-- - v_admin_home_units returns 44 units with has_home_config flag.

create or replace view public.v_admin_home_units as
select
  ou.id        as unit_id,
  ou.code      as unit_code,
  ou.slug      as slug,
  ou.name_ar   as name_ar,
  ou.unit_type as unit_type,
  ou.is_active as is_active,
  (hc.id is not null) as has_home_config,
  hc.updated_at as home_updated_at
from core.org_units ou
left join public.home_config hc
  on hc.id = ou.slug
order by
  ou.is_active desc,
  ou.unit_type,
  ou.name_ar;
