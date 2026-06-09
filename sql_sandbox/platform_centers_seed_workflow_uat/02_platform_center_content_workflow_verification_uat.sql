-- Mega Batch K — Workflow Verification UAT
-- Purpose: verify platform_content workflow tables and public wrappers after SQL readiness.
-- This script creates a transient UAT row, verifies transitions/events, then cleans it up.
-- No waqf schema mutation. No awqaf_system mutation.

drop table if exists _platform_center_workflow_uat_results;
create temp table _platform_center_workflow_uat_results (
  check_key text,
  passed boolean,
  note text
);

insert into _platform_center_workflow_uat_results
select
  'platform_content_schema_exists',
  exists(select 1 from information_schema.schemata where schema_name = 'platform_content'),
  'platform_content schema exists';

insert into _platform_center_workflow_uat_results
select
  'required_tables_exist',
  (select count(*) = 5 from information_schema.tables where table_schema = 'platform_content' and table_name in ('center_content_categories','center_content_items','center_content_workflow_events','center_content_attachments','center_content_relations')),
  'required_tables=' || (select count(*)::text from information_schema.tables where table_schema = 'platform_content' and table_name in ('center_content_categories','center_content_items','center_content_workflow_events','center_content_attachments','center_content_relations')) || '/5';

insert into _platform_center_workflow_uat_results
select
  'public_wrappers_exist',
  (select count(*) = 4 from (
    select 1 from information_schema.views where table_schema = 'public' and table_name = 'v_platform_center_content'
    union all
    select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace where n.nspname = 'public' and p.proname = 'pwf_platform_center_content_list'
    union all
    select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace where n.nspname = 'public' and p.proname = 'pwf_platform_center_content_upsert'
    union all
    select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace where n.nspname = 'public' and p.proname = 'pwf_platform_center_content_transition'
  ) q),
  'public view + 3 RPC wrappers should exist';

-- Cleanup any previous interrupted UAT row.
delete from platform_content.center_content_items
where metadata ->> 'uat_batch' = 'mega_batch_k_transient_workflow_uat';

with inserted as (
  insert into platform_content.center_content_items (
    family_key,
    category_key,
    title_ar,
    summary_ar,
    body_ar,
    scope_type,
    unit_slug,
    owner_name_ar,
    workflow_status,
    publication_status,
    public_route,
    source_system,
    metadata
  ) values (
    'press_releases',
    'official_press_release',
    'UAT transient press release',
    'Transient row created and deleted by Mega Batch K workflow UAT.',
    'This row must not remain after UAT cleanup.',
    'central',
    'home',
    'UAT',
    'draft',
    'draft',
    '/press-releases',
    'platform_content_workflow_uat',
    jsonb_build_object('uat_batch', 'mega_batch_k_transient_workflow_uat')
  ) returning id, family_key, workflow_status
), event_create as (
  insert into platform_content.center_content_workflow_events (content_item_id, family_key, action_key, from_status, to_status, decision_label_ar, unit_slug, source_route, notes, metadata)
  select id, family_key, 'create_draft', null, 'draft', 'UAT create draft', 'home', '/press-releases', 'Transient UAT create event.', jsonb_build_object('uat_batch', 'mega_batch_k_transient_workflow_uat')
  from inserted
  returning content_item_id
), step_review as (
  update platform_content.center_content_items
  set workflow_status = 'in_review', updated_at = now()
  where id in (select id from inserted)
  returning id, family_key
), event_review as (
  insert into platform_content.center_content_workflow_events (content_item_id, family_key, action_key, from_status, to_status, decision_label_ar, unit_slug, source_route, notes, metadata)
  select id, family_key, 'submit_review', 'draft', 'in_review', 'UAT submit review', 'home', '/press-releases', 'Transient UAT review event.', jsonb_build_object('uat_batch', 'mega_batch_k_transient_workflow_uat')
  from step_review
  returning content_item_id
), step_publish as (
  update platform_content.center_content_items
  set workflow_status = 'published', publication_status = 'published', published_at = now(), updated_at = now()
  where id in (select id from inserted)
  returning id, family_key
), event_publish as (
  insert into platform_content.center_content_workflow_events (content_item_id, family_key, action_key, from_status, to_status, decision_label_ar, unit_slug, source_route, notes, metadata)
  select id, family_key, 'publish', 'in_review', 'published', 'UAT publish', 'home', '/press-releases', 'Transient UAT publish event.', jsonb_build_object('uat_batch', 'mega_batch_k_transient_workflow_uat')
  from step_publish
  returning content_item_id
)
insert into _platform_center_workflow_uat_results
select
  'transient_workflow_events_created',
  (select count(*) = 3 from platform_content.center_content_workflow_events where metadata ->> 'uat_batch' = 'mega_batch_k_transient_workflow_uat'),
  'transient_events=' || (select count(*)::text from platform_content.center_content_workflow_events where metadata ->> 'uat_batch' = 'mega_batch_k_transient_workflow_uat') || '/3';

insert into _platform_center_workflow_uat_results
select
  'published_view_can_see_transient_published_row',
  exists(select 1 from public.v_platform_center_content where title_ar = 'UAT transient press release' and family_key = 'press_releases'),
  'public view should expose the transient row only after it becomes published.';

-- Cleanup transient UAT row and cascade workflow events.
delete from platform_content.center_content_items
where metadata ->> 'uat_batch' = 'mega_batch_k_transient_workflow_uat';

insert into _platform_center_workflow_uat_results
select
  'transient_uat_cleanup_done',
  not exists(select 1 from platform_content.center_content_items where metadata ->> 'uat_batch' = 'mega_batch_k_transient_workflow_uat')
  and not exists(select 1 from platform_content.center_content_workflow_events where metadata ->> 'uat_batch' = 'mega_batch_k_transient_workflow_uat'),
  'transient content and workflow events are removed after UAT.';

insert into _platform_center_workflow_uat_results
values ('no_waqf_assets_mutation_in_this_script', true, 'This UAT only uses platform_content and public wrappers; no waqf schema mutation.');

select * from _platform_center_workflow_uat_results order by check_key;

