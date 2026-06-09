-- Mega Batch I — Platform Centers Backend Tables + RPC Production Readiness
-- Scope: create production-ready backing schema for platform center content.
-- Governance:
--   - Operational data lives in platform_content.*
--   - public remains for views/RPC wrappers only.
--   - No waqf_assets mutation.
--   - No awqaf_system mutation.
--   - Existing public.awqaf_system_content remains owned by awqaf_system and is not reused here.

begin;

create schema if not exists platform_content;

comment on schema platform_content is
  'Operational schema for PalWakf platform center content: media center, services highlights, legal references, events, and public homepage-bound content. public schema remains for views/RPC wrappers.';

-- -----------------------------------------------------------------------------
-- 1) Dictionaries / categories
-- -----------------------------------------------------------------------------
create table if not exists platform_content.center_content_categories (
  id uuid primary key default gen_random_uuid(),
  family_key text not null,
  category_key text not null,
  label_ar text not null,
  description_ar text,
  display_order integer not null default 100,
  is_active boolean not null default true,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint center_content_categories_family_key_chk check (btrim(family_key) <> ''),
  constraint center_content_categories_category_key_chk check (btrim(category_key) <> ''),
  constraint center_content_categories_unique unique (family_key, category_key)
);

comment on table platform_content.center_content_categories is
  'Optional categories for platform center content families such as press release type, campaign type, legal reference type, observatory incident type, and event type.';

-- -----------------------------------------------------------------------------
-- 2) Main content table
-- -----------------------------------------------------------------------------
create table if not exists platform_content.center_content_items (
  id uuid primary key default gen_random_uuid(),
  family_key text not null,
  category_key text,
  title_ar text not null,
  summary_ar text,
  body_ar text,
  scope_type text not null default 'central',
  unit_id uuid,
  unit_slug text not null default 'home',
  owner_org_unit_id uuid,
  owner_name_ar text,
  workflow_status text not null default 'draft',
  publication_status text not null default 'draft',
  public_route text,
  document_url text,
  hero_image_url text,
  starts_at timestamptz,
  ends_at timestamptz,
  scheduled_at timestamptz,
  published_at timestamptz,
  archived_at timestamptz,
  featured_until timestamptz,
  is_featured boolean not null default false,
  is_active boolean not null default true,
  sort_order integer not null default 100,
  source_system text not null default 'platform_content',
  created_by uuid,
  updated_by uuid,
  reviewed_by uuid,
  published_by uuid,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint center_content_items_family_key_chk check (btrim(family_key) <> ''),
  constraint center_content_items_title_ar_chk check (btrim(title_ar) <> ''),
  constraint center_content_items_scope_type_chk check (scope_type in ('central', 'unit', 'system', 'internal')),
  constraint center_content_items_workflow_status_chk check (workflow_status in ('draft', 'in_review', 'ready_to_publish', 'published', 'scheduled', 'archived', 'rejected')),
  constraint center_content_items_publication_status_chk check (publication_status in ('draft', 'internal', 'published', 'archived'))
);

comment on table platform_content.center_content_items is
  'Unified operational content table for PalWakf platform centers. Families include social_posts, press_releases, official_statements, awareness_campaigns, sanctities_observatory, legal_references, events, media_reports, media_coverage, waqf_impact_stories, and services_center.';

create index if not exists center_content_items_family_status_idx
  on platform_content.center_content_items (family_key, workflow_status, published_at desc nulls last);

create index if not exists center_content_items_scope_unit_idx
  on platform_content.center_content_items (scope_type, unit_slug, family_key);

create index if not exists center_content_items_featured_idx
  on platform_content.center_content_items (is_featured, featured_until, published_at desc nulls last)
  where is_featured is true;

create index if not exists center_content_items_metadata_gin_idx
  on platform_content.center_content_items using gin (metadata);

