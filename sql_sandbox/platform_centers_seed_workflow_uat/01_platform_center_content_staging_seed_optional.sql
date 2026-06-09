-- Mega Batch K — Platform Centers Browser UAT Result Intake + Productive Content Seed/Workflow Verification
-- OPTIONAL STAGING SEED
-- Purpose: provide reviewed sample rows for Browser UAT of platform center public pages and homepage sections.
-- Governance:
--   - Do not run on live production unless these seed labels are explicitly approved.
--   - Rows are deterministic and tagged with metadata.seed_batch = 'mega_batch_k_2026_05_10'.
--   - No waqf schema mutation. No awqaf_system mutation.
--   - Operational data goes to platform_content.center_content_items only.

begin;

with seed_rows(id, family_key, category_key, title_ar, summary_ar, body_ar, public_route, sort_order) as (
  values
    ('61000000-0000-4000-8000-000000000001'::uuid, 'social_posts', 'general', 'تهنئة رسمية ضمن الاجتماعيات', 'نموذج محتوى اجتماعي مراجع لاختبار ظهور قسم الاجتماعيات في الواجهة العامة.', 'هذا النص مخصص لاختبار سير نشر الاجتماعيات ضمن المركز الإعلامي، ويجب استبداله بمحتوى رسمي قبل التشغيل الإنتاجي العام.', '/social-posts', 10),
    ('61000000-0000-4000-8000-000000000002'::uuid, 'press_releases', 'official_press_release', 'بيان صحفي رسمي — نموذج تشغيل', 'نموذج بيان صحفي للتحقق من الربط بين الإدارة والصفحة العامة.', 'هذا البيان نموذجي لغرض UAT ويؤكد أن البيانات الصحفية منفصلة عن الأخبار والتصريحات الرسمية.', '/press-releases', 20),
    ('61000000-0000-4000-8000-000000000003'::uuid, 'official_statements', 'authorized_statement', 'تصريح رسمي — نموذج تحقق', 'تصريح رسمي نموذجي للتحقق من سير اعتماد التصريحات قبل النشر.', 'هذا المحتوى يختبر صفحة التصريحات الرسمية وربطها بقسم homepage عند تفعيله.', '/official-statements', 30),
    ('61000000-0000-4000-8000-000000000004'::uuid, 'awareness_campaigns', 'public_awareness', 'حملة توعوية — نموذج تشغيل', 'حملة توعوية تجريبية للتحقق من ظهور الحملات في الواجهة العامة.', 'هذا النص يوضح أن الحملة لها هدف وجمهور وفترة، ويستخدم للاختبار فقط.', '/awareness-campaigns', 40),
    ('61000000-0000-4000-8000-000000000005'::uuid, 'sanctities_observatory', 'incident_report', 'مرصد حماية المقدسات — نموذج تقرير', 'نموذج تقرير موثق بلغة حكومية للتحقق من المرصد دون تسجيل واقعة حقيقية.', 'هذا السجل لا يمثل واقعة فعلية، بل يستخدم لاختبار الواجهة والحوكمة ومسار النشر.', '/sanctities-observatory', 50),
    ('61000000-0000-4000-8000-000000000006'::uuid, 'legal_references', 'law', 'مرجع قانوني — نموذج عرض', 'نموذج مرجع قانوني للتحقق من صفحة الأنظمة والقوانين والتعليمات.', 'هذا النص مخصص لاختبار تصنيف المراجع القانونية وربطها بالمرفقات لاحقًا.', '/legal-references', 60),
    ('61000000-0000-4000-8000-000000000007'::uuid, 'events', 'public_event', 'فعالية رسمية — نموذج تشغيل', 'فعالية نموذجية للتحقق من فصل الفعاليات عن الأنشطة.', 'هذا السجل يستخدم لاختبار الحقول الزمنية والظهور العام للفعاليات.', '/events', 70),
    ('61000000-0000-4000-8000-000000000008'::uuid, 'media_reports', 'media_report', 'تقرير إعلامي — نموذج', 'نموذج تقرير إعلامي للتحقق من صفحات إدارة التقارير.', 'هذا السجل يستخدم لاختبار إدارة التقارير الإعلامية ولا يظهر في صفحة عامة مستقلة إلا عند بناء route خاص بها.', '/media-center', 80),
    ('61000000-0000-4000-8000-000000000009'::uuid, 'media_coverage', 'coverage', 'تغطية إعلامية — نموذج', 'نموذج تغطية إعلامية لاختبار سجل التغطيات والرصد.', 'هذا السجل يستخدم لاختبار إدارة التغطيات الإعلامية ومصدر البيانات الموحد.', '/media-center', 90),
    ('61000000-0000-4000-8000-000000000010'::uuid, 'waqf_impact_stories', 'impact_story', 'قصة أثر وقفي — نموذج', 'قصة أثر نموذجية لاختبار عائلة قصص الأثر دون ربط سيادي بأصل وقفي.', 'هذا السجل لا ينشئ أي رابط مع waqf_assets، ويستخدم فقط لاختبار مراكز المنصة.', '/media-center', 100)
)
insert into platform_content.center_content_items (
  id,
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
  published_at,
  is_featured,
  sort_order,
  source_system,
  metadata
)
select
  id,
  family_key,
  category_key,
  title_ar,
  summary_ar,
  body_ar,
  'central',
  'home',
  'وزارة الأوقاف والشؤون الدينية',
  'published',
  'published',
  public_route,
  now() - (sort_order || ' minutes')::interval,
  true,
  sort_order,
  'platform_content_seed',
  jsonb_build_object(
    'seed_batch', 'mega_batch_k_2026_05_10',
    'seed_type', 'browser_uat_reviewed_seed',
    'governance_note_ar', 'محتوى seed اختياري لاختبار Browser UAT، ويجب مراجعته أو تنظيفه قبل التشغيل العام النهائي.'
  )
