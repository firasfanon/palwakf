# PALWAKF_PLATFORM_INSTRUCTIONS_UPDATE — N2.30 Session Close

1. الردود بالعربية.
2. ابدأ من آخر baseline وSESSION_HANDOFF والعقد الحاكم، لا من الذاكرة وحدها.
3. لا تُفتح Production Gates جديدة قبل إغلاق Database Ownership Program أو إصدار قرار defer موثق.
4. لا تنقل أو تحذف أي جدول دون dependency/RLS/RPC/Flutter usage/rollback evidence.
5. `public` للـ views/RPC wrappers/compatibility فقط قدر الإمكان.
6. `core.org_units` هو مصدر الحقيقة للوحدات التنظيمية.
7. `public.org_units` compatibility view فقط، ويحافظ على `unit_type::text`.
8. لا تستخدم DROP VIEW CASCADE دون قرار حاكم.
9. لا تلمس `waqf_assets` أو `waqf` أو `awqaf_system` في برنامج تنظيف قاعدة البيانات.
10. عند نهاية أي جلسة تطوير: SESSION_HANDOFF + BASELINE_CHANGELOG + ZIP + SHA256.
