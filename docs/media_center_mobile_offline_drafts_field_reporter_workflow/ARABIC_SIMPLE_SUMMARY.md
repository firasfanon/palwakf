
# Media Center Mobile Offline Drafts + Field Reporter Workflow

## الهدف

دعم الموظف أو مراسل الإعلام في الميدان عندما لا يكون الحاسوب متاحًا أو عندما يكون الاتصال ضعيفًا.

## ما أضيف

```text
1. حفظ مسودة محلية على الهاتف.
2. صفحة مسودات الهاتف.
3. استكمال تحرير المسودة لاحقًا.
4. زر "حفظ على الهاتف" داخل واجهة النشر السريع.
5. مسار جديد /app/media-center/drafts.
6. ربط المسودات من شاشة /app/media.
```

## المسارات

```text
/app/media
/app/media-center/publish
/app/media-center/drafts
```

## القاعدة

```text
المسودة المحلية ليست نشرًا رسميًا.
المحتوى يصبح رسميًا فقط عند إرساله إلى media_center عبر RPC.
public يبقى API edge فقط.
```

## لا يوجد

```text
لا SQL apply
لا public base tables
لا service_role
لا production approval
```
