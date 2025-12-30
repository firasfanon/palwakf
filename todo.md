# PalWakf – TODO & مرجع سريع

هذا الملف مرجع حيّ للمشروع: ماذا تم إنجازه، ما الذي يعمل الآن، وما الذي يجب تنفيذه لاحقًا.

## 1) الهدف العام
منصة PalWakf منصة سيادية موحّدة (Flutter Web + Supabase + Riverpod) تشمل:
- موقع عام (Public) للأخبار والإعلانات والأنشطة وخطبة الجمعة…
- لوحات تحكم داخلية متعددة (Systems) تحت Shells منفصلة.
- قاعدة بيانات واحدة متكاملة بحيث أي إدخال يخدم أكثر من نظام.

## 2) المكدس التقني
- Flutter Web
- Supabase (Postgres + RLS)
- Riverpod (StateNotifier legacy عند الحاجة)
- GoRouter
- تصميم RTL + i18n (ar/en)

## 3) قواعد تصميم/هندسة (ثوابت)
- Feature-based: `features/*`
- Widgets قابلة لإعادة الاستخدام + OOP + DRY
- Enums واضحة: `SystemKey`, `PlatformRole`, `PermissionKey`
- CRUD عبر Repos/Services بوضوح

## 4) RBAC (قاعدة البيانات)
- مصدر الهوية الوحيد: `admin_users` مرتبط بـ `auth.users`.
- جداول RBAC الأساسية:
  - `platform_systems`
  - `platform_permissions`
  - `user_system_roles`
  - `user_system_permissions`
- RLS: القراءة للمستخدم نفسه (أو superuser)، والكتابة في إدارة الصلاحيات عبر:
  - `is_superuser = true` أو صلاحية `manageUsers` على `platformAdmin`.

## 5) التوجيه (Routing)
- نعتمد GoRouter.
- المسارات الأساسية:
  - `/` الرئيسية
  - `/news` الأخبار
  - `/announcements` الإعلانات
  - `/activities` الأنشطة
  - `/friday-sermon` خطبة الجمعة
  - `/minister` كلمة الوزير
  - `/structure` الهيكل التنظيمي
  - `/former-ministers` الوزراء السابقون
  - `/contact` تواصل
  - `/admin/*` لوحة التحكم

> ملاحظة: تجنب خلط Navigator 1.0 مع GoRouter في صفحات الويب.

## 6) توحيد قالب صفحات الموقع العام
اعتمدنا قالب Web موحّد (مستوحى من صفحة الأخبار):
- `WebAppBar` شريط تنقل علوي
- Header بتدرج لوني + عنوان
- محتوى داخل `WebContainer`
- `WebFooter`

الملف: `lib/presentation/widgets/web/web_public_page.dart`

## 7) ما تم ضبطه مؤخرًا
- إصلاح استقرار التنقل: CustomAppBar أصبح يستخدم GoRouter (context.pop / context.go) مع fallback إلى `/home` عند عدم وجود Back Stack.
- معالجة "الأحرف الغريبة" في الإعلانات الرسمية عبر normalizeRichText قبل العرض/البحث.
- إضافة مسار وصفحة مبدئية: `/social-services`.

### SQL جديد
- `supabase/sql/palwakf_step4_org_units_v1.sql`
  - org_units + org_unit_profiles + RLS
  - بدون `CREATE POLICY IF NOT EXISTS` (تم استخدام DROP POLICY IF EXISTS ثم CREATE POLICY).
- توحيد قالب الصفحات التالية على Web:
  - الإعلانات
  - الأنشطة (مع فلترة/بحث)
  - خطبة الجمعة (مع بحث)
  - كلمة الوزير
  - الهيكل التنظيمي
  - الوزراء السابقون

## 8) مهام قادمة (Next)
### A) صفحات إعلامية ناقصة (إن لزم)
- صفحة “الخدمات الاجتماعية” (Placeholder → تنفيذ فعلي)
- صفحات “المشاريع” و “المساجد” (تحسينات UX + ربط بيانات)

### B) إدارة المحتوى من لوحة التحكم
- CRUD للإعلانات (إنشاء شاشة إدارة مستقلة)
- CRUD للأخبار/الأنشطة/الخطب (تحسينات وإكمال الحقول)

### C) ضبط RBAC على الواجهة
- قراءة `admin_users` بعد تسجيل الدخول
- تحميل Roles/Permissions وتفعيل Guards
- صفحة Forbidden/Login وربطها بالمسارات الإدارية

### D) i18n
- نقل النصوص الصلبة إلى ملفات الترجمة ar/en

## 9) ملاحظات تشغيل
- عند ظهور أخطاء RLS: افحص أولًا وجود الجداول + أسماء الأعمدة + سياسات RLS.
- إذا ظهرت أخطاء تنقل على Web: افحص أي صفحة تستخدم `CustomAppBar` أو `AppRouter.pop`.


---

## تحديثات 2025-12-29
- إضافة مسار إداري **/admin/mosques** داخل PlatformAdminShell + شاشة Placeholder (لتجنب الشاشات البيضاء).
- إضافة شاشة **إدارة المؤسسات** **/admin/org-units** (CRUD) تربط:
  - `org_units`
  - `org_unit_profiles` (تواصل + سوشيال)
