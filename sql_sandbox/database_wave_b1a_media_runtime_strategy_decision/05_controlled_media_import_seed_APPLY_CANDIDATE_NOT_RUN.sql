-- DO NOT RUN IN PRODUCTION.
-- Database Wave B-1A Controlled Media Import/Seed APPLY CANDIDATE — NOT RUN.
-- This file is intentionally non-executing guidance. It must be replaced by a reviewed idempotent script.

-- Required before any apply:
-- 1. Confirm exact columns of public.news_articles/public.activities/public.announcements.
-- 2. Confirm required columns of media_center.content_items.
-- 3. Define idempotency key, e.g. source_table + source_id.
-- 4. Define content_type mapping.
-- 5. Define publication_state mapping.
-- 6. Run transaction in staging and verify published-only public view.

select 'DRAFT_NOT_RUN' as state,
       'controlled_media_import_seed_requires_reviewed_mapping_before_apply' as decision;
