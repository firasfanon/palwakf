
# Media Center Official-first Mobile Operational Workflow + Android Readiness

## الهدف

تحويل تطبيق المركز الإعلامي من مجرد واجهات إلى مسار تشغيل موبايل عملي:

```text
/app/media
/app/media-center
/app/media-center/publish
/official/media/:family/:id
```

## ما أضيف

```text
1. شاشة تشغيل موبايل رئيسية /app/media.
2. ربط واضح بين النشر السريع والاستعراض.
3. توضيح مسار الموظف العادي والناشر المعتمد والجمهور.
4. سكربت build Android debug.
5. ملف تحقق SQL read-only لتأكيد جاهزية RPCs.
```

## القاعدة

```text
الموقع الرسمي أولًا
وسائل التواصل تشارك الرابط الرسمي فقط
media_center = source of truth
public = API edge only
```

## لا يوجد

```text
لا SQL apply
لا public base tables
لا service_role
لا production approval
```
