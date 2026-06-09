-- PalWakf N2.27
-- Draft only. Do NOT run in production without approval.
-- Purpose: prepare site_content schema ownership surfaces.

-- BEGIN DRAFT
create schema if not exists site_content;

comment on schema site_content is
  'PalWakf site-content bounded domain: page management, homepage structure, header/footer/site settings. Draft N2.27.';

-- Optional governance table for future migration tracking only.
create table if not exists site_content.migration_shadow_registry (
  id uuid primary key default gen_random_uuid(),
  source_schema text not null default 'public',
  source_table text not null,
  target_schema text not null default 'site_content',
  target_table text not null,
  migration_status text not null default 'planned',
  rls_migration_required boolean not null default true,
  rpc_wrapper_required boolean not null default true,
  flutter_migration_required boolean not null default true,
  notes text,
  created_at timestamptz not null default now()
);

comment on table site_content.migration_shadow_registry is
  'Planning registry only. Does not move data. Tracks future site_content migration candidates.';

insert into site_content.migration_shadow_registry (source_table, target_table, notes)
values
  ('site_pages', 'site_pages', 'Candidate: site pages ownership'),
  ('homepage_sections', 'homepage_sections', 'Candidate: dynamic homepage sections'),
  ('home_config', 'home_config', 'Candidate: homepage configuration'),
  ('header_settings', 'header_settings', 'Candidate: header settings'),
  ('footer_settings', 'footer_settings', 'Candidate: footer settings'),
  ('hero_slides', 'hero_slides', 'Candidate: hero slides'),
  ('home_hero_slides', 'home_hero_slides', 'Candidate: legacy/home hero slides'),
  ('home_stats', 'home_stats', 'Candidate: homepage statistics'),
  ('site_settings', 'site_settings', 'Candidate: site settings'),
  ('app_settings', 'app_settings', 'Candidate: app/site public settings'),
  ('former_ministers', 'former_ministers', 'Candidate: public institutional profile content'),
  ('pwf_former_ministers', 'former_ministers_v2', 'Candidate: newer former ministers surface')
on conflict do nothing;
-- END DRAFT
