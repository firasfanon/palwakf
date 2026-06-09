-- 02_media_assets_contract_extension_apply.sql
-- APPLY. Idempotently extends media_center.content_assets with a legacy mapping contract.
-- No data deletion. No public table mutation. No waqf mutation.

begin;

alter table media_center.content_assets
  add column if not exists legacy_source text,
  add column if not exists legacy_source_id text,
  add column if not exists content_key text,
  add column if not exists unit_slug text,
  add column if not exists source_public_table text,
  add column if not exists published_at timestamptz;

create unique index if not exists idx_media_content_assets_legacy_source_id
  on media_center.content_assets (legacy_source, legacy_source_id)
  where legacy_source is not null and legacy_source_id is not null;

create index if not exists idx_media_content_assets_unit_slug
  on media_center.content_assets (unit_slug);

comment on column media_center.content_assets.legacy_source is
  'Controlled legacy mapping source for asset migration, e.g. public.media_gallery_items. Added by Platform Data Ownership Stabilization controlled execution.';
comment on column media_center.content_assets.legacy_source_id is
  'Controlled legacy source id for idempotent asset migration.';

commit;

select
  'media_assets_contract_extension' as section,
  column_name,
  true as present
from information_schema.columns
where table_schema='media_center'
  and table_name='content_assets'
  and column_name in ('legacy_source','legacy_source_id','content_key','unit_slug','source_public_table','published_at')
order by column_name;
