
-- ROLLBACK DRAFT ONLY - DO NOT APPLY WITHOUT EXPLICIT AUTHORIZATION
-- This rollback removes governed attachments draft objects.
-- It does not delete media content tables.

drop view if exists public.v_media_center_content_attachments_public_v1;

drop function if exists media_center.rpc_upsert_content_attachment_v1(
  uuid,
  text,
  uuid,
  text,
  text,
  text,
  text,
  text,
  text,
  text,
  bigint,
  integer,
  boolean,
  text
);

drop table if exists media_center.content_attachments;
