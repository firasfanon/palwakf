# Mega Batch — Media/Services Data Ownership Final Closure + Legacy Table Quarantine Decision

## الغرض
إغلاق عقد ملكية مركز الإعلام ومركز الخدمات على مستوى القرار والتشغيل العام، مع عزل الجداول القديمة منطقيًا كـ legacy/quarantined sources دون حذف فعلي.

## ترتيب التشغيل
1. `01_media_services_legacy_inventory_read_only.sql`
2. `02_media_gallery_assets_final_closure_read_only.sql`
3. `03_services_legacy_quarantine_decision_read_only.sql`
4. `04_media_services_final_closure_decision_read_only.sql`
5. `05_sovereign_boundary_read_only.sql`

## حدود الدفعة
- لا حذف لجداول `public` القديمة.
- لا `DROP` ولا `DELETE` ولا `UPDATE`.
- لا mutation على `waqf_assets/waqf/awqaf_system`.
- أي أرشفة أو حذف لاحق يحتاج Mega Batch منفصلة وموافقة صريحة.
