# Governing Contract Appendix — N2.33A

## 1. Superuser Root Authority

داخل PalWakf، `superuser` سلطة منصة عليا. لا يجوز حجبه عن نظام مسجل لمجرد غياب role scoped لذلك النظام.

الترتيب الحاكم:

```text
1. auth/profile loaded
2. active user
3. explicit maintenance/system lock
4. superuser root authority
5. platform admin management authority
6. system-scoped role/permission
7. unitSlug authority
8. deny
```

## 2. Awqaf System

`awqaf_system` نظام سيادي شبه مستقل وليس Platform Core، لكنه يخضع لنواة المنصة في Auth/RBAC/Dynamic Registry/Health/Maintenance.

```text
superuser => allowed unless explicit lock
awqaf_system admin => allowed by system scope
unit manager => allowed within unitSlug scope
authenticated no grants => public-safe entry only
anonymous => public-safe entry only
```

## 3. SQL Read-only Syntax Safety

أي SQL UAT read-only يجب أن يستخدم صياغات PostgreSQL صريحة وآمنة.

ممنوع:

```sql
view_definition not ~* 'pattern'
```

مسموح:

```sql
not (coalesce(view_definition, '') ~* 'pattern')
coalesce(view_definition, '') !~* 'pattern'
```

## 4. Baseline Cleanliness

الملفات المؤقتة والقديمة لا توضع في جذر baseline. توضع السجلات داخل مجلدات منظمة:

```text
ops/governance/
ops/handoffs/
ops/changelogs/
ops/error_records/
sql_sandbox/
source_patch/
```
