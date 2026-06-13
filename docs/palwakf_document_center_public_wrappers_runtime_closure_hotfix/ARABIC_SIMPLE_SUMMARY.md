
# إغلاق Runtime لمركز الوثائق

## المشكلة

`/admin/documents` كان يحاول القراءة مباشرة من:

```text
platform_services
media_center
```

وهذه schemas غير مكشوفة للـ PostgREST، لذلك ظهر PGRST106.

## التصحيح

Flutter لم يعد يقرأ owner schemas مباشرة.  
القراءة أصبحت عبر public wrappers اختيارية:

```text
public.v_document_center_service_attachments_v1
public.v_document_center_media_assets_v1
```

إذا لم تكن wrappers مطبقة بعد، تعرض الصفحة بيانات الذكاء الوثائقي فقط دون خطأ أحمر.

## تصحيح /home/news

تم ضبط NewsHeroCard بارتفاع ثابت في العرض الواسع لمنع خطأ RenderFlex/Row مع ارتفاع غير محدود.

## الحدود

```text
لا SQL apply
لا RLS apply
لا service_role
لا production approval
```
