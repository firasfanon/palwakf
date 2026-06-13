-- 02_APPLY_replace_waqf_asset_detail_rpc_qualified_postgis.sql
-- DDL target: waqf.rpc_waqf_asset_detail_v1(uuid) only.

begin;

CREATE OR REPLACE FUNCTION waqf.rpc_waqf_asset_detail_v1(p_waqf_asset_id uuid)
 RETURNS jsonb
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO 'waqf', 'public', 'auth'
AS $function$
declare
  v_asset jsonb;
  v_result jsonb;
begin
  if not waqf.has_waqf_asset_read_access_v1(p_waqf_asset_id) then
    raise exception 'WAQF_ASSETS_RBAC_DENIED: read access denied for asset %', p_waqf_asset_id
      using errcode = '42501';
  end if;

  select to_jsonb(x) into v_asset
  from (
    select
      a.*,
      coalesce(nullif(a.asset_name_ar, ''), nullif(a.generated_asset_name, ''), nullif(a.asset_short_name, ''), a.national_asset_code) as display_name_ar
    from waqf.waqf_assets a
    where a.id = p_waqf_asset_id
      and a.is_deleted = false
  ) x;

  if v_asset is null then
    raise exception 'WAQF_ASSETS_NOT_FOUND: asset % not found', p_waqf_asset_id
      using errcode = 'P0002';
  end if;

  select jsonb_build_object(
    'asset', v_asset,
    'geometries', coalesce((
      select jsonb_agg(jsonb_build_object(
        'id', g.id,
        'geometry_role', g.geometry_role,
        'geometry_type', g.geometry_type,
        'source_schema', g.source_schema,
        'source_table', g.source_table,
        'source_record_id', g.source_record_id,
        'source_layer_key', g.source_layer_key,
        'source_accuracy', g.source_accuracy,
        'is_primary', g.is_primary,
        'is_public', g.is_public,
        'is_approved', g.is_approved,
        'review_status', g.review_status,
        'geom_geojson', extensions.st_asgeojson(g.geom)::jsonb,
        'centroid_geojson', case when g.centroid is null then null else extensions.st_asgeojson(g.centroid)::jsonb end,
        'notes', g.notes,
        'created_at', g.created_at,
        'updated_at', g.updated_at
      ) order by g.is_primary desc, g.created_at desc)
      from waqf.waqf_asset_geometries g
      where g.waqf_asset_id = p_waqf_asset_id
    ), '[]'::jsonb),
    'parcel_links', coalesce((
      select jsonb_agg(to_jsonb(l) order by l.is_primary desc, l.created_at desc)
      from waqf.waqf_asset_parcel_links l
      where l.waqf_asset_id = p_waqf_asset_id
    ), '[]'::jsonb),
    'documents', coalesce((
      select jsonb_agg(jsonb_build_object(
        'id', d.id,
        'document_type', d.document_type,
        'document_title', d.document_title,
        'document_no', d.document_no,
        'document_date', d.document_date,
        'book_no', d.book_no,
        'book_page', d.book_page,
        'court_name', d.court_name,
        'issuer', d.issuer,
        'file_path', d.file_path,
        'storage_bucket', d.storage_bucket,
        'summary', d.summary,
        'is_verified', d.is_verified,
        'verified_at', d.verified_at,
        'notes', d.notes,
        'created_at', d.created_at
      ) order by d.created_at desc)
      from waqf.waqf_asset_documents d
      where d.waqf_asset_id = p_waqf_asset_id
    ), '[]'::jsonb),
    'duplicate_candidates', coalesce((
      select jsonb_agg(to_jsonb(dc) order by dc.match_score desc nulls last, dc.created_at desc)
      from waqf.waqf_asset_duplicate_candidates dc
      where dc.possible_waqf_asset_id = p_waqf_asset_id
    ), '[]'::jsonb),
    'notes', coalesce((
      select jsonb_agg(to_jsonb(n) order by n.created_at desc)
      from waqf.waqf_asset_notes n
      where n.waqf_asset_id = p_waqf_asset_id
    ), '[]'::jsonb),
    'field_visits', coalesce((
      select jsonb_agg(to_jsonb(v) order by v.created_at desc)
      from waqf.waqf_asset_field_visits v
      where v.waqf_asset_id = p_waqf_asset_id
    ), '[]'::jsonb),
    'review_events', coalesce((
      select jsonb_agg(to_jsonb(e) order by e.created_at desc)
      from waqf.waqf_asset_review_events e
      where e.waqf_asset_id = p_waqf_asset_id
    ), '[]'::jsonb),
    'status_history', coalesce((
      select jsonb_agg(to_jsonb(h) order by h.changed_at desc)
      from waqf.waqf_asset_status_history h
      where h.waqf_asset_id = p_waqf_asset_id
    ), '[]'::jsonb)
  ) into v_result;

  return v_result;
end;
$function$;

commit;

select
  'awqaf_asset_detail_postgis_geojson_qualification_applied' as section,
  true as function_replaced,
  false as dml_executed,
  false as rbac_changed,
  false as waqf_assets_mutated,
  false as production_approved;
