-- Mega Batch L1 — Platform Centers View Column Order Fix + Detail/Workflow Hardening Re-Apply
-- Purpose:
--   Fix Mega Batch L SQL failure:
--   ERROR 42P16: cannot change name of view column "title_ar" to "category_key".
-- Cause:
--   PostgreSQL CREATE OR REPLACE VIEW requires existing view column names/order to remain unchanged.
-- Strategy:
--   Preserve the existing public.v_platform_center_content column order from Mega Batch I,
--   then append detail-safe columns at the end.
-- Safety:
--   This script only touches platform_content schema objects and public wrappers/views.
--   It does NOT touch waqf.*, awqaf_system_content, awqaf_system workflow, mustakshif, cases, tasks, or billing tables.

begin;

-- -----------------------------------------------------------------------------
-- 1) Recreate public view while preserving existing Mega I column order.
-- Existing Mega I order:
-- id, family_key, title_ar, summary_ar, owner_name, scope_type, workflow_status,
-- status, public_route, published_at, document_url, unit_slug, is_featured,
-- sort_order, metadata, created_at, updated_at
-- New detail-safe columns are appended only at the end:
-- body_ar, category_key
-- -----------------------------------------------------------------------------
create or replace view public.v_platform_center_content as
select
  i.id::text as id,
  i.family_key,
  i.title_ar,
  coalesce(i.summary_ar, '') as summary_ar,
  coalesce(
    i.owner_name_ar,
    case
      when i.scope_type = 'unit' then coalesce(i.unit_slug, 'وحدة')
      else 'الوزارة'
    end
  ) as owner_name,
  i.scope_type,
  i.workflow_status,
  i.publication_status as status,
  coalesce(i.public_route, '/' || replace(i.family_key, '_', '-')) as public_route,
  i.published_at,
  i.document_url,
  i.unit_slug,
  i.is_featured,
  i.sort_order,
  i.metadata,
  i.created_at,
  i.updated_at,
  coalesce(i.body_ar, i.summary_ar, '') as body_ar,
  coalesce(i.category_key, 'general') as category_key
from platform_content.center_content_items i
where i.is_active is true
  and i.workflow_status = 'published'
  and i.publication_status = 'published'
  and (i.published_at is null or i.published_at <= now());

comment on view public.v_platform_center_content is
  'Public published-only wrapper view for platform_content.center_content_items. Mega L1 preserves the original Mega I column order and appends detail-safe columns body_ar/category_key.';

grant select on public.v_platform_center_content to anon, authenticated;

-- -----------------------------------------------------------------------------
-- 2) Public/admin detail RPC for /family/:id pages.
-- Public users read only from the published-only public view.
-- Admin users with media_center_can_read_v1() can read non-published workflow rows.
-- -----------------------------------------------------------------------------
drop function if exists public.pwf_platform_center_content_get(text, text, text);

create or replace function public.pwf_platform_center_content_get(
  p_id text,
  p_family_key text default null,
  p_unit_slug text default 'home'
)
returns table(
  id text,
  family_key text,
  category_key text,
  title_ar text,
  summary_ar text,
  body_ar text,
  owner_name text,
  scope_type text,
  unit_slug text,
  workflow_status text,
  public_route text,
  published_at timestamptz,
  document_url text,
  metadata jsonb
)
language plpgsql
security definer
set search_path = public, platform_content
as $$
declare
  v_id uuid;
  v_family_key text := replace(nullif(coalesce(p_family_key, ''), ''), '-', '_');
  v_unit_slug text := coalesce(nullif(p_unit_slug, ''), 'home');
  v_can_admin_read boolean := public.media_center_can_read_v1();
