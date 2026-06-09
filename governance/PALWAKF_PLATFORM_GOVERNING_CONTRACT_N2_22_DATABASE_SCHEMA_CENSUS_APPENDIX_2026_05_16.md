# PalWakf Governing Contract Appendix — N2.22 Database Schema Census

## قاعدة حاكمة جديدة

قبل أي Production Gate جديد، يجب تنفيذ برنامج Database Schema Census + Ownership Classification + Legacy Quarantine Plan.

## Public schema policy

`public` لا يكون مصدر تخزين سيادي. الدور المقبول له:

- views/RPC wrappers
- compatibility contracts
- public published-only exposure
- transitional tables مؤقتة بقرار موثق

## Mandatory update rule

أي تغيير في ملكية جدول أو schema أو source-of-truth يجب أن ينعكس في:

1. العقد الحاكم.
2. ملف التعليمات.
3. ملف الحوكمة.
4. نطاق المساعد الداخلي.
5. نطاق الشات العام.
6. baseline/changelog/session handoff/ZIP عند الحاجة.

## لا حذف مباشر

يمنع حذف أو نقل أي جدول قبل فحص dependencies/RLS/RPC/Flutter usage. يتم النقل أولًا إلى legacy/staging archive مع rollback plan.

## System schemas

لا تُلمس schemas النظامية `auth`, `storage`, `realtime`, `extensions`, `vault`, `supabase_migrations` إلا للفهرسة.