-- -----------------------------------------------------------------------------
-- 3) Workflow / audit events
-- -----------------------------------------------------------------------------
create table if not exists platform_content.center_content_workflow_events (
  id uuid primary key default gen_random_uuid(),
  content_item_id uuid not null references platform_content.center_content_items(id) on delete cascade,
  family_key text not null,
  action_key text not null,
  from_status text,
  to_status text,
  decision_label_ar text,
  actor_id uuid,
  actor_role text,
  unit_slug text,
  source_route text,
  notes text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  constraint center_content_workflow_events_action_chk check (btrim(action_key) <> '')
);

comment on table platform_content.center_content_workflow_events is
  'Workflow event ledger for platform center content: create, update, submit_review, approve, schedule, publish, archive, reject.';

create index if not exists center_content_workflow_events_item_idx
  on platform_content.center_content_workflow_events (content_item_id, created_at desc);

create index if not exists center_content_workflow_events_family_idx
  on platform_content.center_content_workflow_events (family_key, action_key, created_at desc);

-- -----------------------------------------------------------------------------
-- 4) Attachments
-- -----------------------------------------------------------------------------
create table if not exists platform_content.center_content_attachments (
  id uuid primary key default gen_random_uuid(),
  content_item_id uuid not null references platform_content.center_content_items(id) on delete cascade,
  attachment_type text not null default 'file',
  title_ar text,
  file_url text,
  storage_bucket text,
  storage_path text,
  mime_type text,
  file_size_bytes bigint,
  checksum_sha256 text,
  is_primary boolean not null default false,
  is_public boolean not null default false,
  sort_order integer not null default 100,
  metadata jsonb not null default '{}'::jsonb,
  created_by uuid,
  created_at timestamptz not null default now(),
  constraint center_content_attachments_type_chk check (attachment_type in ('image', 'document', 'video', 'link', 'file'))
);

comment on table platform_content.center_content_attachments is
  'Attachments for platform center content including images, PDF/legal references, evidence files, campaign media, and external links.';

create index if not exists center_content_attachments_item_idx
  on platform_content.center_content_attachments (content_item_id, sort_order, created_at desc);

-- -----------------------------------------------------------------------------
-- 5) Optional relations for future system linking. References are kept loose here
--    to avoid coupling or mutating other systems.
-- -----------------------------------------------------------------------------
create table if not exists platform_content.center_content_relations (
  id uuid primary key default gen_random_uuid(),
  content_item_id uuid not null references platform_content.center_content_items(id) on delete cascade,
  related_system text not null,
  related_entity text not null,
  related_id text not null,
  relation_type text not null default 'reference',
  notes text,
  metadata jsonb not null default '{}'::jsonb,
  created_by uuid,
  created_at timestamptz not null default now(),
  constraint center_content_relations_related_system_chk check (btrim(related_system) <> ''),
  constraint center_content_relations_related_entity_chk check (btrim(related_entity) <> ''),
  constraint center_content_relations_related_id_chk check (btrim(related_id) <> ''),
  constraint center_content_relations_unique unique (content_item_id, related_system, related_entity, related_id, relation_type)
);

comment on table platform_content.center_content_relations is
  'Loose references from platform center content to other systems such as document_intelligence, cases, tasks, assistant, or mustakshif. This table must not mutate those systems.';

-- -----------------------------------------------------------------------------
-- 6) updated_at trigger helper
-- -----------------------------------------------------------------------------
create or replace function platform_content.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_center_content_categories_updated_at on platform_content.center_content_categories;
create trigger trg_center_content_categories_updated_at
before update on platform_content.center_content_categories
for each row execute function platform_content.set_updated_at();

drop trigger if exists trg_center_content_items_updated_at on platform_content.center_content_items;
create trigger trg_center_content_items_updated_at
before update on platform_content.center_content_items
for each row execute function platform_content.set_updated_at();