begin
  begin
    v_id := p_id::uuid;
  exception when others then
    return;
  end;

  if v_can_admin_read is false then
    return query
    select
      v.id,
      v.family_key,
      v.category_key,
      v.title_ar,
      v.summary_ar,
      v.body_ar,
      v.owner_name,
      v.scope_type,
      v.unit_slug,
      v.workflow_status,
      v.public_route,
      v.published_at,
      v.document_url,
      v.metadata
    from public.v_platform_center_content v
    where v.id = v_id::text
      and (v_family_key is null or v.family_key = v_family_key)
      and (v_unit_slug = 'home' or coalesce(v.unit_slug, 'home') in ('home', v_unit_slug));
    return;
  end if;

  return query
  select
    i.id::text,
    i.family_key,
    coalesce(i.category_key, 'general') as category_key,
    i.title_ar,
    coalesce(i.summary_ar, '') as summary_ar,
    coalesce(i.body_ar, i.summary_ar, '') as body_ar,
    coalesce(
      i.owner_name_ar,
      case
        when i.scope_type = 'unit' then coalesce(i.unit_slug, 'وحدة')
        else 'الوزارة'
      end
    ) as owner_name,
    i.scope_type,
    i.unit_slug,
    i.workflow_status,
    coalesce(i.public_route, '/' || replace(i.family_key, '_', '-')) as public_route,
    i.published_at,
    i.document_url,
    i.metadata
  from platform_content.center_content_items i
  where i.id = v_id
    and i.is_active is true
    and (v_family_key is null or i.family_key = v_family_key)
    and (v_unit_slug = 'home' or coalesce(i.unit_slug, 'home') in ('home', v_unit_slug));
end;
$$;

grant execute on function public.pwf_platform_center_content_get(text, text, text) to anon, authenticated;

-- -----------------------------------------------------------------------------
-- 3) Replace upsert wrapper with production form contract.
-- Keep function name aligned with Flutter repository.
-- The 10-arg function has defaults and remains compatible with named RPC calls.
-- -----------------------------------------------------------------------------
drop function if exists public.pwf_platform_center_content_upsert(text, text, text, text, text);
drop function if exists public.pwf_platform_center_content_upsert(text, text, text, text, text, text, text, text, text, jsonb);

