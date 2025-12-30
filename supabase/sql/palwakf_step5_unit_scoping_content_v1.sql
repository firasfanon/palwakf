-- PalWakf خطوة (5): ربط المحتوى العام (الأخبار/الإعلانات/الأنشطة) بوحدة مؤسسية org_units عبر unit_id
-- الهدف:
-- 1) إضافة العمود unit_id (uuid) للجداول:
--    - news_articles
--    - announcements
--    - activities
-- 2) backfill: أي سجل قديم بدون unit_id => home
-- 3) فرض علاقات وفهارس (FK + INDEX)

begin;

-- Ensure home unit exists
do $$
declare
  v_home_id uuid;
begin
  select id into v_home_id from public.org_units where slug = 'home' limit 1;

  if v_home_id is null then
    insert into public.org_units (unit_type, code, slug, name_ar, name_en, is_active, sort_order)
    values (
      'ministry'::public.org_unit_type,
      'HOME',
      'home',
      'وزارة الأوقاف والشؤون الدينية',
      'Ministry of Awqaf',
      true,
      0
    )
    returning id into v_home_id;
  else
    -- If home exists but code is NULL/empty, fix it (some schemas enforce NOT NULL)
    update public.org_units
    set code = coalesce(nullif(code, ''), 'HOME')
    where id = v_home_id;
  end if;
end
$$;

-- Add unit_id columns (if missing)
alter table public.news_articles add column if not exists unit_id uuid;
alter table public.announcements add column if not exists unit_id uuid;
alter table public.activities add column if not exists unit_id uuid;

-- Backfill existing rows -> home
do $$
declare
  v_home_id uuid;
begin
  select id into v_home_id from public.org_units where slug = 'home' limit 1;
  if v_home_id is null then
    raise exception 'org_units.home is missing';
  end if;

  update public.news_articles set unit_id = v_home_id where unit_id is null;
  update public.announcements set unit_id = v_home_id where unit_id is null;
  update public.activities set unit_id = v_home_id where unit_id is null;
end
$$;

-- FK constraints (safe)
do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'news_articles_unit_id_fkey'
  ) then
    alter table public.news_articles
      add constraint news_articles_unit_id_fkey
      foreign key (unit_id) references public.org_units(id) on delete restrict;
  end if;

  if not exists (
    select 1 from pg_constraint
    where conname = 'announcements_unit_id_fkey'
  ) then
    alter table public.announcements
      add constraint announcements_unit_id_fkey
      foreign key (unit_id) references public.org_units(id) on delete restrict;
  end if;

  if not exists (
    select 1 from pg_constraint
    where conname = 'activities_unit_id_fkey'
  ) then
    alter table public.activities
      add constraint activities_unit_id_fkey
      foreign key (unit_id) references public.org_units(id) on delete restrict;
  end if;
end
$$;

-- Not null (after backfill)
alter table public.news_articles alter column unit_id set not null;
alter table public.announcements alter column unit_id set not null;
alter table public.activities alter column unit_id set not null;

-- Helpful indexes
create index if not exists idx_news_articles_unit_published on public.news_articles (unit_id, published_at desc);
create index if not exists idx_announcements_unit_created on public.announcements (unit_id, created_at desc);
create index if not exists idx_activities_unit_start on public.activities (unit_id, start_date desc);

commit;
