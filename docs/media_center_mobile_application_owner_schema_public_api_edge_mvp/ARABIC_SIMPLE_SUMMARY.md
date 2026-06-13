
# تطبيق الهاتف للمركز الإعلامي

## ما تم تجهيزه

تم تجهيز MVP لتطبيق هاتف محمول خاص بالمركز الإعلامي داخل مشروع Flutter نفسه.

## المسار

```text
/app/media-center
```

## الواجهة

```text
Bottom navigation:
- الأخبار
- الإعلانات
- الأنشطة
```

## الوظائف

```text
قراءة الأخبار/الإعلانات/الأنشطة
بحث سريع
Pull to refresh
تفاصيل داخل bottom sheet
بطاقات موبايل
إظهار ملاحظة أن المرفقات لا تصبح public تلقائيًا
```

## قاعدة البيانات

```text
media_center = مصدر الحقيقة
public.v_media_* = API edge فقط
```

## الحدود

```text
لا SQL apply
لا public base tables
لا service_role
لا production approval
لا media-gallery auto-public
```