- تحديث السايدبار لإظهار (المؤسسات).
- إضافة/تحديث ملف **problems_solves.md** كمرجع للأخطاء والحلول.

### القادم مباشرة
- ربط صفحات الموقع العام بنطاق `org_units`:
  - `/home` للوزارة
  - `/:code` للمديرية/المؤسسة (مثل `/Bth`)
- توحيد قراءة بيانات التواصل/السوشيال من `org_unit_profiles` حسب الوحدة الحالية.
- توسيع محتوى (أخبار/إعلانات/أنشطة/فعاليات/خطب) بإضافة `unit_id` (Migration خفيف + Backfill).


## تحديث 2025-12-29
- [x] إصلاح خطأ النص في صفحة إدارة المساجد (compile).
- [x] إصلاح صفحة المشاريع لتتوافق مع AppFilterChip (isSelected/onSelected).
- [x] توحيد صفحات: الخدمات الإلكترونية/المشاريع/الرؤية والرسالة بنمط WebPublicPage على الويب.
- [x] إصلاح صفحات الويب التي أصبحت بيضاء/تعمل Loop بسبب ListView/Expanded داخل WebPublicPage (تحويلها إلى Column على الويب).
- [x] توحيد موضع الفلاتر في صفحة الإعلانات الرسمية (headerExtras).
- [x] توحيد صفحة الأنشطة على الويب بنمط (الأخبار): نقل البحث/الفلاتر إلى الهيدر + تطبيع النصوص.
- [x] إصلاح صفحة الإعلانات الرسمية: تصحيح ترميز أسماء Priority (منخفض/متوسط/عالي/عاجل/طارئ) + استخدام AppFilterChip بنمط موحّد.
- [x] إلغاء Splash لصفحة الموقع الرسمية: تحويل المسار `/` مباشرة إلى `/home` (وزارة = home).
- [x] إضافة شاشة انتقال عند الدخول للأنظمة الخدمية: `/switch/:systemKey` + إضافة قائمة (الأنظمة) في WebAppBar وتوجيهها عبر شاشة الانتقال.
- [ ] توحيد بقية الصفحات العامة التي ما زالت تستخدم Scaffold مخصص على الويب (مراجعة شاملة).
- [ ] توحيد Toolbar (بحث/فلترة) في: الأخبار/الإعلانات/الأنشطة/الخطب (تصميم واحد + re-usable widget).


## 5) Institution Routing (home + directorates)
- [x] اعتماد slug للوحدات: وزارة = `home`، مديريات مثل: `bth`, `jer`, `rml`...
- [x] تفعيل مسارات ديناميكية: `/:unitSlug/news` + `/:unitSlug/announcements` + `/:unitSlug/activities`
- [x] Redirect للمسارات القديمة: `/news` → `/home/news`، `/announcements` → `/home/announcements`، `/activities` → `/home/activities`
- [x] إضافة صفحة وحدة ديناميكية: `/:unitSlug` (مبدئيًا روابط للأخبار/الإعلانات/الأنشطة)
- [ ] استكمال: صفحة بيانات الوحدة (اتصال + تواصل اجتماعي) وربطها بـ `org_unit_profiles`
- [ ] استكمال: توحيد المشاريع/الخدمات/الرؤية… لتصبح Unit-scoped عند الحاجة

## 6) SQL / DB
- [x] org_units + org_unit_profiles (Step 4)
- [x] ربط المحتوى العام بوحدة عبر unit_id + backfill (Step 5: `supabase/sql/palwakf_step5_unit_scoping_content_v1.sql`)
- [ ] تحديث سياسات RLS (إن لزم) لتصفية القراءة حسب `unit_id` للجمهور/لوحات التحكم


## تحديث 2025-12-30 (Hotfix)
- [x] إصلاح أخطاء Build بعد خطوة Unit Routes:
  - إضافة Imports الناقصة في `go_router_config.dart` (UnitRoutes/UnitHomeScreen/NewsDetailRouteScreen/NewsArticle).
  - إصلاح صفحة الأنشطة: تمرير `unitSlug` إلى الجسم + استخدام `filteredActivitiesForUnitProvider(unitSlug)` في الويب والموبايل.
  - إصلاح صفحة الإعلانات الرسمية: توحيد فلاتر الأولوية (منخفض/متوسط/عالي/عاجل/طارئ) + تعديل `onSelected` ليطابق `AppFilterChip`.
  - إضافة `AppDateUtils.formatDate()` لمنع خطأ عدم وجود الدالة.
- [x] تثبيت `code/slug` في نموذج `Org Units`:
  - `code` = Uppercase (A-Z0-9_-)
  - `slug` = lowercase (a-z0-9_-)
  - تعبئة slug تلقائيًا من code ما لم يقم المستخدم بتعديله.
- [x] إصلاح SQL Migration Step 5: إدراج home مع `code='HOME'` ومعالجة حالة وجود home بدون code.


## تحديثات 2025-12-30
- إصلاح صفحة الأنشطة: إزالة `const` من `Padding` لتفادي خطأ Not a constant expression.
- إصلاح صفحة تفاصيل الخبر: استبدال `AppErrorWidget` بـ `CustomErrorWidget`.
- تثبيت سلوك code/slug في فورم المؤسسات: مزامنة slug تلقائياً مع code طالما لم يتم تعديله يدويًا.
