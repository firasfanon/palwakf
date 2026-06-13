
-- DRAFT ONLY - DO NOT APPLY WITHOUT EXPLICIT AUTHORIZATION
-- 04_DRAFT_rpc_upsert_content_attachment.sql

create or replace function media_center.rpc_upsert_content_attachment_v1(
  p_id uuid,
  p_content_table text,
  p_content_id uuid,
  p_attachment_kind text,
  p_storage_bucket text,
  p_storage_path text,
  p_external_url text,
  p_title_ar text,
  p_title_en text,
  p_mime_type text,
  p_file_size_bytes bigint,
  p_display_order integer,
  p_is_primary boolean,
  p_status text
)
returns media_center.content_attachments
language plpgsql
security definer
set search_path = media_center, platform_access, public
as $$
declare
  v_admin_id uuid;
  v_row media_center.content_attachments;
begin
  select au.id into v_admin_id
  from platform_access.admin_users au
  where au.id = auth.uid()
    and coalesce(au.is_active, true) = true
  limit 1;

  if v_admin_id is null then
    raise exception 'MEDIA_CENTER_ATTACHMENT_AUTH_REQUIRED';
  end if;

  if p_id is null then
    insert into media_center.content_attachments (
      content_table,
      content_id,
      attachment_kind,
      storage_bucket,
      storage_path,
      external_url,
      title_ar,
      title_en,
      mime_type,
      file_size_bytes,
      display_order,
      is_primary,
      status,
      created_by
    )
    values (
      p_content_table,
      p_content_id,
      p_attachment_kind,
      p_storage_bucket,
      p_storage_path,
      p_external_url,
      p_title_ar,
      p_title_en,
      p_mime_type,
      p_file_size_bytes,
      coalesce(p_display_order, 0),
      coalesce(p_is_primary, false),
      coalesce(p_status, 'draft'),
      v_admin_id
    )
    returning * into v_row;
  else
    update media_center.content_attachments
    set
      content_table = p_content_table,
      content_id = p_content_id,
      attachment_kind = p_attachment_kind,
      storage_bucket = p_storage_bucket,
      storage_path = p_storage_path,
      external_url = p_external_url,
      title_ar = p_title_ar,
      title_en = p_title_en,
      mime_type = p_mime_type,
      file_size_bytes = p_file_size_bytes,
      display_order = coalesce(p_display_order, display_order),
      is_primary = coalesce(p_is_primary, is_primary),
      status = coalesce(p_status, status),
      updated_at = now()
    where id = p_id
    returning * into v_row;

    if v_row.id is null then
      raise exception 'MEDIA_CENTER_ATTACHMENT_NOT_FOUND';
    end if;
  end if;

  return v_row;
end;
$$;
