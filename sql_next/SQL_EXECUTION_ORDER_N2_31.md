# SQL EXECUTION ORDER — N2.31 Draft

لا تشغل أي SQL DML قبل مراجعة N2.30 handoff.

## Read-only first

```text
1. Inventory candidate dependency matrix
2. RPC/function usage scan
3. RLS policy scan
4. Flutter usage evidence intake
5. View dependency scan
6. Safe candidate decision UAT
```

## ممنوع في بداية N2.31

```text
DROP TABLE
ALTER TABLE SET SCHEMA
DROP VIEW CASCADE
DELETE FROM public.*
UPDATE production operational rows
```

## مسموح لاحقًا فقط بعد القرار

```text
DRAFT_NOT_RUN migration SQL
rollback SQL
read-only UAT SQL
```
