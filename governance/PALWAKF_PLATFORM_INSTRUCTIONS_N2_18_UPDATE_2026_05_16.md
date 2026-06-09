# PalWakf Platform Instructions Update — N2.18

## تعليمات تشغيلية

عند اختبار Dynamic System Registry:

- لا تقبل صورة فتح `/admin/platform/system-registry` وحدها كدليل إنتاج.
- يجب إثبات create/update فعلي.
- يجب إثبات route access للمصرح وroute denial لغير المصرح.
- يجب فصل أدلة superuser/admin عن أدلة bthusr1.
- يجب تشغيل SQL read-only evidence بعد أي create حقيقي.
