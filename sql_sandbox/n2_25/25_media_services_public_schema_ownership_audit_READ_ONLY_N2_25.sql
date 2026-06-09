-- N2.25 - Media/Services Ownership Audit
-- READ ONLY. No DML.

with targets(table_name, proposed_owner, family) as (
  values
    ('news','media_center','media'),
    ('news_articles','media_center','media'),
    ('news_items','media_center','media'),
    ('announcements','media_center','media'),
    ('announcement_items','media_center','media'),
    ('activities','media_center','media'),
    ('media_gallery_items','media_center','media'),
    ('breaking_news','media_center','media'),
    ('media_center_audit_events','media_center','media'),
    ('media_center_editorial_events','media_center','media'),
    ('media_center_editorial_roles','media_center','media'),
    ('media_center_permission_uat_events','media_center_or_governance','media'),
    ('media_center_publishing_governance_rules','media_center','media'),
    ('services','platform_services','services'),
    ('servicepoints','platform_services_or_facilities_module','services'),
    ('serviceproviders','platform_services_or_facilities_module','services'),
    ('servicetypes','platform_services_or_facilities_module','services'),
    ('home_services','platform_services_or_platform_content','services')
),
existing as (
  select
    t.table_name,
    t.proposed_owner,
    t.family,
    c.table_schema,
    c.table_type
  from targets t
  left join information_schema.tables c
    on c.table_schema = 'public'
   and c.table_name = t.table_name
),
rls as (
  select
    schemaname as table_schema,
    tablename as table_name,
    count(*) as rls_policy_count
  from pg_policies
  where schemaname = 'public'
  group by schemaname, tablename
)
select
  'media_services_ownership_audit' as section,
  e.family,
  e.table_schema,
  e.table_name,
  e.table_type,
  e.proposed_owner,
  coalesce(r.rls_policy_count, 0) as rls_policy_count,
  case
    when e.table_schema is null then 'not_found'
    when coalesce(r.rls_policy_count,0) > 0 then 'do_not_move_without_rls_migration_plan'
    else 'manual_review_before_move'
  end as movement_gate
from existing e
left join rls r on r.table_schema=e.table_schema and r.table_name=e.table_name
order by e.family, e.table_name;
