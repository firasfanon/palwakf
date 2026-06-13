
-- MEDIA_CENTER_OFFICIAL_FIRST_MOBILE_PUBLISHING_APP_MVP
-- AUTHORIZED APPLY CANDIDATE
--
-- Purpose:
-- Official-first mobile publishing workflow.
--
-- Pattern:
-- mobile contributor -> create draft -> submit for review
-- trusted publisher -> create draft -> publish now with audit
-- public -> opens official link /official/media/:family/:id
--
-- Boundaries:
-- - media_center remains source of truth.
-- - public RPCs are API edge only.
-- - No public base tables.
-- - No service_role in Flutter.
-- - No RLS mutation in this script.
-- - No file deletion.
-- - No storage.objects mutation.
-- - No production approval.

begin;

create table if not exists media_center.mobile_publish_events (
  id uuid primary key default gen_random_uuid(),
  content_item_id uuid null references media_center.content_items(id) on delete cascade,
  action_key text not null,
  actor_user_id uuid null references auth.users(id),
  from_status text null,
  to_status text null,
  source_channel text not null default 'mobile_app',
  official_path text null,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

comment on table media_center.mobile_publish_events is
  'Audit trail for official-first mobile publishing workflow.';

create index if not exists idx_mobile_publish_events_item_created
  on media_center.mobile_publish_events(content_item_id, created_at desc);

create index if not exists idx_mobile_publish_events_actor_created
  on media_center.mobile_publish_events(actor_user_id, created_at desc);

create or replace function public.rpc_media_center_mobile_actor_can_publish_v1()
returns boolean
language sql
security definer
set search_path = public, platform_access, auth, pg_temp
as $$
  select exists (
    select 1
    from platform_access.admin_users au
    where au.id = auth.uid()
      and coalesce((to_jsonb(au)->>'is_active')::boolean, true) = true
      and (
        coalesce((to_jsonb(au)->>'is_superuser')::boolean, false) = true
        or lower(coalesce(to_jsonb(au)->>'role', '')) in (
          'super_admin',
          'admin',
          'media_admin',
          'publisher',
          'editor'
        )
        or coalesce(to_jsonb(au)->'assigned_system_keys', '[]'::jsonb) ? 'media_center'
        or coalesce(to_jsonb(au)->'assigned_system_keys', '[]'::jsonb) ? 'site'
      )
  );
$$;

create or replace function public.rpc_media_center_official_path_v1(
  p_content_type text,
  p_content_item_id uuid
)
returns text
language sql
stable
set search_path = public, pg_temp
as $$
  select '/official/media/' ||
    case
      when p_content_type = 'news' then 'news'
      when p_content_type = 'announcement' then 'announcements'
      when p_content_type = 'activity' then 'activities'
      else 'news'
    end ||
    '/' ||
    p_content_item_id::text;
$$;

create or replace function public.rpc_media_center_mobile_create_draft_v1(
  p_content_type text,
  p_title_ar text,
  p_summary_ar text default null,
  p_body_ar text default null,
  p_unit_id uuid default null,
  p_unit_slug text default null,
  p_primary_asset_bucket text default null,
  p_primary_asset_path text default null,
  p_primary_asset_mime_type text default null,
  p_primary_asset_size_bytes bigint default null
)
returns jsonb
language plpgsql
security definer
set search_path = public, media_center, auth, pg_temp
as $$
declare
  v_actor uuid := auth.uid();
  v_content_type text;
  v_item_id uuid;
  v_official_path text;
begin
  if v_actor is null then
    raise exception 'AUTH_REQUIRED' using errcode = '28000';
  end if;

  v_content_type := lower(trim(coalesce(p_content_type, 'news')));
  if v_content_type not in ('news','announcement','activity') then
    raise exception 'UNSUPPORTED_CONTENT_TYPE: %', p_content_type using errcode = '22023';
  end if;

  if p_title_ar is null or length(trim(p_title_ar)) < 5 then
    raise exception 'TITLE_REQUIRED' using errcode = '22023';
  end if;

  insert into media_center.content_items (
    content_key,
    content_type,
    title_ar,
    summary_ar,
    body_ar,
    status,
    visibility_scope,
    unit_id,
    unit_slug,
    author_user_id,
    owner_system,
    metadata,
    created_by,
    updated_by
  )
  values (
    'mobile_' || v_content_type || '_' || replace(gen_random_uuid()::text, '-', ''),
    v_content_type,
    trim(p_title_ar),
    nullif(trim(coalesce(p_summary_ar, '')), ''),
    nullif(trim(coalesce(p_body_ar, '')), ''),
    'draft',
    'public',
    p_unit_id,
    lower(nullif(trim(coalesce(p_unit_slug, '')), '')),
    v_actor,
    'media_center',
    jsonb_build_object(
      'source_channel', 'mobile_app',
      'official_first', true,
      'social_media_policy', 'share_official_link_only',
      'asset_bucket', p_primary_asset_bucket,
      'asset_path', p_primary_asset_path
    ),
    v_actor,
    v_actor
  )
  returning id into v_item_id;

  if p_primary_asset_bucket is not null and p_primary_asset_path is not null then
    insert into media_center.content_assets (
      content_item_id,
      asset_type,
      storage_bucket,
      storage_path,
      filename,
      mime_type,
      file_size_bytes,
      is_primary,
      display_order,
      metadata
    )
    values (
      v_item_id,
      'image',
      p_primary_asset_bucket,
      p_primary_asset_path,
      split_part(p_primary_asset_path, '/', array_length(string_to_array(p_primary_asset_path, '/'), 1)),
      p_primary_asset_mime_type,
      p_primary_asset_size_bytes,
      true,
      0,
      jsonb_build_object(
        'source_channel', 'mobile_app',
        'public_visibility_requires_content_publish', true
      )
    );
  end if;

  v_official_path := public.rpc_media_center_official_path_v1(v_content_type, v_item_id);

  insert into media_center.editorial_events (
    content_item_id,
    from_state,
    to_state,
    action_key,
    actor_user_id,
    actor_scope,
    note_ar,
    metadata
  )
  values (
    v_item_id,
    null,
    'draft',
    'mobile_create_draft',
    v_actor,
    'mobile_app',
    'تم إنشاء مسودة من تطبيق الهاتف.',
    jsonb_build_object('official_path', v_official_path)
  );

  insert into media_center.mobile_publish_events (
    content_item_id,
    action_key,
    actor_user_id,
    from_status,
    to_status,
    official_path,
    metadata
  )
  values (
    v_item_id,
    'mobile_create_draft',
    v_actor,
    null,
    'draft',
    v_official_path,
    jsonb_build_object('content_type', v_content_type)
  );

  return jsonb_build_object(
    'success', true,
    'content_item_id', v_item_id,
    'status', 'draft',
    'official_path', v_official_path,
    'official_url', v_official_path,
    'message_ar', 'تم حفظ المسودة على المنصة الرسمية.',
    'public_visibility_granted', false,
    'production_approved', false
  );
end;
$$;

create or replace function public.rpc_media_center_mobile_submit_for_review_v1(
  p_content_item_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path = public, media_center, auth, pg_temp
as $$
declare
  v_actor uuid := auth.uid();
  v_old_status text;
  v_content_type text;
  v_official_path text;
begin
  if v_actor is null then
    raise exception 'AUTH_REQUIRED' using errcode = '28000';
  end if;

  select status, content_type
    into v_old_status, v_content_type
  from media_center.content_items
  where id = p_content_item_id
  for update;

  if v_old_status is null then
    raise exception 'CONTENT_ITEM_NOT_FOUND' using errcode = '02000';
  end if;

  if v_old_status not in ('draft','rejected') then
    raise exception 'CONTENT_ITEM_NOT_SUBMITTABLE_FROM_STATUS: %', v_old_status using errcode = '22023';
  end if;

  update media_center.content_items
  set
    status = 'in_review',
    updated_by = v_actor,
    updated_at = now()
  where id = p_content_item_id;

  v_official_path := public.rpc_media_center_official_path_v1(v_content_type, p_content_item_id);

  insert into media_center.editorial_events (
    content_item_id,
    from_state,
    to_state,
    action_key,
    actor_user_id,
    actor_scope,
    note_ar,
    metadata
  )
  values (
    p_content_item_id,
    v_old_status,
    'in_review',
    'mobile_submit_for_review',
    v_actor,
    'mobile_app',
    'تم إرسال المحتوى للمراجعة من تطبيق الهاتف.',
    jsonb_build_object('official_path', v_official_path)
  );

  insert into media_center.mobile_publish_events (
    content_item_id,
    action_key,
    actor_user_id,
    from_status,
    to_status,
    official_path
  )
  values (
    p_content_item_id,
    'mobile_submit_for_review',
    v_actor,
    v_old_status,
    'in_review',
    v_official_path
  );

  return jsonb_build_object(
    'success', true,
    'content_item_id', p_content_item_id,
    'status', 'in_review',
    'official_path', v_official_path,
    'official_url', v_official_path,
    'message_ar', 'تم إرسال المحتوى للمراجعة. لن يظهر للجمهور قبل الاعتماد.',
    'public_visibility_granted', false,
    'production_approved', false
  );
end;
$$;

create or replace function public.rpc_media_center_mobile_publish_v1(
  p_content_item_id uuid
)
returns jsonb
language plpgsql
security definer
set search_path = public, media_center, auth, pg_temp
as $$
declare
  v_actor uuid := auth.uid();
  v_old_status text;
  v_content_type text;
  v_official_path text;
begin
  if v_actor is null then
    raise exception 'AUTH_REQUIRED' using errcode = '28000';
  end if;

  if not public.rpc_media_center_mobile_actor_can_publish_v1() then
    raise exception 'MEDIA_CENTER_PUBLISH_PERMISSION_REQUIRED' using errcode = '42501';
  end if;

  select status, content_type
    into v_old_status, v_content_type
  from media_center.content_items
  where id = p_content_item_id
  for update;

  if v_old_status is null then
    raise exception 'CONTENT_ITEM_NOT_FOUND' using errcode = '02000';
  end if;

  if v_old_status not in ('draft','in_review','approved','scheduled') then
    raise exception 'CONTENT_ITEM_NOT_PUBLISHABLE_FROM_STATUS: %', v_old_status using errcode = '22023';
  end if;

  update media_center.content_items
  set
    status = 'published',
    visibility_scope = 'public',
    published_at = coalesce(published_at, now()),
    updated_by = v_actor,
    updated_at = now()
  where id = p_content_item_id;

  v_official_path := public.rpc_media_center_official_path_v1(v_content_type, p_content_item_id);

  insert into media_center.editorial_events (
    content_item_id,
    from_state,
    to_state,
    action_key,
    actor_user_id,
    actor_scope,
    note_ar,
    metadata
  )
  values (
    p_content_item_id,
    v_old_status,
    'published',
    'mobile_publish_now',
    v_actor,
    'mobile_app',
    'تم النشر المباشر من تطبيق الهاتف بواسطة ناشر معتمد.',
    jsonb_build_object(
      'official_path', v_official_path,
      'social_media_policy', 'share_official_link_only'
    )
  );

  insert into media_center.mobile_publish_events (
    content_item_id,
    action_key,
    actor_user_id,
    from_status,
    to_status,
    official_path,
    metadata
  )
  values (
    p_content_item_id,
    'mobile_publish_now',
    v_actor,
    v_old_status,
    'published',
    v_official_path,
    jsonb_build_object('social_media_policy', 'share_official_link_only')
  );

  return jsonb_build_object(
    'success', true,
    'content_item_id', p_content_item_id,
    'status', 'published',
    'official_path', v_official_path,
    'official_url', v_official_path,
    'message_ar', 'تم النشر رسميًا. شارك الرابط الرسمي فقط.',
    'public_visibility_granted', true,
    'production_approved', false
  );
end;
$$;

create or replace function public.rpc_media_center_public_content_detail_v1(
  p_family text,
  p_content_item_id text
)
returns jsonb
language plpgsql
security definer
set search_path = public, media_center, pg_temp
as $$
declare
  v_family text := lower(trim(coalesce(p_family, 'news')));
  v_content_type text;
  v_item_id uuid;
  v_row media_center.content_items%rowtype;
  v_official_path text;
begin
  v_content_type := case
    when v_family in ('news','new') then 'news'
    when v_family in ('announcements','announcement') then 'announcement'
    when v_family in ('activities','activity') then 'activity'
    else 'news'
  end;

  begin
    v_item_id := p_content_item_id::uuid;
  exception when others then
    raise exception 'INVALID_CONTENT_ITEM_ID' using errcode = '22023';
  end;

  select *
    into v_row
  from media_center.content_items
  where id = v_item_id
    and content_type = v_content_type
    and status = 'published'
    and visibility_scope = 'public'
    and (published_at is null or published_at <= now());

  if v_row.id is null then
    raise exception 'PUBLIC_CONTENT_NOT_FOUND' using errcode = '02000';
  end if;

  v_official_path := public.rpc_media_center_official_path_v1(v_row.content_type, v_row.id);

  return jsonb_build_object(
    'id', v_row.id,
    'family', v_family,
    'content_type', v_row.content_type,
    'title_ar', v_row.title_ar,
    'summary_ar', v_row.summary_ar,
    'body_ar', v_row.body_ar,
    'unit_slug', v_row.unit_slug,
    'published_at', v_row.published_at,
    'official_path', v_official_path,
    'official_url', v_official_path,
    'source', 'official_platform',
    'production_approved', false
  );
end;
$$;

grant execute on function public.rpc_media_center_mobile_actor_can_publish_v1() to authenticated;
grant execute on function public.rpc_media_center_official_path_v1(text, uuid) to authenticated, anon;
grant execute on function public.rpc_media_center_mobile_create_draft_v1(
  text, text, text, text, uuid, text, text, text, text, bigint
) to authenticated;
grant execute on function public.rpc_media_center_mobile_submit_for_review_v1(uuid) to authenticated;
grant execute on function public.rpc_media_center_mobile_publish_v1(uuid) to authenticated;
grant execute on function public.rpc_media_center_public_content_detail_v1(text, text) to authenticated, anon;

commit;

select
  'media_center_official_first_mobile_publish_apply_result' as section,
  to_regclass('media_center.mobile_publish_events') is not null as mobile_publish_events_present,
  to_regprocedure('public.rpc_media_center_mobile_create_draft_v1(text,text,text,text,uuid,text,text,text,text,bigint)') is not null as create_draft_rpc_present,
  to_regprocedure('public.rpc_media_center_mobile_submit_for_review_v1(uuid)') is not null as submit_review_rpc_present,
  to_regprocedure('public.rpc_media_center_mobile_publish_v1(uuid)') is not null as publish_rpc_present,
  to_regprocedure('public.rpc_media_center_public_content_detail_v1(text,text)') is not null as public_detail_rpc_present,
  false as public_base_table_created,
  false as production_approved;