from seed_rows
on conflict (id) do update
set
  family_key = excluded.family_key,
  category_key = excluded.category_key,
  title_ar = excluded.title_ar,
  summary_ar = excluded.summary_ar,
  body_ar = excluded.body_ar,
  scope_type = excluded.scope_type,
  unit_slug = excluded.unit_slug,
  owner_name_ar = excluded.owner_name_ar,
  workflow_status = excluded.workflow_status,
  publication_status = excluded.publication_status,
  public_route = excluded.public_route,
  published_at = excluded.published_at,
  is_featured = excluded.is_featured,
  sort_order = excluded.sort_order,
  source_system = excluded.source_system,
  metadata = excluded.metadata,
  updated_at = now();

insert into platform_content.center_content_workflow_events (
  content_item_id,
  family_key,
  action_key,
  from_status,
  to_status,
  decision_label_ar,
  unit_slug,
  source_route,
  notes,
  metadata
)
select
  item.id,
  item.family_key,
  'seed_publish',
  null,
  'published',
  'Seed مراجع لاختبار الظهور العام',
  item.unit_slug,
  item.public_route,
  'تم إدخال هذا السجل كـ seed اختياري لاختبار صفحات مراكز المنصة بعد Mega Batch K.',
  jsonb_build_object('seed_batch', 'mega_batch_k_2026_05_10')
from platform_content.center_content_items item
where item.metadata ->> 'seed_batch' = 'mega_batch_k_2026_05_10'
  and not exists (
    select 1
    from platform_content.center_content_workflow_events ev
    where ev.content_item_id = item.id
      and ev.action_key = 'seed_publish'
      and ev.metadata ->> 'seed_batch' = 'mega_batch_k_2026_05_10'
  );

commit;

select
  'seed_rows_by_family' as section,
  family_key,
  count(*) as rows_count,
  count(*) filter (where workflow_status = 'published' and publication_status = 'published') as published_rows
from platform_content.center_content_items
where metadata ->> 'seed_batch' = 'mega_batch_k_2026_05_10'
group by family_key
order by family_key;
