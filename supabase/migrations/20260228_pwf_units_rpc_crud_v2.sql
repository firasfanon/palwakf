-- PalWakf Patch (V2): Admin CRUD RPCs for core.org_units + core.org_unit_profiles
-- Fixes: OrgUnitsRepository methods missing + Admin org units management CRUD
-- Notes:
-- - Uses SECURITY DEFINER.
-- - Enforces superuser via public.admin_users (id = auth.uid()).

-- =========================
-- 0) Guard: require superuser
-- =========================
create or replace function public.pwf_require_superuser()
returns void
language plpgsql
security definer
as $$
begin
  if auth.uid() is null then
    raise exception 'Not authenticated';
  end if;

  if not exists (
    select 1
    from public.admin_users au
    where au.id = auth.uid()
      and coalesce(au.is_active, true) = true
      and coalesce(au.is_superuser, false) = true
  ) then
    raise exception 'Not authorized';
  end if;
end;
$$;

grant execute on function public.pwf_require_superuser() to authenticated;

-- =========================
-- 1) Create unit + profile
-- =========================
create or replace function public.pwf_admin_create_unit_with_profile(
  p_unit jsonb,
  p_profile jsonb default '{}'::jsonb
)
returns uuid
language plpgsql
security definer
as $$
declare
  v_unit_id uuid;
  v_site_title text;
  v_site_subtitle text;
  v_logo_url text;
  v_favicon_url text;
begin
  perform public.pwf_require_superuser();

  insert into core.org_units (
    unit_type,
    parent_id,
    governorate_id,
    code,
    slug,
    name_ar,
    name_en,
    is_active,
    sort_order
  )
  values (
    nullif(p_unit->>'unit_type',''),
    nullif(p_unit->>'parent_id','')::uuid,
    nullif(p_unit->>'governorate_id','')::uuid,
    nullif(p_unit->>'code',''),
    lower(nullif(p_unit->>'slug','')),
    nullif(p_unit->>'name_ar',''),
    nullif(p_unit->>'name_en',''),
    coalesce((p_unit->>'is_active')::boolean, true),
    coalesce((p_unit->>'sort_order')::integer, 0)
  )
  returning id into v_unit_id;

  -- Profile defaults (avoid NOT NULL surprises)
  v_site_title := coalesce(nullif(p_profile->>'site_title',''), nullif(p_unit->>'name_ar',''), 'المنصة العامة');
  v_site_subtitle := coalesce(nullif(p_profile->>'site_subtitle',''), 'وزارة الأوقاف والشؤون الدينية - فلسطين');
  v_logo_url := coalesce(nullif(p_profile->>'logo_url',''), 'https://via.placeholder.com/150');
  v_favicon_url := coalesce(nullif(p_profile->>'favicon_url',''), 'https://via.placeholder.com/32');

  insert into core.org_unit_profiles (
    unit_id,
    logo_url,
    favicon_url,
    cover_url,
    site_title,
    site_subtitle,
    contact_email,
    contact_phone,
    contact_address,
    facebook_url,
    x_url,
    instagram_url,
    youtube_url,
    whatsapp_url,
    updated_at
  )
  values (
    v_unit_id,
    v_logo_url,
    v_favicon_url,
    nullif(p_profile->>'cover_url',''),
    v_site_title,
    v_site_subtitle,
    nullif(p_profile->>'contact_email',''),
    nullif(p_profile->>'contact_phone',''),
    nullif(p_profile->>'contact_address',''),
    nullif(p_profile->>'facebook_url',''),
    nullif(p_profile->>'x_url',''),
    nullif(p_profile->>'instagram_url',''),
    nullif(p_profile->>'youtube_url',''),
    nullif(p_profile->>'whatsapp_url',''),
    now()
  )
  on conflict (unit_id)
  do update set
    logo_url = excluded.logo_url,
    favicon_url = excluded.favicon_url,
    cover_url = excluded.cover_url,
    site_title = excluded.site_title,
    site_subtitle = excluded.site_subtitle,
    contact_email = excluded.contact_email,
    contact_phone = excluded.contact_phone,
    contact_address = excluded.contact_address,
    facebook_url = excluded.facebook_url,
    x_url = excluded.x_url,
    instagram_url = excluded.instagram_url,
    youtube_url = excluded.youtube_url,
    whatsapp_url = excluded.whatsapp_url,
    updated_at = now();

  return v_unit_id;
end;
$$;

grant execute on function public.pwf_admin_create_unit_with_profile(jsonb, jsonb) to authenticated;

