# PalWakf Baseline Operations & Cleanup Summary — 2026-06-10

## 1. مصدر المراجعة

- Baseline reviewed: `palwakf.zip`
- Original file count: `5,681`
- Original uncompressed size: `120.60 MB`
- Original compressed size in ZIP entries: `99.99 MB`

## 2. أين كان التضخم؟

أكبر مصادر الحجم داخل baseline:

| Directory | Files | Uncompressed size |
|---|---:|---:|
| `evidence` | 474 | 91.86 MB |
| `lib` | 751 | 6.73 MB |
| `assets` | 61 | 5.12 MB |
| `SERVICE_CENTER_BROWSER_UAT_ROUTE_ALIAS_HERO_SWITCHER_HOTFIX_2026_05_31` | 15 | 3.26 MB |
| `docs` | 1,078 | 2.85 MB |
| `sql_sandbox` | 770 | 2.25 MB |
| `(root)` | 1,224 | 1.98 MB |
| `baseline_control` | 289 | 0.99 MB |
| `service_center_public_request_alias_retest_intake` | 9 | 0.86 MB |
| `service_center_admin_transition_evidence_closure` | 10 | 0.71 MB |
| `android` | 41 | 0.50 MB |
| `presentation` | 64 | 0.44 MB |

الاستنتاج العملي:
- التضخم الأساسي من `evidence/`، وخاصة صور Browser/UAT القديمة.
- يوجد تراكم كبير لملفات `BASELINE_CHANGELOG_*`, `SESSION_HANDOFF_*`, `UAT_*`, `ARTIFACT_MANIFEST_*` في الجذر.
- الكود الفعلي في `lib/` ليس سبب التضخم الرئيسي.
- ملفات SQL ليست ضخمة مقارنة بالـ evidence، لذلك أبقيتها في النسخة النظيفة.

## 3. ملخص العمليات والإجراءات المستفادة من baseline

### أ. Platform Governance / Governing Contract
- تثبيت المنصة كطبقة سيادية تدير الأنظمة، العقود، الصلاحيات، وواجهات القراءة.
- فصل المسؤوليات بين المنصة والأنظمة المتخصصة.
- اعتماد `public` كطبقة compatibility/wrappers وليس كمصدر سيادي.

### ب. Public Schema / Ownership Migration
- تنفيذ مسار طويل لجرد جداول `public`.
- نقل/تصنيف الملكية نحو schemas مالكة مثل `core`, `gis`, `platform_services`, `media_center`.
- منع drop/archive/rename إلا بعد dependency-zero وowner approval.

### ج. Platform 11K / Core-GIS Locations
- إسقاط `public.locations` بعد تحقق dependency safety.
- حفظ `gis.locations` كمصدر GIS runtime.
- إنشاء/اعتماد `core.core_locations` كمرجع سيادي للمواقع.
- اعتماد `core.core_lgus` كهيئة محلية/parent.
- R2 bridge coverage: `666/666`.
- `core_locations_total = 351`.
- `review_backlog = 366`.
- القرار الحاكم: Platform تجهز backend contract فقط، وAwqaf System يبني النماذج والشاشات التشغيلية.

### د. Public Runtime / Media / Services
- وجود أدلة لمسارات media/services/root cutover وruntime source certification.
- كثير من أدلة الصور والـ UAT القديمة أصبحت تاريخية ويمكن حفظها خارج baseline التشغيلي.

### هـ. Access / RBAC / Auth Recovery
- وجود مسارات متعددة لتثبيت access gateway، password recovery، ودلالات role/unit/superuser.
- هذه الملفات أصبحت سجلات تاريخية، بينما الكود والتكوينات هي التي يجب أن تبقى في baseline النظيف.

### و. Service Center / Other Operational Evidence
- توجد حزم أدلة كاملة للـ Service Center.
- الأدلة المصورة والحزم القديمة لا يجب أن تبقى داخل baseline التشغيلي، بل في أرشيف خارجي عند الحاجة.

## 4. سياسة التنظيف المطبقة

### تم الاحتفاظ بـ
- كود Flutter: `lib/`, `presentation/`, `data/`, `domain/`
- Assets باستثناء ملفات الخطوط
- إعدادات المشروع: `pubspec.yaml`, `analysis_options.yaml`, `l10n.yaml`, إلخ
- منصات البناء: `android/`, `ios/`, `web/`, `macos/`, `linux/`, `windows/`
- `supabase/`
- `scripts/`, `tools/`
- `sql_apply/`, `sql_sandbox/`, `sql_next/`
- `governance/`
- README / Latest pointer / guide الرئيسي

### تم عزلها من النسخة النظيفة
- `evidence/` بالكامل
- صور UAT القديمة
- ملفات handoff/changelog/UAT/manifest المتراكمة
- مجلدات evidence الخاصة بـ Service Center
- `.idea/`
- source overlays/patch history القديمة
- docs التاريخية التي تم استبدالها بهذا الملخص

### تم استبعادها من الحزمة المشتركة
- ملفات الخطوط: `.ttf`, `.otf`, `.woff`, `.woff2`

> ملاحظة: ملفات الخطوط لم تُدرج في الحزمة النظيفة. أبقها في مستودعك المحلي/مصدرها الأصلي عند التشغيل إن كان المشروع يحتاجها.

## 5. أرقام التنظيف

- Files kept in clean baseline: `2,016`
- Files quarantined from clean baseline: `3,648`
- Font files excluded: `17`
- Kept uncompressed size: `13.29 MB`
- Quarantined uncompressed size: `104.28 MB`
- Excluded font size: `3.03 MB`

## 6. طريقة الاعتماد المقترحة

1. استخدم cleaned baseline كنسخة تشغيلية أخف.
2. احتفظ بـ `palwakf.zip` الأصلي كأرشيف تاريخي فقط.
3. لا تُرجع `evidence/` إلى baseline التشغيلي.
4. أي evidence جديدة تحفظ في أرشيف خارجي أو حزمة evidence منفصلة.
5. أي نظام متخصص مثل `awqaf_system` يستلم handoff/prompt لا كود داخل مسار المنصة.