-- -----------------------------------------------------------------------------
-- 7) Seed controlled family/category dictionary. No content rows are inserted.
-- -----------------------------------------------------------------------------
insert into platform_content.center_content_categories (family_key, category_key, label_ar, display_order)
values
  ('social_posts', 'general', 'اجتماعيات عامة', 10),
  ('press_releases', 'official_press_release', 'بيان صحفي رسمي', 10),
  ('official_statements', 'authorized_statement', 'تصريح رسمي مخوّل', 10),
  ('awareness_campaigns', 'public_awareness', 'حملة توعوية عامة', 10),
  ('sanctities_observatory', 'incident_report', 'تقرير/واقعة موثقة', 10),
  ('legal_references', 'law', 'قانون', 10),
  ('legal_references', 'instruction', 'تعليمات', 20),
  ('legal_references', 'procedure_guide', 'دليل إجرائي', 30),
  ('events', 'public_event', 'فعالية عامة', 10),
  ('media_reports', 'media_report', 'تقرير إعلامي', 10),
  ('media_coverage', 'coverage', 'تغطية إعلامية', 10),
  ('waqf_impact_stories', 'impact_story', 'قصة أثر وقفي', 10),
  ('services_center', 'highlight', 'إبراز خدمة', 10)
on conflict (family_key, category_key) do update
set label_ar = excluded.label_ar,
    display_order = excluded.display_order,
    is_active = true,
    updated_at = now();

-- -----------------------------------------------------------------------------
-- 8) RLS / permissions. Direct access is conservative; public UI should use RPCs.
-- -----------------------------------------------------------------------------
alter table platform_content.center_content_categories enable row level security;
alter table platform_content.center_content_items enable row level security;
alter table platform_content.center_content_workflow_events enable row level security;
alter table platform_content.center_content_attachments enable row level security;
alter table platform_content.center_content_relations enable row level security;

drop policy if exists center_content_categories_read_active on platform_content.center_content_categories;
create policy center_content_categories_read_active
on platform_content.center_content_categories
for select
to anon, authenticated
using (is_active is true);

drop policy if exists center_content_items_public_read_published on platform_content.center_content_items;
create policy center_content_items_public_read_published
on platform_content.center_content_items
for select
to anon, authenticated
using (
  is_active is true
  and workflow_status = 'published'
  and publication_status = 'published'
  and (published_at is null or published_at <= now())
);

drop policy if exists center_content_items_admin_read on platform_content.center_content_items;
create policy center_content_items_admin_read
on platform_content.center_content_items
for select
to authenticated
using (public.media_center_can_read_v1());

drop policy if exists center_content_items_admin_write on platform_content.center_content_items;
create policy center_content_items_admin_write
on platform_content.center_content_items
for all
to authenticated
using (public.media_center_can_write_v1())
with check (public.media_center_can_write_v1());

drop policy if exists center_content_workflow_events_admin_read on platform_content.center_content_workflow_events;
create policy center_content_workflow_events_admin_read
on platform_content.center_content_workflow_events
for select
to authenticated
using (public.media_center_can_read_v1());

drop policy if exists center_content_workflow_events_admin_write on platform_content.center_content_workflow_events;
create policy center_content_workflow_events_admin_write
on platform_content.center_content_workflow_events
for insert
to authenticated
with check (public.media_center_can_write_v1());

drop policy if exists center_content_attachments_public_read on platform_content.center_content_attachments;
create policy center_content_attachments_public_read
on platform_content.center_content_attachments
for select
to anon, authenticated
using (
  is_public is true
  and exists (
    select 1
    from platform_content.center_content_items i
    where i.id = center_content_attachments.content_item_id
      and i.is_active is true
      and i.workflow_status = 'published'
      and i.publication_status = 'published'
  )
);

drop policy if exists center_content_attachments_admin_all on platform_content.center_content_attachments;
create policy center_content_attachments_admin_all
on platform_content.center_content_attachments
for all
to authenticated
using (public.media_center_can_write_v1())
with check (public.media_center_can_write_v1());

drop policy if exists center_content_relations_admin_all on platform_content.center_content_relations;
create policy center_content_relations_admin_all
on platform_content.center_content_relations
for all
to authenticated
using (public.media_center_can_write_v1())
with check (public.media_center_can_write_v1());

