-- PalWakf Platform Services Center
-- Production Data Layer Readiness Pack
-- 99 - Rollback Draft
-- Date: 2026-05-08
-- Status: DESTRUCTIVE / DO NOT RUN UNLESS ROLLBACK IS APPROVED
-- Warning: This drops Services Center data-layer objects. Backup first.

-- Drop public RPC wrappers.
drop function if exists public.rpc_services_admin_request_queue_draft_v1();
drop function if exists public.rpc_services_admin_request_queue_v1(text, integer);
drop function if exists public.rpc_services_submit_request_draft_v1(jsonb);
drop function if exists public.rpc_services_submit_request_v1(jsonb);
drop function if exists public.rpc_services_track_request_public_v1(text);
drop function if exists public.rpc_services_forms_public_v1();

-- Drop internal functions.
drop function if exists platform_services.can_admin_read_requests_v1();
drop function if exists platform_services.generate_tracking_code_v1();
drop function if exists platform_services.set_updated_at_v1() cascade;

-- Drop tables in dependency order.
drop table if exists platform_services.service_request_attachments cascade;
drop table if exists platform_services.service_request_status_events cascade;
drop table if exists platform_services.service_requests cascade;
drop table if exists platform_services.service_forms_registry cascade;

-- Drop schema if empty.
drop schema if exists platform_services;

-- Storage rollback must be reviewed separately before removing buckets/files.
-- Do not delete storage buckets automatically from this rollback draft.

