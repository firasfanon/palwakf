
# MEDIA_CENTER_OFFICIAL_FIRST_MOBILE_PUBLISHING_APP_MVP_MEGA_BATCH

## الفكرة

هذا ليس تطبيق قراءة فقط.  
هذا تطبيق موبايل للنشر الرسمي أولًا.

## المشكلة

```text
كاتب الخبر بعيد عن الحاسوب
↓
ينشر سريعًا على فيسبوك
↓
فيسبوك يصبح المصدر الأول بدل الموقع الرسمي
```

## الحل

```text
الموظف ينشئ الخبر من الهاتف
↓
المحتوى يحفظ في media_center
↓
الموظف العادي يرسل للمراجعة
↓
الناشر المعتمد ينشر مباشرة مع audit
↓
النظام يولد رابطًا رسميًا
↓
وسائل التواصل تشارك الرابط الرسمي فقط
```

## مسارات التطبيق

```text
/app/media-center
/app/media-center/publish
/official/media/:family/:id
```

## الواجهات

```text
1. واجهة قراءة موبايل للجمهور/المستخدم
2. واجهة نشر سريع للموظف
3. واجهة تفاصيل رسمية للجمهور
```

## الحوكمة

```text
media_center = source of truth
public RPC/views = API edge only
لا public base tables
لا service_role
لا media-gallery auto-public
```
