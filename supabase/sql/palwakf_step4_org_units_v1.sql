-- PalWakf - Step 4: Organization Units + Contact/Social Profiles
--
-- ملاحظة مهمّة:
-- Postgres (النسخ الشائعة في Supabase حتى الآن) لا يدعم
-- `CREATE POLICY IF NOT EXISTS`.
-- لذلك نستخدم: DROP POLICY IF EXISTS ... ثم CREATE POLICY.

-- 1) Enum: org_unit_type
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'org_unit_type') THEN
    CREATE TYPE public.org_unit_type AS ENUM (
      'ministry',
      'general_admin',
      'directorate',
      'school',
      'university',
      'institute',
      'orphanage',
      'zakat_committee',
      'mosque',
      'other'
    );
  END IF;
END $$;

-- 2) org_units
CREATE TABLE IF NOT EXISTS public.org_units (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  unit_type public.org_unit_type NOT NULL DEFAULT 'other',
  parent_id uuid NULL REFERENCES public.org_units(id) ON DELETE SET NULL,
  governorate_id uuid NULL,
  code text NOT NULL UNIQUE,
  slug text NOT NULL UNIQUE,
  name_ar text NOT NULL,
  name_en text NOT NULL DEFAULT '',
  is_active boolean NOT NULL DEFAULT true,
  sort_order int NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_org_units_parent_id ON public.org_units(parent_id);
CREATE INDEX IF NOT EXISTS idx_org_units_unit_type ON public.org_units(unit_type);

-- 3) org_unit_profiles (1:1)
CREATE TABLE IF NOT EXISTS public.org_unit_profiles (
  unit_id uuid PRIMARY KEY REFERENCES public.org_units(id) ON DELETE CASCADE,
  logo_url text NOT NULL DEFAULT '',
  favicon_url text NULL,
  cover_url text NULL,
  site_title text NOT NULL DEFAULT '',
  site_subtitle text NOT NULL DEFAULT '',
  contact_email text NULL,
  contact_phone text NULL,
  contact_address text NULL,
  facebook_url text NULL,
  x_url text NULL,
  instagram_url text NULL,
  youtube_url text NULL,
  whatsapp_url text NULL,
  map_lat double precision NULL,
  map_lng double precision NULL,
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- 4) updated_at trigger (مفيد للتتبع)
CREATE OR REPLACE FUNCTION public.tg_set_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END $$;

DROP TRIGGER IF EXISTS trg_org_units_updated_at ON public.org_units;
CREATE TRIGGER trg_org_units_updated_at
BEFORE UPDATE ON public.org_units
FOR EACH ROW EXECUTE FUNCTION public.tg_set_updated_at();

DROP TRIGGER IF EXISTS trg_org_unit_profiles_updated_at ON public.org_unit_profiles;
CREATE TRIGGER trg_org_unit_profiles_updated_at
BEFORE UPDATE ON public.org_unit_profiles
FOR EACH ROW EXECUTE FUNCTION public.tg_set_updated_at();

-- 5) RLS
ALTER TABLE public.org_units ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.org_unit_profiles ENABLE ROW LEVEL SECURITY;

-- 6) Policies (Public Read)
DROP POLICY IF EXISTS org_units_public_read ON public.org_units;
CREATE POLICY org_units_public_read
ON public.org_units
FOR SELECT
USING (is_active = true);

DROP POLICY IF EXISTS org_unit_profiles_public_read ON public.org_unit_profiles;
CREATE POLICY org_unit_profiles_public_read
ON public.org_unit_profiles
FOR SELECT
USING (true);

-- 7) Policies (Admin Write)
-- يعتمد على دوال RBAC الموجودة مسبقاً: public.is_superuser() و public.has_permission(system, permission)
DROP POLICY IF EXISTS org_units_admin_write ON public.org_units;
CREATE POLICY org_units_admin_write
ON public.org_units
FOR ALL
USING (
  public.is_superuser()
  OR public.has_permission('platformAdmin', 'manageSite')
)
WITH CHECK (
  public.is_superuser()
  OR public.has_permission('platformAdmin', 'manageSite')
);

DROP POLICY IF EXISTS org_unit_profiles_admin_write ON public.org_unit_profiles;
CREATE POLICY org_unit_profiles_admin_write
ON public.org_unit_profiles
FOR ALL
USING (
  public.is_superuser()
  OR public.has_permission('platformAdmin', 'manageSite')
)
WITH CHECK (
  public.is_superuser()
  OR public.has_permission('platformAdmin', 'manageSite')
);