create or replace function public.pwf_platform_center_content_upsert(
  p_family_key text,
  p_title text,
  p_summary text,
  p_scope_type text default 'central',
  p_unit_slug text default 'home',
  p_id text default null,
  p_body text default null,
  p_category_key text default 'general',
  p_document_url text default null,
  p_metadata jsonb default '{}'::jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = public, platform_content
as $$
declare
  v_id uuid;
  v_family_key text := replace(coalesce(nullif(p_family_key, ''), 'media_center'), '-', '_');
  v_scope_type text := coalesce(nullif(p_scope_type, ''), 'central');
  v_unit_slug text := coalesce(nullif(p_unit_slug, ''), 'home');
  v_public_route text := '/' || replace(v_family_key, '_', '-');
  v_is_update boolean := false;
  v_previous_status text := null;
begin
  if not public.media_center_can_write_v1() then
    return jsonb_build_object('success', false, 'id', p_id, 'message_ar', 'لا تملك صلاحية حفظ محتوى مراكز المنصة.');
  end if;

  if btrim(coalesce(p_title, '')) = '' then
    return jsonb_build_object('success', false, 'id', p_id, 'message_ar', 'العنوان مطلوب.');
  end if;

  if v_scope_type not in ('central', 'unit', 'system', 'internal') then
    v_scope_type := 'central';
  end if;

  if v_scope_type = 'unit' and v_unit_slug = 'home' then
    return jsonb_build_object('success', false, 'id', p_id, 'message_ar', 'نطاق الوحدة يحتاج unitSlug حقيقيًا؛ لا تستخدم unit-demo أو home.');
  end if;

  if nullif(p_id, '') is not null then
    begin
      v_id := p_id::uuid;
    exception when others then
      return jsonb_build_object('success', false, 'id', p_id, 'message_ar', 'معرف المحتوى غير صالح.');
    end;
    v_is_update := true;
  end if;

  if v_is_update then
    select workflow_status
    into v_previous_status
    from platform_content.center_content_items
    where id = v_id
      and family_key = v_family_key
      and is_active is true;

    if not found then
      return jsonb_build_object('success', false, 'id', p_id, 'message_ar', 'لم يتم العثور على عنصر المحتوى المطلوب للتعديل.');
    end if;

    update platform_content.center_content_items
    set title_ar = p_title,
        summary_ar = nullif(p_summary, ''),
        body_ar = nullif(p_body, ''),
        category_key = coalesce(nullif(p_category_key, ''), category_key, 'general'),
        scope_type = v_scope_type,
        unit_slug = v_unit_slug,
        document_url = nullif(p_document_url, ''),
        public_route = v_public_route,
        metadata = coalesce(metadata, '{}'::jsonb) || coalesce(p_metadata, '{}'::jsonb),
        updated_by = auth.uid(),
        updated_at = now()
    where id = v_id
      and family_key = v_family_key
      and is_active is true;
  else
    insert into platform_content.center_content_items (
      family_key,
      category_key,
      title_ar,
      summary_ar,
      body_ar,
      scope_type,
      unit_slug,
      workflow_status,
      publication_status,
      public_route,
      document_url,
      created_by,
      updated_by,
      metadata
    ) values (
      v_family_key,
      coalesce(nullif(p_category_key, ''), 'general'),
      p_title,
      nullif(p_summary, ''),
      nullif(p_body, ''),
      v_scope_type,
      v_unit_slug,
      'draft',
      'draft',
      v_public_route,
      nullif(p_document_url, ''),
      auth.uid(),
      auth.uid(),
      coalesce(p_metadata, '{}'::jsonb) || jsonb_build_object('created_from', 'pwf_platform_center_content_upsert')
    ) returning id into v_id;

    v_previous_status := null;
  end if;

  insert into platform_content.center_content_workflow_events (
    content_item_id,
    family_key,
    action_key,
    from_status,
    to_status,
    decision_label_ar,
    actor_id,
    unit_slug,
    source_route,
    notes,
    metadata
  ) values (
    v_id,
    v_family_key,
    case when v_is_update then 'update_content' else 'create_draft' end,
    v_previous_status,
    case when v_is_update then coalesce(v_previous_status, 'draft') else 'draft' end,
    case when v_is_update then 'تحديث محتوى' else 'إنشاء مسودة' end,
    auth.uid(),
    v_unit_slug,
    v_public_route,
    case when v_is_update then 'تم تحديث بيانات المحتوى من محرر مراكز المنصة.' else 'تم إنشاء مسودة من واجهة مراكز المنصة.' end,
    coalesce(p_metadata, '{}'::jsonb)
  );

  return jsonb_build_object(
    'success', true,
    'id', v_id::text,
    'message_ar', case when v_is_update then 'تم حفظ التعديلات في platform_content.center_content_items.' else 'تم حفظ المسودة في platform_content.center_content_items.' end
  );
end;
$$;

grant execute on function public.pwf_platform_center_content_upsert(text, text, text, text, text, text, text, text, text, jsonb) to authenticated;

-- -----------------------------------------------------------------------------
-- 4) Harden workflow transitions at DB/RPC level.
-- UI buttons are not the source of truth.
-- -----------------------------------------------------------------------------
create or replace function public.pwf_platform_center_content_transition(
  p_id text,
  p_family_key text,
  p_action text
)
returns jsonb
language plpgsql
security definer
set search_path = public, platform_content
as $$
declare
  v_id uuid;
  v_current_status text;
  v_new_status text;
  v_family_key text := replace(coalesce(nullif(p_family_key, ''), 'media_center'), '-', '_');
  v_action text := coalesce(nullif(p_action, ''), '');
  v_unit_slug text;
