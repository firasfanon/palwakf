-- PalWakf Hotfix: Seed home_config rows for ALL org units
-- Goal: make Home Management unit dropdown show every unit (not just home/bth/jer)
-- Safe: inserts missing rows only.

-- Source of truth for units: public.pwf_org_units_cache (populated from core.org_units)
-- If your cache/view name differs, replace it with the table/view you are using.

insert into public.home_config (
  id,
  hero_title,
  hero_subtitle,
  hero_image_url,
  about_text,
  show_stats,
  show_news,
  show_services,
  updated_at
)
select
  u.slug as id,
  coalesce(u.name_ar, 'وحدة') as hero_title,
  coalesce(u.name_en, '') as hero_subtitle,
  null as hero_image_url,
  '' as about_text,
  true as show_stats,
  true as show_news,
  true as show_services,
  now() as updated_at
from public.pwf_org_units_cache u
where u.slug is not null
  and u.slug <> ''
on conflict (id) do nothing;

-- Optional: keep HOME/GLOBAL present even if not in cache
insert into public.home_config (
  id,
  hero_title,
  hero_subtitle,
  hero_image_url,
  about_text,
  show_stats,
  show_news,
  show_services,
  updated_at
)
values
  ('home', 'وزارة الأوقاف والشؤون الدينية', '', null, '', true, true, true, now()),
  ('global', 'المنصة العامة', '', null, '', true, true, true, now())
on conflict (id) do nothing;
