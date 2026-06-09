-- Mega Batch H — Productive Platform Centers Data Binding + CRUD Completion
-- Scope: public RPC wrappers only. No waqf_assets mutation. No awqaf_system mutation.
-- This script defines platform-center content contracts for UI binding.
-- It is safe as a wrapper layer and does not create new sovereign tables.

create or replace function public.pwf_platform_center_content_list(
  p_family_key text,
  p_unit_slug text default 'home',
  p_published_only boolean default false,
  p_limit integer default 12
)
returns table(
  id text,
  family_key text,
  title_ar text,
  summary_ar text,
  owner_name text,
  scope_type text,
  workflow_status text,
  public_route text,
  published_at timestamptz,
  document_url text
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_limit integer := greatest(1, least(coalesce(p_limit, 12), 50));
begin
  -- Preferred integration contract: a public view/wrapper named v_platform_center_content.
  -- The view may unify media items, legal references, observatory records, events, and service-center highlights.
  if to_regclass('public.v_platform_center_content') is not null then
    return query execute '
      select
        id::text,
        family_key::text,
        coalesce(title_ar, title, name_ar, name)::text as title_ar,
        coalesce(summary_ar, summary, description_ar, description, '''')::text as summary_ar,
        coalesce(owner_name, unit_name, ''الوزارة'')::text as owner_name,
        coalesce(scope_type, ''central'')::text as scope_type,
        coalesce(workflow_status, status, ''draft'')::text as workflow_status,
        coalesce(public_route, route, '''')::text as public_route,
        published_at::timestamptz,
        document_url::text
      from public.v_platform_center_content
      where family_key = $1
        and ($2 = ''home'' or coalesce(unit_slug, ''home'') in (''home'', $2))
        and ($3 is false or coalesce(workflow_status, status, '''') in (''published'', ''ready_to_publish'', ''منشور'', ''جاهز للنشر''))
      order by published_at desc nulls last, id desc
      limit $4'
    using replace(coalesce(p_family_key, 'media_center'), '-', '_'), coalesce(nullif(p_unit_slug, ''), 'home'), coalesce(p_published_only, false), v_limit;
    return;
  end if;

  -- No backing view yet: return zero rows. Flutter repository has explicit fallback rendering.
  return;
end;
$$;

create or replace function public.pwf_platform_center_content_upsert(
  p_family_key text,
  p_title text,
  p_summary text,
  p_scope_type text default 'central',
  p_unit_slug text default 'home'
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_id text := gen_random_uuid()::text;
begin
  if to_regclass('public.platform_center_content_drafts') is not null then
    execute '
      insert into public.platform_center_content_drafts
        (id, family_key, title_ar, summary_ar, scope_type, unit_slug, workflow_status, created_at)
      values ($1, $2, $3, $4, $5, $6, ''draft'', now())'
    using v_id, replace(coalesce(p_family_key, 'media_center'), '-', '_'), p_title, p_summary, coalesce(p_scope_type, 'central'), coalesce(nullif(p_unit_slug, ''), 'home');
    return jsonb_build_object('success', true, 'id', v_id, 'message_ar', 'تم حفظ المسودة.');
  end if;

  return jsonb_build_object(
    'success', false,
    'id', null,
    'message_ar', 'لم يتم إنشاء public.platform_center_content_drafts بعد؛ واجهة الإدارة جاهزة لكن الحفظ الإنتاجي غير مفعل.'
  );
end;
$$;

create or replace function public.pwf_platform_center_content_transition(
  p_id text,
  p_family_key text,
  p_action text
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_status text := case
    when p_action = 'review' then 'in_review'
    when p_action = 'schedule' then 'ready_to_publish'
    when p_action = 'publish' then 'published'
    when p_action = 'archive' then 'archived'
    else 'draft'
  end;
begin
  if to_regclass('public.platform_center_content_drafts') is not null then
    execute '
      update public.platform_center_content_drafts
      set workflow_status = $1, updated_at = now()
      where id::text = $2 and family_key = $3'
    using v_status, p_id, replace(coalesce(p_family_key, 'media_center'), '-', '_');
    return jsonb_build_object('success', true, 'id', p_id, 'message_ar', 'تم تحديث حالة سير العمل.');
  end if;

  return jsonb_build_object(
    'success', false,
    'id', p_id,
    'message_ar', 'لم يتم تفعيل جدول مسودات مراكز المنصة بعد؛ الإجراء موثق كعقد UI فقط.'
  );
end;
$$;
