-- PalWakf - Storage bucket + RLS policies for Media Gallery uploads
-- Bucket id used in Flutter admin UI: 'media-gallery'
--
-- Requires RBAC helper functions already in the project:
--   public.is_superuser()
--   public.has_permission(system_key, permission_key)

-- 1) Ensure bucket exists and is public (for getPublicUrl)
insert into storage.buckets (id, name, public)
values ('media-gallery', 'media-gallery', true)
on conflict (id) do update
  set public = true;

-- 2) RLS policies on storage.objects
-- NOTE: You can apply these policies safely multiple times by dropping if exists.

drop policy if exists "Public read media-gallery" on storage.objects;
drop policy if exists "Admin insert media-gallery" on storage.objects;
drop policy if exists "Admin update media-gallery" on storage.objects;
drop policy if exists "Admin delete media-gallery" on storage.objects;

create policy "Public read media-gallery"
on storage.objects
for select
using (bucket_id = 'media-gallery');

create policy "Admin insert media-gallery"
on storage.objects
for insert
with check (
  bucket_id = 'media-gallery'
  and (
    public.is_superuser()
    or public.has_permission('platformAdmin', 'manageHome')
  )
);

create policy "Admin update media-gallery"
on storage.objects
for update
using (
  bucket_id = 'media-gallery'
  and (
    public.is_superuser()
    or public.has_permission('platformAdmin', 'manageHome')
  )
)
with check (
  bucket_id = 'media-gallery'
  and (
    public.is_superuser()
    or public.has_permission('platformAdmin', 'manageHome')
  )
);

create policy "Admin delete media-gallery"
on storage.objects
for delete
using (
  bucket_id = 'media-gallery'
  and (
    public.is_superuser()
    or public.has_permission('platformAdmin', 'manageHome')
  )
);
