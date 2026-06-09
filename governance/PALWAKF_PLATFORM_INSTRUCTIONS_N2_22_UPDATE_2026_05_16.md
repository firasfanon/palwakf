# Platform Instructions Update — N2.22

## تعليمات للمطورين

- لا تضف جدولًا جديدًا إلى `public` إلا إذا كان Transitional بقرار حاكم.
- أي جدول جديد يجب أن يملك owner system وschema مقترحة قبل الإنشاء.
- أي wrapper عام يجب أن يكون view/RPC فوق schema المالك، لا نسخة بيانات.
- عند تعديل view قائم، حافظ على أسماء وترتيب وأنواع الأعمدة.
- أي جدول staging/backup/cache يجب أن يحمل تاريخ انتهاء أو قرار أرشفة.
- لا تعتمد Flutter مباشرة على cache أو public duplicate tables.
