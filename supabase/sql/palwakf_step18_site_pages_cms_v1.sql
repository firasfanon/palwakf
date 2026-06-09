-- PalWakf - Step 18: Simple CMS Pages (site_pages)
--
-- هدف: ربط الصفحات الثابتة (عن الوزارة/كلمة الوزير/الرؤية/الهيكل/الخدمات/اتصل بنا...
-- ) بجدول واحد عام مع RLS، مع دعم صفحات عامة (unit_id = NULL) وصفحات خاصة بوحدة (unit_id).

-- 1) Table: site_pages
CREATE TABLE IF NOT EXISTS public.site_pages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  unit_id uuid NULL REFERENCES public.org_units(id) ON DELETE CASCADE,
  slug text NOT NULL,
  title_ar text NOT NULL DEFAULT '',
  title_en text NOT NULL DEFAULT '',
  subtitle_ar text NOT NULL DEFAULT '',
  subtitle_en text NOT NULL DEFAULT '',
  body_ar text NOT NULL DEFAULT '',
  body_en text NOT NULL DEFAULT '',
  is_published boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Uniqueness
--  - per unit: (unit_id, slug)
--  - global pages: unique slug where unit_id is null
CREATE UNIQUE INDEX IF NOT EXISTS ux_site_pages_unit_slug ON public.site_pages(unit_id, slug);
CREATE UNIQUE INDEX IF NOT EXISTS ux_site_pages_global_slug ON public.site_pages(slug) WHERE unit_id IS NULL;

CREATE INDEX IF NOT EXISTS idx_site_pages_slug ON public.site_pages(slug);
CREATE INDEX IF NOT EXISTS idx_site_pages_unit_id ON public.site_pages(unit_id);
CREATE INDEX IF NOT EXISTS idx_site_pages_published ON public.site_pages(is_published);

-- updated_at trigger
DROP TRIGGER IF EXISTS trg_site_pages_updated_at ON public.site_pages;
CREATE TRIGGER trg_site_pages_updated_at
BEFORE UPDATE ON public.site_pages
FOR EACH ROW EXECUTE FUNCTION public.tg_set_updated_at();

-- 2) RLS
ALTER TABLE public.site_pages ENABLE ROW LEVEL SECURITY;

-- Public read for published pages, admin read for all
DROP POLICY IF EXISTS site_pages_public_read ON public.site_pages;
CREATE POLICY site_pages_public_read
ON public.site_pages
FOR SELECT
USING (
  is_published = true
  OR public.is_superuser()
  OR public.has_permission('platformAdmin', 'manageSite')
);

-- Admin write
DROP POLICY IF EXISTS site_pages_admin_write ON public.site_pages;
CREATE POLICY site_pages_admin_write
ON public.site_pages
FOR ALL
USING (
  public.is_superuser()
  OR public.has_permission('platformAdmin', 'manageSite')
)
WITH CHECK (
  public.is_superuser()
  OR public.has_permission('platformAdmin', 'manageSite')
);

-- 3) Seed examples (optional) - uncomment to test
-- INSERT INTO public.site_pages (unit_id, slug, title_ar, title_en, subtitle_ar, subtitle_en, body_ar, body_en)
-- VALUES
-- (NULL, 'about', 'عن الوزارة', 'About', '', '', '## نبذة\nنص...', '## Overview\nText...');
