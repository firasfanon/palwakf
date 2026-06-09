-- Mega Batch N2.29
-- DRAFT_NOT_RUN unless approved.
-- Inserts Wave A planning decisions using the real schema_inventory_decisions contract.
-- No operational table is moved or deleted here.

with rows(
  source_schema, object_name, object_type, current_owner_system,
  recommended_owner_system, classification, decision, action_status,
  risk_level, dependency_status, rls_status, rpc_usage_status, flutter_usage_status, notes_ar
) as (
  values
  -- Site content domain candidates
  ('public','site_pages','table','public','site_content','site_content_candidate','plan_domain_migration','planned','medium','not_checked','not_checked','not_checked','not_checked','مرشح لطبقة site_content بعد فحص RLS/RPC/Flutter.'),
  ('public','homepage_sections','table','public','site_content','site_content_candidate','plan_domain_migration','planned','medium','not_checked','not_checked','not_checked','not_checked','مرشح لطبقة site_content مع الحفاظ على public wrappers.'),
  ('public','home_config','table','public','site_content','site_content_candidate','plan_domain_migration','planned','medium','not_checked','not_checked','not_checked','not_checked','إعدادات الصفحة الرئيسية؛ لا تنقل قبل dependency review.'),
  ('public','header_settings','table','public','site_content','site_content_candidate','plan_domain_migration','planned','medium','not_checked','not_checked','not_checked','not_checked','إعدادات الهيدر؛ تحتاج RLS migration plan.'),
  ('public','footer_settings','table','public','site_content','site_content_candidate','plan_domain_migration','planned','medium','not_checked','not_checked','not_checked','not_checked','إعدادات الفوتر؛ تحتاج RLS migration plan.'),
  ('public','hero_slides','table','public','site_content','site_content_candidate','plan_domain_migration','planned','medium','not_checked','not_checked','not_checked','not_checked','شرائح الواجهة العامة؛ مرشح site_content.'),
  ('public','home_hero_slides','table','public','site_content','site_content_candidate','plan_domain_migration','planned','medium','not_checked','not_checked','not_checked','not_checked','شرائح الصفحة الرئيسية؛ مرشح site_content.'),
  ('public','home_stats','table','public','site_content','site_content_candidate','plan_domain_migration','planned','medium','not_checked','not_checked','not_checked','not_checked','إحصائيات الصفحة الرئيسية؛ مرشح site_content.'),
  ('public','site_settings','table','public','site_content','site_content_candidate','plan_domain_migration','planned','medium','not_checked','not_checked','not_checked','not_checked','إعدادات الموقع؛ مرشح site_content.'),
  ('public','app_settings','table','public','site_content','site_content_candidate','plan_domain_migration','planned','medium','not_checked','not_checked','not_checked','not_checked','إعدادات عامة تحتاج تصنيف نهائي.'),
  ('public','former_ministers','table','public','site_content','site_content_candidate','plan_domain_migration','planned','low','not_checked','not_checked','not_checked','not_checked','مرشح site_content أو محتوى عام حسب renderer.'),
  ('public','pwf_former_ministers','table','public','site_content','site_content_candidate','plan_domain_migration','planned','low','not_checked','not_checked','not_checked','not_checked','نسخة PWF؛ تحتاج dedupe/merge review.'),

  -- Media center domain candidates
  ('public','activities','table','public','media_center','media_candidate','plan_domain_migration','planned','high','not_checked','not_checked','not_checked','not_checked','مرشح media_center؛ لا ينقل قبل RLS/workflow migration.'),
  ('public','announcements','table','public','media_center','media_candidate','plan_domain_migration','planned','high','not_checked','not_checked','not_checked','not_checked','مرشح media_center؛ يحتاج public wrapper compatibility.'),
  ('public','breaking_news','table','public','media_center','media_candidate','plan_domain_migration','planned','high','not_checked','not_checked','not_checked','not_checked','مرشح media_center؛ عالي الحساسية بسبب RLS policies.'),
  ('public','media_gallery_items','table','public','media_center','media_candidate','plan_domain_migration','planned','high','not_checked','not_checked','not_checked','not_checked','مرشح media_center؛ يحتاج Flutter repository migration.'),
  ('public','news_articles','table','public','media_center','media_candidate','plan_domain_migration','planned','high','not_checked','not_checked','not_checked','not_checked','مرشح media_center؛ لا ينقل قبل editorial workflow compatibility.'),
  ('public','media_center_audit_events','table','public','media_center','media_governance_candidate','plan_domain_migration','planned','high','not_checked','not_checked','not_checked','not_checked','يفضل نقله إلى media_center أو governance بعد audit.'),
  ('public','media_center_editorial_events','table','public','media_center','media_governance_candidate','plan_domain_migration','planned','high','not_checked','not_checked','not_checked','not_checked','يفضل داخل media_center workflow.'),
  ('public','media_center_editorial_roles','table','public','media_center','media_governance_candidate','plan_domain_migration','planned','high','not_checked','not_checked','not_checked','not_checked','أدوار تحرير؛ تحتاج RBAC mapping.'),
  ('public','media_center_publishing_governance_rules','table','public','media_center','media_governance_candidate','plan_domain_migration','planned','high','not_checked','not_checked','not_checked','not_checked','قواعد النشر؛ تحتاج policy migration.'),

  -- Services mapping candidates
  ('public','services','table','public','platform_services','services_candidate','plan_mapping_before_migration','planned','medium','not_checked','not_checked','not_checked','not_checked','مرشح platform_services بعد mapping.'),
  ('public','home_services','table','public','platform_services_or_platform_content','services_candidate','manual_mapping_required','planned','medium','not_checked','not_checked','not_checked','not_checked','قد يكون عرضًا للصفحة الرئيسية أو خدمة تشغيلية.'),
  ('public','servicepoints','table','public','platform_services_or_facilities_module','services_candidate','manual_mapping_required','planned','medium','not_checked','not_checked','not_checked','not_checked','قد يرتبط بالفواتير/المرافق؛ لا ينقل قبل facilities review.'),
  ('public','serviceproviders','table','public','platform_services_or_facilities_module','services_candidate','manual_mapping_required','planned','medium','not_checked','not_checked','not_checked','not_checked','مزودو الخدمة؛ يحتاج facilities review.'),
  ('public','servicetypes','table','public','platform_services_or_facilities_module','services_candidate','manual_mapping_required','planned','medium','not_checked','not_checked','not_checked','not_checked','أنواع الخدمة؛ يحتاج facilities review.'),

  -- Unresolved / quarantine
  ('public','locations','table','public','gis_or_lookup_wrapper','locations_unresolved','deep_audit_required','planned','high','not_checked','not_checked','not_checked','not_checked','public.locations lookup بسيط مقابل gis.locations مكاني غني؛ لا يحسم الآن.'),
  ('public','org_units_cache','table','public','legacy_archive','cache_deprecated','archive_after_usage_zero','planned','medium','not_checked','not_checked','not_checked','not_checked','كاش وحدات؛ لا يحذف قبل Flutter/RPC dependency check.'),
  ('public','pwf_org_units_cache','table','public','legacy_archive','cache_deprecated','archive_after_usage_zero','planned','medium','not_checked','not_checked','not_checked','not_checked','كاش وحدات قديم؛ لا يحذف قبل dependency check.'),

  -- Transitional RBAC
  ('public','platform_systems','table','public','platform','rbac_transitional','do_not_move_before_rbac_migration','planned','high','not_checked','not_checked','not_checked','not_checked','مصدر RBAC انتقالي؛ لا ينقل قبل migration مستقل.'),
  ('public','platform_permissions','table','public','platform','rbac_transitional','do_not_move_before_rbac_migration','planned','high','not_checked','not_checked','not_checked','not_checked','صلاحيات platform legacy/transitional.'),
  ('public','user_system_roles','table','public','platform','rbac_transitional','do_not_move_before_rbac_migration','planned','high','not_checked','not_checked','not_checked','not_checked','أدوار المستخدمين الانتقالية؛ لا تنقل قبل RBAC migration.'),
  ('public','user_system_permissions','table','public','platform','rbac_transitional','do_not_move_before_rbac_migration','planned','high','not_checked','not_checked','not_checked','not_checked','صلاحيات المستخدمين الانتقالية؛ لا تنقل قبل RBAC migration.')
), inserted as (
  insert into platform.schema_inventory_decisions (
    batch_key,
    source_schema,
    object_name,
    object_type,
    current_owner_system,
    recommended_owner_system,
    classification,
    decision,
    action_status,
    risk_level,
    dependency_status,
    rls_status,
    rpc_usage_status,
    flutter_usage_status,
    notes_ar
  )
  select
    'N2.29',
    r.source_schema,
    r.object_name,
    r.object_type,
    r.current_owner_system,
    r.recommended_owner_system,
    r.classification,
    r.decision,
    r.action_status,
    r.risk_level,
    r.dependency_status,
    r.rls_status,
    r.rpc_usage_status,
    r.flutter_usage_status,
    r.notes_ar
  from rows r
  where not exists (
    select 1
    from platform.schema_inventory_decisions d
    where d.batch_key = 'N2.29'
      and d.source_schema = r.source_schema
      and d.object_name = r.object_name
  )
  returning id
)
select
  'schema_inventory_wave_a' as section,
  'n2_29_inserted_decisions' as check_key,
  count(*) as inserted_count,
  'Draft inserts Wave A decisions using real contract columns.' as note
from inserted;