-- Grants for RPC/view usage. Direct table access is still governed by RLS.
grant usage on schema platform_content to anon, authenticated;
grant select on platform_content.center_content_categories to anon, authenticated;
grant select on platform_content.center_content_items to anon, authenticated;
grant select on platform_content.center_content_attachments to anon, authenticated;
grant select on platform_content.center_content_workflow_events to authenticated;
grant select, insert, update, delete on platform_content.center_content_items to authenticated;
grant select, insert on platform_content.center_content_workflow_events to authenticated;
grant select, insert, update, delete on platform_content.center_content_attachments to authenticated;
grant select, insert, update, delete on platform_content.center_content_relations to authenticated;

-- -----------------------------------------------------------------------------
-- 9) public view for published/public read contract only
-- -----------------------------------------------------------------------------
create or replace view public.v_platform_center_content as
select
  i.id::text as id,
  i.family_key,
  i.title_ar,
  coalesce(i.summary_ar, '') as summary_ar,
  coalesce(i.owner_name_ar, case when i.scope_type = 'unit' then coalesce(i.unit_slug, 'وحدة') else 'الوزارة' end) as owner_name,
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
  i.updated_at
from platform_content.center_content_items i
where i.is_active is true
  and i.workflow_status = 'published'
  and i.publication_status = 'published'
  and (i.published_at is null or i.published_at <= now());

comment on view public.v_platform_center_content is
  'Public published-only wrapper view for platform_content.center_content_items. Admin drafts/review records are available only through permission-gated RPCs.';

grant select on public.v_platform_center_content to anon, authenticated;

-- -----------------------------------------------------------------------------
-- 10) RPC wrappers aligned with Mega Batch H Flutter contract
-- -----------------------------------------------------------------------------
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
set search_path = public, platform_content
as $$
declare
  v_limit integer := greatest(1, least(coalesce(p_limit, 12), 50));
  v_family_key text := replace(coalesce(nullif(p_family_key, ''), 'media_center'), '-', '_');
  v_unit_slug text := coalesce(nullif(p_unit_slug, ''), 'home');
  v_can_admin_read boolean := public.media_center_can_read_v1();
begin
  -- Public/published path: safe for anon and authenticated users.
  if coalesce(p_published_only, false) is true or v_can_admin_read is false then
    return query
    select
      v.id,
      v.family_key,
      v.title_ar,
      v.summary_ar,
      v.owner_name,
      v.scope_type,
      v.workflow_status,
      v.public_route,
      v.published_at,
      v.document_url
    from public.v_platform_center_content v
    where v.family_key = v_family_key
      and (v_unit_slug = 'home' or coalesce(v.unit_slug, 'home') in ('home', v_unit_slug))
    order by v.published_at desc nulls last, v.sort_order, v.id desc
    limit v_limit;
    return;
  end if;

  -- Admin path: returns drafts/review/scheduled records only when media-center read permission is available.
  return query
  select
    i.id::text,
    i.family_key,
    i.title_ar,
    coalesce(i.summary_ar, '') as summary_ar,
    coalesce(i.owner_name_ar, case when i.scope_type = 'unit' then coalesce(i.unit_slug, 'وحدة') else 'الوزارة' end) as owner_name,
    i.scope_type,
    i.workflow_status,
    coalesce(i.public_route, '/' || replace(i.family_key, '_', '-')) as public_route,
    i.published_at,
    i.document_url
  from platform_content.center_content_items i
  where i.is_active is true
    and i.family_key = v_family_key
    and (v_unit_slug = 'home' or coalesce(i.unit_slug, 'home') in ('home', v_unit_slug))
  order by i.published_at desc nulls last, i.sort_order, i.created_at desc
  limit v_limit;
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
set search_path = public, platform_content
as $$
declare
  v_id uuid;
  v_family_key text := replace(coalesce(nullif(p_family_key, ''), 'media_center'), '-', '_');
  v_scope_type text := coalesce(nullif(p_scope_type, ''), 'central');
  v_unit_slug text := coalesce(nullif(p_unit_slug, ''), 'home');
  v_public_route text := '/' || replace(v_family_key, '_', '-');