-- =========================
-- 2) Update unit + profile
-- =========================
create or replace function public.pwf_admin_update_unit_with_profile(
  p_unit_id uuid,
  p_unit_patch jsonb,
  p_profile_patch jsonb default '{}'::jsonb
)
returns void
language plpgsql
security definer
as $$
declare
  v_site_title text;
  v_site_subtitle text;
  v_logo_url text;
  v_favicon_url text;
begin
  perform public.pwf_require_superuser();

  update core.org_units u
  set
    unit_type = coalesce(nullif(p_unit_patch->>'unit_type',''), u.unit_type::text),
    parent_id = coalesce(nullif(p_unit_patch->>'parent_id','')::uuid, u.parent_id),
    governorate_id = coalesce(nullif(p_unit_patch->>'governorate_id','')::uuid, u.governorate_id),
    code = coalesce(nullif(p_unit_patch->>'code',''), u.code),
    slug = coalesce(lower(nullif(p_unit_patch->>'slug','')), u.slug),
    name_ar = coalesce(nullif(p_unit_patch->>'name_ar',''), u.name_ar),
    name_en = coalesce(nullif(p_unit_patch->>'name_en',''), u.name_en),
    is_active = coalesce((p_unit_patch->>'is_active')::boolean, u.is_active),
    sort_order = coalesce((p_unit_patch->>'sort_order')::integer, u.sort_order),
    updated_at = now()
  where u.id = p_unit_id;

  -- Profile defaults
  v_site_title := coalesce(nullif(p_profile_patch->>'site_title',''), nullif(p_unit_patch->>'name_ar',''));
  v_site_subtitle := nullif(p_profile_patch->>'site_subtitle','');
  v_logo_url := nullif(p_profile_patch->>'logo_url','');
  v_favicon_url := nullif(p_profile_patch->>'favicon_url','');

  insert into core.org_unit_profiles (
    unit_id,
    logo_url,
    favicon_url,
    cover_url,
    site_title,
    site_subtitle,
    contact_email,
    contact_phone,
    contact_address,
    facebook_url,
    x_url,
    instagram_url,
    youtube_url,
    whatsapp_url,
    updated_at
  )
  values (
    p_unit_id,
    coalesce(v_logo_url, 'https://via.placeholder.com/150'),
    coalesce(v_favicon_url, 'https://via.placeholder.com/32'),
    nullif(p_profile_patch->>'cover_url',''),
    coalesce(v_site_title, 'المنصة العامة'),
    coalesce(v_site_subtitle, 'وزارة الأوقاف والشؤون الدينية - فلسطين'),
    nullif(p_profile_patch->>'contact_email',''),
    nullif(p_profile_patch->>'contact_phone',''),
    nullif(p_profile_patch->>'contact_address',''),
    nullif(p_profile_patch->>'facebook_url',''),
    nullif(p_profile_patch->>'x_url',''),
    nullif(p_profile_patch->>'instagram_url',''),
    nullif(p_profile_patch->>'youtube_url',''),
    nullif(p_profile_patch->>'whatsapp_url',''),
    now()
  )
  on conflict (unit_id)
  do update set
    logo_url = coalesce(excluded.logo_url, core.org_unit_profiles.logo_url),
    favicon_url = coalesce(excluded.favicon_url, core.org_unit_profiles.favicon_url),
    cover_url = coalesce(excluded.cover_url, core.org_unit_profiles.cover_url),
    site_title = coalesce(excluded.site_title, core.org_unit_profiles.site_title),
    site_subtitle = coalesce(excluded.site_subtitle, core.org_unit_profiles.site_subtitle),
    contact_email = excluded.contact_email,
    contact_phone = excluded.contact_phone,
    contact_address = excluded.contact_address,
    facebook_url = excluded.facebook_url,
    x_url = excluded.x_url,
    instagram_url = excluded.instagram_url,
    youtube_url = excluded.youtube_url,
    whatsapp_url = excluded.whatsapp_url,
    updated_at = now();
end;
$$;

grant execute on function public.pwf_admin_update_unit_with_profile(uuid, jsonb, jsonb) to authenticated;

-- =========================
-- 3) Delete unit
-- =========================
create or replace function public.pwf_admin_delete_unit(p_unit_id uuid)
returns void
language plpgsql
security definer
as $$
begin
  perform public.pwf_require_superuser();

  -- delete profile first (safe even if ON DELETE CASCADE exists)
  delete from core.org_unit_profiles where unit_id = p_unit_id;
  delete from core.org_units where id = p_unit_id;
end;
$$;

grant execute on function public.pwf_admin_delete_unit(uuid) to authenticated;
