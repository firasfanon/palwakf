# INTERNAL_ASSISTANT_SCOPE_UPDATE — N2.30 Session Close

## نطاق المساعد الداخلي بعد N2.30

يسمح للمساعد الداخلي بقراءة قرارات الحوكمة والجداول المصنفة فقط وفق صلاحيات المستخدم، ولا يجوز له اقتراح نقل/حذف جدول دون Movement Gate.

## القيود

```text
لا كتابة مباشرة على schemas سيادية
لا اقتراح حذف تلقائي
لا اعتبار public source-of-truth إلا إذا كان wrapper/compatibility موثق
لا كشف بيانات حساسة خارج RBAC
```

## المعرفة التي يجب أن يستخدمها

```text
platform.schema_inventory_decisions
العقد الحاكم
Latest baseline pointer
Database Ownership Program status
```
