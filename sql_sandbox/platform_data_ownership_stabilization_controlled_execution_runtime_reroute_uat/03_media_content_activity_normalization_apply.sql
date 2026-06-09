-- 03_media_content_activity_normalization_apply.sql
-- APPLY. Idempotently stabilizes public.activities under media_center.content_items.
-- It does not delete or mutate public.activities. It makes legacy public activity rows visible through the compatibility wrapper when safe.

begin;

-- Insert any missing public.activities rows that were not included in previous controlled seed.
insert into media_center.content_items (
  legacy_source,
  legacy_source_id,
  content_key,
  content_type,
  title_ar,
  title_en,
  summary_ar,
  summary_en,
  body_ar,
  body_en,
  category_key,
  status,
  visibility_scope,
  source_public_table,
  published_at,
  metadata
)
select
  'public.activities',
  coalesce(j->>'id', j->>'uuid', md5(j::text)),
  'legacy_activities_' || coalesce(j->>'id', j->>'uuid', md5(j::text)),
  'activity',
  coalesce(nullif(j->>'title_ar',''), nullif(j->>'title',''), nullif(j->>'name_ar',''), 'نشاط بدون عنوان'),
  nullif(coalesce(j->>'title_en', j->>'name_en'), ''),
  nullif(coalesce(j->>'summary_ar', j->>'description_ar', j->>'summary', j->>'description'), ''),
  nullif(coalesce(j->>'summary_en', j->>'description_en'), ''),
  nullif(coalesce(j->>'body_ar', j->>'content_ar', j->>'body', j->>'content', j->>'description'), ''),
  nullif(coalesce(j->>'body_en', j->>'content_en'), ''),
  coalesce(nullif(j->>'category_key',''), nullif(j->>'category',''), 'activity'),
  case
    when lower(coalesce(j->>'status', j->>'publish_status', '')) in ('draft','archived','rejected','inactive','deleted') then 'draft'
    else 'published'
  end,
  'public',
  'public.activities',
  coalesce(
    case when nullif(coalesce(j->>'published_at', j->>'event_date', j->>'start_date', j->>'created_at'), '') ~ '^\d{4}-\d{2}-\d{2}'
      then nullif(coalesce(j->>'published_at', j->>'event_date', j->>'start_date', j->>'created_at'), '')::timestamptz
      else null end,
    now()
  ),
  jsonb_build_object(
    'legacy_payload', j,
    'controlled_execution_batch', 'platform_data_ownership_stabilization_controlled_execution',
    'seed_scope', 'activities'
  )
from (select to_jsonb(s) as j from public.activities s) q
where not exists (
  select 1 from media_center.content_items ci
  where ci.legacy_source='public.activities'
    and ci.legacy_source_id=coalesce(j->>'id', j->>'uuid', md5(j::text))
);

-- Normalize previously seeded public.activities rows. Public legacy activity rows are public content unless explicitly negative.
with normalized as (
  select
    ci.id,
    coalesce(
      case when nullif(coalesce(ci.metadata->'legacy_payload'->>'published_at', ci.metadata->'legacy_payload'->>'event_date', ci.metadata->'legacy_payload'->>'start_date', ci.metadata->'legacy_payload'->>'created_at'), '') ~ '^\d{4}-\d{2}-\d{2}'
        then nullif(coalesce(ci.metadata->'legacy_payload'->>'published_at', ci.metadata->'legacy_payload'->>'event_date', ci.metadata->'legacy_payload'->>'start_date', ci.metadata->'legacy_payload'->>'created_at'), '')::timestamptz
        else null end,
      ci.published_at,
      ci.created_at,
      now()
    ) as safe_published_at,
    lower(coalesce(ci.metadata->'legacy_payload'->>'status', ci.status, '')) as source_status
  from media_center.content_items ci
  where ci.legacy_source='public.activities'
)
update media_center.content_items ci
set
  content_type = 'activity',
  category_key = coalesce(nullif(ci.category_key,''), 'activity'),
  visibility_scope = 'public',
  status = case
    when n.source_status in ('draft','archived','rejected','inactive','deleted') then 'draft'
    else 'published'
  end,
  published_at = case
    when n.source_status in ('draft','archived','rejected','inactive','deleted') then ci.published_at
    else n.safe_published_at
  end,
  metadata = coalesce(ci.metadata, '{}'::jsonb) || jsonb_build_object(
    'ownership_stabilization', jsonb_build_object(
      'batch', 'platform_data_ownership_stabilization_controlled_execution',
      'normalized_content_type', 'activity',
      'normalized_at', now()
    )
  ),
  updated_at = now()
from normalized n
where ci.id = n.id;

insert into media_center.editorial_events (
  content_item_id,
  from_state,
  to_state,
  action_key,
  actor_scope,
  note_ar,
  metadata
)
select
  ci.id,
  null,
  ci.status,
  'controlled_activity_normalization',
  'system_migration',
  'تطبيع أنشطة public.activities ضمن media_center بعقد تنفيذ محكوم دون حذف المصدر القديم.',
  jsonb_build_object('batch','platform_data_ownership_stabilization_controlled_execution')
from media_center.content_items ci
where ci.legacy_source='public.activities'
  and not exists (
    select 1 from media_center.editorial_events ee
    where ee.content_item_id = ci.id
      and ee.action_key = 'controlled_activity_normalization'
  );

commit;

select
  'activity_normalization_result' as section,
  legacy_source,
  content_type,
  status,
  count(*)::bigint as row_count
from media_center.content_items
where legacy_source='public.activities'
group by legacy_source, content_type, status
order by content_type, status;
