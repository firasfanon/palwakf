-- PalWakf (Sovereign) — Step 2 Patch
-- Mustakshif: Controlled GPKG import helpers + id=0 strategy + official views (gis/hist/waqf)
-- Version: contracts v0.1.0 compatible
-- Safe to re-run (idempotent). Designed to NOT break existing tables.
-- Apply in Supabase SQL Editor or migrations (recommended: a single migration file).

begin;

-- 0) Prereqs
create extension if not exists postgis;

-- 1) Staging schemas for imports (ogr2ogr should import into import_raw.*)
create schema if not exists import_raw;
create schema if not exists import_utils;

-- -----------------------------------------------------------------------------
-- 2) Small helpers (introspection / picking columns safely)
-- -----------------------------------------------------------------------------

create or replace function import_utils.col_exists(p_schema text, p_table text, p_col text)
returns boolean
language sql
stable
as $$
  select exists (
    select 1
    from information_schema.columns
    where table_schema = p_schema
      and table_name   = p_table
      and column_name  = p_col
  );
$$;

create or replace function import_utils.pick_col_cast(
  p_schema text,
  p_table text,
  p_candidates text[],
  p_cast text,
  p_alias text
) returns text
language plpgsql
stable
as $$
declare
  c text;
begin
  foreach c in array p_candidates loop
    if import_utils.col_exists(p_schema, p_table, c) then
      if p_cast is null or btrim(p_cast) = '' then
        return format('%I as %I', c, p_alias);
      else
        return format('%I::%s as %I', c, p_cast, p_alias);
      end if;
    end if;
  end loop;

  if p_cast is null or btrim(p_cast) = '' then
    return format('NULL as %I', p_alias);
  end if;

  return format('NULL::%s as %I', p_cast, p_alias);
end;
$$;

create or replace function import_utils.pick_geom_col(
  p_schema text,
  p_table text
) returns text
language plpgsql
stable
as $$
begin
  if import_utils.col_exists(p_schema, p_table, 'geom') then
    return 'geom';
  end if;

  if import_utils.col_exists(p_schema, p_table, 'wkb_geometry') then
    return 'wkb_geometry';
  end if;

  return null;
end;
$$;

-- -----------------------------------------------------------------------------
-- 3) Normalization helpers for imported layers
--    Contracted import recommendation (outside SQL):
--      ogr2ogr ... -lco GEOMETRY_NAME=geom -lco FID=ogc_fid -lco LAUNDER=NO
--    Then promote with import_utils.promote_layer(...)
-- -----------------------------------------------------------------------------

create or replace function import_utils.ensure_geom_column(
  p_schema text,
  p_table text,
  p_geom_col text default 'geom'
) returns void
language plpgsql
as $$
declare
  tbl regclass;
  has_geom boolean;
  has_wkb boolean;
begin
  tbl := to_regclass(format('%I.%I', p_schema, p_table));
  if tbl is null then
    raise exception 'Table %.% not found', p_schema, p_table;
  end if;

  select import_utils.col_exists(p_schema, p_table, p_geom_col) into has_geom;
  if has_geom then
    return;
  end if;

  select import_utils.col_exists(p_schema, p_table, 'wkb_geometry') into has_wkb;
  if has_wkb then
    execute format('alter table %s rename column wkb_geometry to %I', tbl, p_geom_col);
    return;
  end if;

  raise exception 'No geometry column found. Expected "%" or "wkb_geometry" in %.%',
    p_geom_col, p_schema, p_table;
end;
$$;

create or replace function import_utils.rename_src_id(
  p_schema text,
  p_table text,
  p_src_id_col text default 'id'
) returns void
language plpgsql
as $$
declare
  tbl regclass;
begin
  tbl := to_regclass(format('%I.%I', p_schema, p_table));
  if tbl is null then
    raise exception 'Table %.% not found', p_schema, p_table;
  end if;

  -- If already src_id, do nothing
  if import_utils.col_exists(p_schema, p_table, 'src_id') then
    return;
  end if;

  -- If src id column exists (often "id"), rename it to src_id
  if import_utils.col_exists(p_schema, p_table, p_src_id_col) then
    execute format('alter table %s rename column %I to src_id', tbl, p_src_id_col);
    return;
  end if;

  -- Otherwise add nullable src_id
  execute format('alter table %s add column src_id text', tbl);
end;
$$;

create or replace function import_utils.ensure_gid_pk(
  p_schema text,
  p_table text,
  p_allow_drop_pk boolean default true,
  p_gid_col text default 'gid'
) returns void
language plpgsql
as $$
declare
  tbl regclass;
  seq_name text;
  pk_name text;
  pk_cols text[];