begin
  if not public.media_center_can_write_v1() then
    return jsonb_build_object(
      'success', false,
      'id', null,
      'message_ar', 'لا تملك صلاحية إنشاء مسودة في مراكز المنصة.'
    );
  end if;

  if btrim(coalesce(p_title, '')) = '' then
    return jsonb_build_object(
      'success', false,
      'id', null,
      'message_ar', 'العنوان مطلوب لإنشاء المسودة.'
    );
  end if;

  insert into platform_content.center_content_items (
    family_key,
    title_ar,
    summary_ar,
    scope_type,
    unit_slug,
    workflow_status,
    publication_status,
    public_route,
    created_by,
    updated_by,
    metadata
  ) values (
    v_family_key,
    p_title,
    nullif(p_summary, ''),
    case when v_scope_type in ('central', 'unit', 'system', 'internal') then v_scope_type else 'central' end,
    v_unit_slug,
    'draft',
    'draft',
    v_public_route,
    auth.uid(),
    auth.uid(),
    jsonb_build_object('created_from', 'pwf_platform_center_content_upsert')
  )
  returning id into v_id;

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
    'create_draft',
    null,
    'draft',
    'إنشاء مسودة',
    auth.uid(),
    v_unit_slug,
    v_public_route,
    'تم إنشاء مسودة من واجهة مراكز المنصة.',
    '{}'::jsonb
  );

  return jsonb_build_object(
    'success', true,
    'id', v_id::text,
    'message_ar', 'تم حفظ المسودة في platform_content.center_content_items.'
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
set search_path = public, platform_content
as $$
declare
  v_id uuid;
  v_current_status text;
  v_new_status text;
  v_family_key text := replace(coalesce(nullif(p_family_key, ''), 'media_center'), '-', '_');
  v_action text := coalesce(nullif(p_action, ''), 'draft');
  v_unit_slug text;
begin
  if not public.media_center_can_write_v1() then
    return jsonb_build_object(
      'success', false,
      'id', p_id,
      'message_ar', 'لا تملك صلاحية تنفيذ إجراء سير العمل.'
    );
  end if;

  begin
    v_id := p_id::uuid;
  exception when others then
    return jsonb_build_object('success', false, 'id', p_id, 'message_ar', 'معرف المحتوى غير صالح.');
  end;

  v_new_status := case v_action
    when 'review' then 'in_review'
    when 'submit_review' then 'in_review'
    when 'approve' then 'ready_to_publish'
    when 'schedule' then 'scheduled'
    when 'publish' then 'published'
    when 'archive' then 'archived'
    when 'reject' then 'rejected'
    else 'draft'
  end;

  select workflow_status, unit_slug
  into v_current_status, v_unit_slug
  from platform_content.center_content_items
  where id = v_id
    and family_key = v_family_key
    and is_active is true;

  if not found then
    return jsonb_build_object(
      'success', false,
      'id', p_id,
      'message_ar', 'لم يتم العثور على عنصر المحتوى المطلوب.'
    );
  end if;

  update platform_content.center_content_items
  set workflow_status = v_new_status,
      publication_status = case
        when v_new_status = 'published' then 'published'
        when v_new_status = 'archived' then 'archived'
        else publication_status
      end,
      published_at = case when v_new_status = 'published' then coalesce(published_at, now()) else published_at end,
      archived_at = case when v_new_status = 'archived' then coalesce(archived_at, now()) else archived_at end,
      updated_by = auth.uid(),
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
      when v_new_status = 'ready_to_publish' then 'جاهز للنشر'
      when v_new_status = 'scheduled' then 'جدولة'
      when v_new_status = 'published' then 'نشر'
      when v_new_status = 'archived' then 'أرشفة'
      when v_new_status = 'rejected' then 'رفض'
      else 'إرجاع لمسودة'
    end,
    auth.uid(),
    v_unit_slug,
    '/' || replace(v_family_key, '_', '-'),
    'تم تنفيذ انتقال سير العمل عبر RPC مراكز المنصة.',
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

grant execute on function public.pwf_platform_center_content_list(text, text, boolean, integer) to anon, authenticated;
grant execute on function public.pwf_platform_center_content_upsert(text, text, text, text, text) to authenticated;
grant execute on function public.pwf_platform_center_content_transition(text, text, text) to authenticated;

commit;
