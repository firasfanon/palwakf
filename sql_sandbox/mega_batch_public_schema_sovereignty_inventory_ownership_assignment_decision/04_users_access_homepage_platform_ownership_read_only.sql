
-- Script 04: Users/access/homepage platform ownership read-only
-- Purpose: highlight high-risk public objects that require careful migration contracts.

with targets(object_name, target_owner, risk_level, required_contract) as (
  values
    ('admin_users','core','high','auth.users linkage + core user profile + platform access contract'),
    ('user_profiles','core','high','auth.users linkage + profile compatibility view'),
    ('profiles','core','high','auth.users linkage + profile compatibility view'),
    ('user_system_roles','platform','critical','system registry role contract + RLS + role UAT'),
    ('user_system_permissions','platform','critical','permission registry contract + RLS + role UAT'),
    ('roles','platform','critical','RBAC contract'),
    ('permissions','platform','critical','RBAC contract'),
    ('homepage_sections','platform','medium','PWF-SIS public homepage sections contract'),
    ('header_settings','platform','medium','platform public shell settings contract'),
    ('footer_settings','platform','medium','platform public shell settings contract'),
    ('site_pages','platform','medium','platform content/page registry contract'),
    ('visual_identity_overrides','platform','medium','theme/visual identity override contract')
), presence as (
  select
    t.*,
    exists (
      select 1
      from pg_catalog.pg_class c
      join pg_catalog.pg_namespace n on n.oid = c.relnamespace
      where n.nspname = 'public' and c.relname = t.object_name
    ) as public_object_present
  from targets t
)
select
  'users_access_homepage_platform_ownership_review' as section,
  object_name,
  public_object_present,
  target_owner,
  risk_level,
  required_contract,
  case
    when public_object_present and target_owner='core' then 'MIGRATE_TO_CORE_WITH_AUTH_LINK_COMPATIBILITY'
    when public_object_present and target_owner='platform' then 'MIGRATE_TO_PLATFORM_WITH_PUBLIC_COMPATIBILITY'
    else 'NOT_PRESENT_OR_ALREADY_MOVED_REVIEW_ONLY'
  end as decision
from presence
order by risk_level desc, target_owner, object_name;