begin
  tbl := to_regclass(format('%I.%I', p_schema, p_table));
  if tbl is null then
    raise exception 'Table %.% not found', p_schema, p_table;
  end if;

  -- add gid if not exists
  if not import_utils.col_exists(p_schema, p_table, p_gid_col) then
    execute format('alter table %s add column %I bigint', tbl, p_gid_col);

    -- create sequence + default (bigserial-like, but explicit/idempotent)
    seq_name := format('%I.%I_%I_seq', p_schema, p_table, p_gid_col);
    execute format('create sequence if not exists %s', seq_name);
    execute format('alter table %s alter column %I set default nextval(%L)', tbl, p_gid_col, seq_name);
  else
    -- ensure there is a usable sequence default
    select pg_get_serial_sequence(format('%I.%I', p_schema, p_table), p_gid_col) into seq_name;
    if seq_name is null then
      seq_name := format('%I.%I_%I_seq', p_schema, p_table, p_gid_col);
      execute format('create sequence if not exists %s', seq_name);
      execute format('alter table %s alter column %I set default nextval(%L)', tbl, p_gid_col, seq_name);
    end if;
  end if;

  -- fill existing null gids
  execute format('update %s set %I = nextval(%L) where %I is null', tbl, p_gid_col, seq_name, p_gid_col);
  execute format('alter table %s alter column %I set not null', tbl, p_gid_col);

  -- find existing PK (if any)
  select c.conname,
         array_agg(a.attname order by a.attnum)
  into pk_name, pk_cols
  from pg_constraint c
  join pg_class t on t.oid = c.conrelid
  join pg_namespace n on n.oid = t.relnamespace
  join unnest(c.conkey) k(attnum) on true
  join pg_attribute a on a.attrelid = t.oid and a.attnum = k.attnum
  where c.contype = 'p'
    and t.oid = tbl
  group by c.conname
  limit 1;

  if pk_name is not null then
    -- if pk is already on gid, keep it
    if array_length(pk_cols,1) = 1 and pk_cols[1] = p_gid_col then
      return;
    end if;

    if p_allow_drop_pk then
      execute format('alter table %s drop constraint %I', tbl, pk_name);
    else
      raise exception 'Table %.% already has a primary key (%) not on "%". Refusing to modify.',
        p_schema, p_table, pk_name, p_gid_col;
    end if;
  end if;

  -- set PK on gid
  execute format('alter table %s add constraint %I primary key (%I)',
    tbl,
    format('%s_pkey', p_table),
    p_gid_col
  );
end;
$$;

create or replace function import_utils.enforce_geom(
  p_schema text,
  p_table text,
  p_geom_type text,              -- e.g. 'MULTIPOINT' or 'MULTIPOLYGON'
  p_srid int default 4326,
  p_geom_col text default 'geom'
) returns void
language plpgsql
as $$
declare
  tbl regclass;
  wants_multi boolean;
  type_sql text;
begin
  tbl := to_regclass(format('%I.%I', p_schema, p_table));
  if tbl is null then
    raise exception 'Table %.% not found', p_schema, p_table;
  end if;

  perform import_utils.ensure_geom_column(p_schema, p_table, p_geom_col);

  wants_multi := (upper(p_geom_type) like 'MULTI%');

  -- SRID normalization: set SRID when 0, transform otherwise
  execute format(
    'update %s set %I = st_setsrid(%I, %s) where st_srid(%I) = 0',
    tbl, p_geom_col, p_geom_col, p_srid, p_geom_col
  );

  execute format(
    'update %s set %I = st_transform(%I, %s) where st_srid(%I) <> %s and st_srid(%I) <> 0',
    tbl, p_geom_col, p_geom_col, p_srid, p_geom_col, p_srid, p_geom_col
  );

  -- Multi normalization (if requested)
  if wants_multi then
    execute format(
      'update %s set %I = st_multi(%I) where %I is not null and geometrytype(%I) not like %L',
      tbl, p_geom_col, p_geom_col, p_geom_col, p_geom_col, 'MULTI%'
    );
  end if;

  -- Force2D + cast to expected geometry type
  type_sql := format('geometry(%s,%s)', upper(p_geom_type), p_srid);

  execute format(
    'alter table %s alter column %I type %s using st_force2d(%I)',
    tbl, p_geom_col, type_sql, p_geom_col
  );

  -- Spatial index
  execute format('create index if not exists %I on %s using gist (%I)',
    format('%s_%s_gix', p_table, p_geom_col),
    tbl,
    p_geom_col
  );
end;
$$;

