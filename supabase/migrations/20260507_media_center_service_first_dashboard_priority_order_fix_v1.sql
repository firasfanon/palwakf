-- PalWakf Media Center — Service-First Dashboard SQL Fix
-- Fix: priority_order was referenced directly in ORDER BY inside VALUES.
-- PostgreSQL does not expose RETURNS TABLE column names to a bare VALUES body.
-- This replacement aliases the VALUES table explicitly and orders by t.priority_order.

create or replace function public.rpc_media_center_service_dashboard_actions_v1()
returns table (
  family_key text,
  label_ar text,
  primary_action_ar text,
  secondary_action_ar text,
  admin_route text,
  public_route text,
  service_group_ar text,
  priority_order integer
)
language sql
stable
security definer
set search_path = public
as $$
  select
    t.family_key,
    t.label_ar,
    t.primary_action_ar,
    t.secondary_action_ar,
    t.admin_route,
    t.public_route,
    t.service_group_ar,
    t.priority_order
  from (
    values
      ('news', 'الأخبار', 'إنشاء خبر', 'إدارة الأخبار', '/admin/media-center/news', '/home/news', 'المحتوى التحريري', 10),
      ('announcements', 'الإعلانات', 'إنشاء إعلان', 'إدارة الإعلانات', '/admin/media-center/announcements', '/home/announcements', 'المحتوى التحريري', 20),
      ('activities', 'الأنشطة', 'إضافة نشاط', 'إدارة الأنشطة', '/admin/media-center/activities', '/home/activities', 'المحتوى التحريري', 30),
      ('events', 'الفعاليات', 'إضافة فعالية', 'إدارة الفعاليات', '/admin/media-center/events', '/home/activities', 'المحتوى التحريري', 40),
      ('photos', 'معرض الصور', 'رفع صور', 'إدارة الصور', '/admin/media-center/photos', '/home/media', 'الوسائط', 50),
      ('videos', 'الفيديوهات', 'إضافة فيديو', 'إدارة الفيديوهات', '/admin/media-center/videos', '/home/media', 'الوسائط', 60),
      ('breaking_news', 'الأخبار العاجلة', 'نشر خبر عاجل', 'إدارة العاجل', '/admin/media-center/breaking-news', '/home', 'النشر المركزي', 70),
      ('friday_sermons', 'خُطب الجمعة', 'إضافة خطبة', 'إدارة الخطب', '/admin/media-center/friday-sermons', '/friday-sermon', 'المحتوى المتخصص', 80),
      ('hero_slider', 'السلايدر والحملات البصرية', 'إضافة شريحة', 'إدارة السلايدر', '/admin/media-center/hero-slider', '/home', 'النشر المركزي', 90)
  ) as t(
    family_key,
    label_ar,
    primary_action_ar,
    secondary_action_ar,
    admin_route,
    public_route,
    service_group_ar,
    priority_order
  )
  order by t.priority_order;
$$;

grant execute on function public.rpc_media_center_service_dashboard_actions_v1() to authenticated, anon;

-- Keep the readiness function definition compatible. It depends on the actions RPC above.
create or replace function public.rpc_media_center_service_first_readiness_v1()
returns table (
  check_key text,
  title_ar text,
  status_key text,
  status_label_ar text,
  evidence_ar text,
  required_next_action_ar text,
  is_closed boolean
)
language sql
stable
security definer
set search_path = public
as $$
  with actions as (
    select count(*)::integer as total_actions
    from public.rpc_media_center_service_dashboard_actions_v1()
  ), registry as (
    select count(*)::integer as total_families
    from public.rpc_media_center_family_registry_v1()
  ), runtime as (
    select count(*) filter (where is_closed)::integer as closed_checks,
           count(*)::integer as total_checks
    from public.rpc_media_center_runtime_ux_checks_v1()
  )
  select '01_service_first_default'::text,
         'الخدمات هي التبويب الافتراضي'::text,
         'implemented'::text,
         'منفذ'::text,
         'صفحة /admin/media-center تبدأ بالخدمات والإجراءات اليومية بدل readiness أو UAT.'::text,
         'اختبر أن تبويب الخدمات هو أول ما يراه المستخدم.'::text,
         true::boolean
  union all
  select '02_service_actions_registry',
         'سجل إجراءات الخدمات',
         case when actions.total_actions >= 9 then 'closed' else 'incomplete' end,
         case when actions.total_actions >= 9 then 'مغلق' else 'غير مكتمل' end,
         'إجراءات خدمات مسجلة: ' || actions.total_actions || '/9.',
         'لا تنشئ جداول محتوى موازية؛ حدّث سجل الإجراءات عند إضافة عائلة إعلامية جديدة.',
         actions.total_actions >= 9
  from actions
  union all
  select '03_governance_secondary_tabs',
         'الحوكمة في تبويب ثانوي',
         'implemented',
         'منفذ',
         'مصفوفة الأدوار، قواعد النشر، UAT، والتشخيص بقيت متاحة في تبويبات الحوكمة/التشخيص.',
         'لا تعيد readiness والـ UAT إلى أعلى الصفحة التشغيلية.',
         true
  union all
  select '04_family_registry_preserved',
         'حفظ عائلات المركز الإعلامي',
         case when registry.total_families >= 9 then 'closed' else 'incomplete' end,
         case when registry.total_families >= 9 then 'مغلق' else 'غير مكتمل' end,
         'عائلات إعلامية ظاهرة في registry: ' || registry.total_families || '/9.',
         'تحقق من المسارات العامة والإدارية بعد أي تعديل routing.',
         registry.total_families >= 9
  from registry
  union all
  select '05_runtime_checks_preserved',
         'حفظ فحوص التشغيل',
         case when runtime.total_checks > 0 and runtime.closed_checks = runtime.total_checks then 'closed' else 'pending' end,
         case when runtime.total_checks > 0 and runtime.closed_checks = runtime.total_checks then 'مغلق' else 'بحاجة متابعة' end,
         'فحوص التشغيل المغلقة: ' || runtime.closed_checks || '/' || runtime.total_checks || '.',
         'أعد UAT بعد كل تعديل تشغيلي كبير.',
         runtime.total_checks > 0 and runtime.closed_checks = runtime.total_checks
  from runtime;
$$;

grant execute on function public.rpc_media_center_service_first_readiness_v1() to authenticated, anon;
