-- Public Legacy Dependency Reduction Pack
-- 05_BODY_REWRITE_DRAFT_NOT_RUN.sql
-- Intentionally NOT executable as an apply migration.
-- This file documents the rewrite gate only. Do not paste as a production migration.

select *
from (
  values
    ('draft_rewrite_gate', 'status', 'DRAFT_NOT_RUN'),
    ('draft_rewrite_gate', 'required_before_apply', 'SQL02 exact function body export'),
    ('draft_rewrite_gate', 'required_before_apply', 'Reviewer-approved per-routine source mapping'),
    ('draft_rewrite_gate', 'required_before_apply', 'Rollback body for every changed routine'),
    ('draft_rewrite_gate', 'required_before_apply', 'Post-apply dependency census must show reduced routine references'),
    ('draft_rewrite_gate', 'delete_authorized', 'false'),
    ('draft_rewrite_gate', 'destructive_sql_authorized', 'false'),
    ('draft_rewrite_gate', 'production_approved', 'false')
) as t(section, key, value);

-- Safe rewrite principles for the next pack:
-- 1) Replace metadata-only references to public.news_articles/public.announcements/public.activities
--    with media_center.content_items + public.v_media_*_compat_v1 labels.
-- 2) Do not rewrite public.services-facing RPCs until the 9 public services versus 6 form-registry rows gap is closed.
-- 3) Do not touch Auth/RBAC helper functions in this pack.
-- 4) Do not drop or rename any public legacy table.