-- Promote: normalize a staging layer then move it safely to target schema/table (no overwrites)
create or replace function import_utils.promote_layer(
  p_staging_schema text,
  p_staging_table text,
  p_target_schema text,
  p_target_table text,
  p_geom_type text,                -- 'MULTIPOINT' / 'MULTIPOLYGON'
  p_srid int default 4326,
  p_src_id_col text default 'id',
  p_geom_col text default 'geom'
) returns void
language plpgsql
as $$
declare
  src regclass;
  dst regclass;
begin
  src := to_regclass(format('%I.%I', p_staging_schema, p_staging_table));
  if src is null then
    raise exception 'Staging table %.% not found', p_staging_schema, p_staging_table;
  end if;

  -- Ensure target schema
  execute format('create schema if not exists %I', p_target_schema);

  dst := to_regclass(format('%I.%I', p_target_schema, p_target_table));
  if dst is not null then
    raise exception 'Target table %.% already exists. Refusing to overwrite.', p_target_schema, p_target_table;
  end if;

  -- Normalize in-place
  perform import_utils.ensure_geom_column(p_staging_schema, p_staging_table, p_geom_col);
  perform import_utils.rename_src_id(p_staging_schema, p_staging_table, p_src_id_col);
  perform import_utils.ensure_gid_pk(p_staging_schema, p_staging_table, true, 'gid');
  perform import_utils.enforce_geom(p_staging_schema, p_staging_table, p_geom_type, p_srid, p_geom_col);

  -- Move to target schema/table
  execute format('alter table %I.%I set schema %I', p_staging_schema, p_staging_table, p_target_schema);

  if p_staging_table <> p_target_table then
    execute format('alter table %I.%I rename to %I', p_target_schema, p_staging_table, p_target_table);
  end if;

  -- Optional indexes when columns exist
  if import_utils.col_exists(p_target_schema, p_target_table, 'gov_code') then
    execute format('create index if not exists %I on %I.%I (gov_code)',
      format('%s_gov_code_ix', p_target_table), p_target_schema, p_target_table
    );
  end if;

  if import_utils.col_exists(p_target_schema, p_target_table, 'lgu_code') then
    execute format('create index if not exists %I on %I.%I (lgu_code)',
      format('%s_lgu_code_ix', p_target_table), p_target_schema, p_target_table
    );
  end if;

  if import_utils.col_exists(p_target_schema, p_target_table, 'community_code') then
    execute format('create index if not exists %I on %I.%I (community_code)',
      format('%s_community_code_ix', p_target_table), p_target_schema, p_target_table
    );
  end if;
end;
$$;

-- -----------------------------------------------------------------------------
-- 4) Official Views (safe + conditional)
--    We create views only when required base tables exist.
-- -----------------------------------------------------------------------------

-- GIS views (prefer core_* as sovereign truth; geometry comes from core if present)
do $$
begin
  if to_regclass('core.core_governorates') is not null then
    execute $$
      create or replace view gis.v_admin_governorates as
      select
        gov_code,
        name_ar,
        name_en,
        geom
      from core.core_governorates;
    $$;
  end if;

  if to_regclass('core.core_communities') is not null then
    execute $$
      create or replace view gis.v_admin_communities as
      select
        community_code,
        gov_code,
        lgu_code,
        name_ar,
        name_en,
        geom
      from core.core_communities;
    $$;
  end if;

  if to_regclass('core.core_lgus') is not null then
    execute $$
      create or replace view gis.v_admin_lgus as
      select
        lgu_code,
        gov_code,
        name_ar,
        name_en,
        geom
      from core.core_lgus;
    $$;
  end if;

  -- unified search view (optional)
  if to_regclass('core.core_governorates') is not null
     and to_regclass('core.core_communities') is not null
     and to_regclass('core.core_lgus') is not null then
    execute $$
      create or replace view gis.v_search_admin_units as
      select 'GOV'::text as level, gov_code as code, null::text as parent_code, name_ar, name_en, geom
      from core.core_governorates
      union all
      select 'LGU'::text as level, lgu_code as code, gov_code as parent_code, name_ar, name_en, geom
      from core.core_lgus
      union all
      select 'COM'::text as level, community_code as code, lgu_code as parent_code, name_ar, name_en, geom
      from core.core_communities;
    $$;
  end if;
end $$;

-- HIST views (only if base tables exist; adapt column names safely)
do $$
declare
  sql text;
