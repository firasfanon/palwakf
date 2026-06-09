-- PalWakf خطوة (6): ربط (Hero Slides + Breaking News) بوحدة مؤسسية org_units عبر unit_id
--
-- ملاحظة:
-- لا نفرض NOT NULL الآن حتى لا نكسر إدخالات الإدارة الحالية التي قد لا ترسل unit_id.

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
    update public.org_units
    set code = coalesce(nullif(code, ''), 'HOME')
    where id = v_home_id;
  end if;
end
$$;

-- Add unit_id columns (if missing)
alter table public.hero_slides add column if not exists unit_id uuid;
alter table public.breaking_news add column if not exists unit_id uuid;

-- Backfill existing rows -> home
do $$
declare
  v_home_id uuid;
begin
  select id into v_home_id from public.org_units where slug = 'home' limit 1;
  if v_home_id is null then
    raise exception 'org_units.home is missing';
  end if;

  update public.hero_slides set unit_id = v_home_id where unit_id is null;
  update public.breaking_news set unit_id = v_home_id where unit_id is null;
end
$$;

-- FK constraints (safe)
do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'hero_slides_unit_id_fkey'
  ) then
    alter table public.hero_slides
      add constraint hero_slides_unit_id_fkey
      foreign key (unit_id) references public.org_units(id) on delete restrict;
  end if;

  if not exists (
    select 1 from pg_constraint
    where conname = 'breaking_news_unit_id_fkey'
  ) then
    alter table public.breaking_news
      add constraint breaking_news_unit_id_fkey
      foreign key (unit_id) references public.org_units(id) on delete restrict;
  end if;
end
$$;

-- Helpful indexes
create index if not exists idx_hero_slides_unit_order on public.hero_slides (unit_id, display_order);
create index if not exists idx_breaking_news_unit_order on public.breaking_news (unit_id, display_order);

commit;