begin
  if not public.media_center_can_write_v1() then
    return jsonb_build_object('success', false, 'id', p_id, 'message_ar', 'لا تملك صلاحية تنفيذ إجراء سير العمل.');
  end if;

  begin
    v_id := p_id::uuid;
  exception when others then
    return jsonb_build_object('success', false, 'id', p_id, 'message_ar', 'معرف المحتوى غير صالح.');
  end;

  select workflow_status, unit_slug
  into v_current_status, v_unit_slug
  from platform_content.center_content_items
  where id = v_id
    and family_key = v_family_key
    and is_active is true;

  if not found then
    return jsonb_build_object('success', false, 'id', p_id, 'message_ar', 'لم يتم العثور على عنصر المحتوى المطلوب.');
  end if;

  v_new_status := case
    when v_action in ('submit_review', 'review') and v_current_status in ('draft', 'rejected') then 'in_review'
    when v_action = 'approve' and v_current_status = 'in_review' then 'ready_to_publish'
    when v_action = 'reject' and v_current_status = 'in_review' then 'rejected'
    when v_action = 'schedule' and v_current_status = 'ready_to_publish' then 'scheduled'
    when v_action = 'publish' and v_current_status in ('ready_to_publish', 'scheduled') then 'published'
    when v_action = 'archive' and v_current_status = 'published' then 'archived'
    else null
  end;

  if v_new_status is null then
    return jsonb_build_object(
      'success', false,
      'id', p_id,
      'from_status', v_current_status,
      'message_ar', 'انتقال سير العمل غير مسموح: ' || coalesce(v_current_status, 'unknown') || ' → ' || coalesce(v_action, 'unknown')
    );
  end if;

  update platform_content.center_content_items
  set workflow_status = v_new_status,
      publication_status = case
        when v_new_status = 'published' then 'published'
        when v_new_status = 'archived' then 'archived'
        when v_new_status in ('in_review', 'ready_to_publish', 'scheduled', 'rejected') then 'internal'
        else publication_status
      end,
      published_at = case when v_new_status = 'published' then coalesce(published_at, now()) else published_at end,
      archived_at = case when v_new_status = 'archived' then coalesce(archived_at, now()) else archived_at end,
      updated_by = auth.uid(),
      updated_at = now(),
      reviewed_by = case when v_new_status in ('ready_to_publish', 'scheduled', 'published') then auth.uid() else reviewed_by end,
      published_by = case when v_new_status = 'published' then auth.uid() else published_by end
  where id = v_id;

  insert into platform_content.center_content_workflow_events (
    content_item_id,
    family_key,
    action_key,
    from_status,
    to_status,
    decision_label_ar,
    actor_id,
    unit_slug,
    source_route,
    notes,
    metadata
  ) values (
    v_id,
    v_family_key,
    v_action,
    v_current_status,
    v_new_status,
    case
      when v_new_status = 'in_review' then 'إرسال للمراجعة'
      when v_new_status = 'ready_to_publish' then 'اعتماد للنشر'
      when v_new_status = 'scheduled' then 'جدولة'
      when v_new_status = 'published' then 'نشر'
      when v_new_status = 'archived' then 'أرشفة'
      when v_new_status = 'rejected' then 'رفض'
      else 'تحديث سير عمل'
    end,
    auth.uid(),
    v_unit_slug,
    '/' || replace(v_family_key, '_', '-'),
    'تم تنفيذ انتقال سير العمل عبر RPC مراكز المنصة بعد تحقق state-machine.',
    jsonb_build_object('requested_action', v_action)
  );

  return jsonb_build_object(
    'success', true,
    'id', v_id::text,
    'from_status', v_current_status,
    'to_status', v_new_status,
    'message_ar', 'تم تحديث حالة سير العمل.'
  );
end;
$$;

grant execute on function public.pwf_platform_center_content_transition(text, text, text) to authenticated;

-- Make PostgREST/Supabase refresh function signatures promptly when supported.
notify pgrst, 'reload schema';

commit;
