
# PALWAKF_FILE_CENTER_HOME_NEWS_PUBLIC_API_EDGE_MEGA_BATCH

## ما يجمعه هذا الباتش

```text
FILE_CENTER_EXPLICIT_UNIT_ASSIGNMENT_AND_OWNER_RECORD_MAPPING_WORKFLOW
HOME_NEWS_MEDIA_EXPERIENCE_AND_HOMEPAGE_CHALLENGES_CLOSURE_MEGA_BATCH
PUBLIC_SCHEMA_IS_COMPATIBILITY_AND_API_EDGE_ONLY_NOT_SYSTEM_SOURCE_OF_TRUTH
```

## القرار الحاكم

```text
public = API edge / compatibility façade فقط
owner schemas = source of truth
```

## أهم التغييرات

```text
1. مركز الوثائق يقرأ سجل ملفات التخزين المحكوم.
2. تظهر ملفات Storage كـ restricted/unassigned/mapping_required.
3. NewsService يعطل fallback إلى public base tables افتراضيًا.
4. public.v_media_* تبقى واجهة API انتقالية لا مصدرًا للبيانات.
5. SQL workflow يضيف RPCs للربط الصريح مع وحدة/مالك وسجل audit.
```

## الحدود

```text
لا public base tables
لا نقل source of truth إلى public
لا حذف ملفات
لا تعديل storage.objects
لا fake owner records
لا public auto-publish
لا RLS mutation
لا service_role
لا production approval
```
