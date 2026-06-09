-- PalWakf Platform — Services Center Catalog Taxonomy + Seed Draft
-- Date: 2026-05-09
-- Status: NON-PRODUCTION DRAFT / DO NOT RUN ON PRODUCTION WITHOUT APPROVAL
-- Purpose: Document the intended taxonomy and candidate service seed rows.
-- This file intentionally performs no INSERT/UPDATE/DELETE.

select 'services_center_catalog_taxonomy_seed_draft' as section,
       'no-op' as execution_mode,
       'This draft is documentation-only. Approve taxonomy and seed before production insert.' as note;

-- Draft taxonomy, represented as selectable rows for review.
select * from (
  values
    ('public_services', 'خدمات الجمهور', 'Core public services and citizen-facing requests'),
    ('e_services', 'الخدمات الإلكترونية', 'Online portals, interactive services, or external links'),
    ('forms_documents', 'الطلبات والنماذج', 'Forms, certificates, document requests'),
    ('inquiries_tracking', 'الاستعلامات والمتابعة', 'Tracking and public status inquiry'),
    ('complaints_feedback', 'الشكاوى والملاحظات', 'Existing pwf_complaints channel; not mixed with service requests'),
    ('official_references', 'المراجع الرسمية', 'Laws, systems, instructions, guides'),
    ('financial_services', 'الخدمات المالية', 'Payment and billing-related future services'),
    ('unit_services', 'خدمات المديريات والوحدات', 'Unit-scoped services'),
    ('waqf_services', 'خدمات الأوقاف', 'Waqf asset/endowment-related requests; waqf_assets link deferred')
) as taxonomy(family_key, label_ar, description_en);

-- Candidate service seed rows for review. Do not insert automatically.
select * from (
  values
    ('request_certificate', 'طلب وثيقة أو إفادة', 'forms_documents', '/services/request', true, false, true, 'draft_seed'),
    ('mosque_service_request', 'طلب خدمة متعلقة بالمساجد', 'public_services', '/services/request', true, false, true, 'draft_seed'),
    ('public_service_inquiry', 'الاستعلام عن خدمة', 'inquiries_tracking', '/services/track', false, false, false, 'draft_seed'),
    ('complaint_feedback_entry', 'تقديم شكوى أو ملاحظة', 'complaints_feedback', '/complaints', false, true, false, 'existing_channel'),
    ('legal_references', 'الأنظمة والقوانين والتعليمات', 'official_references', '/legal-references', false, false, true, 'draft_seed'),
    ('e_services_portal', 'بوابة الخدمات الإلكترونية', 'e_services', '/eservices', false, false, false, 'draft_seed'),
    ('payment_followup', 'متابعة دفع أو إشعار مالي', 'financial_services', null, true, false, false, 'deferred_billing'),
    ('unit_service_directory', 'دليل خدمات المديريات', 'unit_services', '/:unitSlug/services', false, false, false, 'draft_seed'),
    ('waqf_asset_related_request', 'طلب متعلق بأصل وقفي', 'waqf_services', '/services/request', true, false, true, 'deferred_waqf_assets')
) as candidate_seed(service_key, title_ar, family_key, suggested_route, request_enabled, complaint_related, document_required, production_status);