begin
  if to_regclass('hist.historical_periods') is not null then
    sql := 'create or replace view hist.v_periods as select '
      || import_utils.pick_col_cast('hist','historical_periods', array['id','period_id','gid'], 'text', 'id') || ', '
      || import_utils.pick_col_cast('hist','historical_periods', array['key','period_key','slug'], 'text', 'key') || ', '
      || import_utils.pick_col_cast('hist','historical_periods', array['name_ar','title_ar','name'], 'text', 'name_ar') || ', '
      || import_utils.pick_col_cast('hist','historical_periods', array['name_en','title_en'], 'text', 'name_en') || ', '
      || import_utils.pick_col_cast('hist','historical_periods', array['date_from','start_year','from_year'], 'int', 'date_from') || ', '
      || import_utils.pick_col_cast('hist','historical_periods', array['date_to','end_year','to_year'], 'int', 'date_to') || ', '
      || import_utils.pick_col_cast('hist','historical_periods', array['sort_order','order_index'], 'int', 'sort_order')
      || ' from hist.historical_periods;';
    execute sql;
  end if;

  if to_regclass('hist.historical_layers') is not null then
    sql := 'create or replace view hist.v_layers_index as select '
      || import_utils.pick_col_cast('hist','historical_layers', array['id','layer_id','gid'], 'text', 'id') || ', '
      || import_utils.pick_col_cast('hist','historical_layers', array['period_id','historical_period_id','period_key'], 'text', 'period_id') || ', '
      || import_utils.pick_col_cast('hist','historical_layers', array['key','layer_key','slug'], 'text', 'key') || ', '
      || import_utils.pick_col_cast('hist','historical_layers', array['name_ar','title_ar','name'], 'text', 'name_ar') || ', '
      || import_utils.pick_col_cast('hist','historical_layers', array['name_en','title_en'], 'text', 'name_en') || ', '
      || import_utils.pick_col_cast('hist','historical_layers', array['source','source_ref'], 'text', 'source')
      || ' from hist.historical_layers;';
    execute sql;
  end if;
end $$;

-- WAQF views (only if base tables exist; adapt column names safely)
do $$
declare
  t text;
  gcol text;
  sql text;
begin
  -- helper to create one view if the table exists
  foreach t in array array['mosques','maqamat','cemeteries','archaeological_sites'] loop
    if to_regclass(format('waqf.%s', t)) is not null then
      gcol := import_utils.pick_geom_col('waqf', t);
      if gcol is null then
        -- no geometry column, skip
        continue;
      end if;

      sql := format('create or replace view waqf.v_%s as select ', t)
        || import_utils.pick_col_cast('waqf', t, array['gid','id', t||'_id'], 'text', 'id') || ', '
        || import_utils.pick_col_cast('waqf', t, array['pwf_key','pwf','national_key'], 'text', 'pwf_key') || ', '
        || import_utils.pick_col_cast('waqf', t, array['name_ar','title_ar','name'], 'text', 'name_ar') || ', '
        || import_utils.pick_col_cast('waqf', t, array['name_en','title_en'], 'text', 'name_en') || ', '
        || import_utils.pick_col_cast('waqf', t, array['gov_code','governorate_code'], 'text', 'gov_code') || ', '
        || import_utils.pick_col_cast('waqf', t, array['lgu_code','lgu','lgu_code_ref'], 'text', 'lgu_code') || ', '
        || import_utils.pick_col_cast('waqf', t, array['community_code','community','com_code'], 'text', 'community_code') || ', '
        || format('%I as geom', gcol)
        || format(' from waqf.%I;', t);

      execute sql;
    end if;
  end loop;
end $$;

commit;

-- -----------------------------------------------------------------------------
-- Usage Notes (run outside SQL, then call promote_layer)
-- -----------------------------------------------------------------------------
-- 1) Import a layer into staging schema with correct geometry type:
--    Example (POINT/MULTIPOINT layer):
--      ogr2ogr -f "PostgreSQL" PG:"<SUPABASE_CONN>" "<file.gpkg>" "<layer_name>" \
--        -nln "import_raw.<layer_name>" -nlt MULTIPOINT \
--        -lco GEOMETRY_NAME=geom -lco FID=ogc_fid -lco LAUNDER=NO
--
--    Example (POLYGON/MULTIPOLYGON layer):
--      ogr2ogr ... -nln "import_raw.<layer_name>" -nlt MULTIPOLYGON -nlt PROMOTE_TO_MULTI ...
--
-- 2) Promote it safely to gis/waqf/hist:
--      select import_utils.promote_layer('import_raw','Natural_Blocks_Full','gis','natural_blocks','MULTIPOLYGON',4326,'id','geom');
--      select import_utils.promote_layer('import_raw','Some_Points_Layer','waqf','mosques','MULTIPOINT',4326,'id','geom');
--
-- 3) If a layer was imported with wrong geometry (e.g., MultiPoint as MultiPolygon):
--    Drop ONLY that staging table and re-import with correct -nlt, then promote again.
-- -----------------------------------------------------------------------------
