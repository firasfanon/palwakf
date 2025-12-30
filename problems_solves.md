# problems_solves.md
مرجع تراكمي للأخطاء التي واجهتنا في PalWakf وكيف تم حلّها لتفادي تكرارها لاحقًا.
> يتم تحديثه مع كل إصلاح.

## 2025-12-29
### 1) SQL: خطأ syntax عند `CREATE POLICY IF NOT EXISTS`
- **السبب:** PostgreSQL لا يدعم `IF NOT EXISTS` في `CREATE POLICY`.
- **الحل:** استخدام:
  - `DROP POLICY IF EXISTS <name> ON <table>;`
  - ثم `CREATE POLICY ...;`

### 2) شاشة حمراء/بيضاء عند الرجوع (Back) في الويب
- **السبب:** استخدام `Navigator.pop()` أو `context.pop()` بدون وجود stack على الويب يؤدي لحالة Route غير مستقرة.
- **الحل:** زر رجوع موحّد مع fallback إلى `/home` (GoRouter):
  - إذا `canPop()` ➜ `pop()`
  - غير ذلك ➜ `go('/home')`

### 3) أحرف غريبة في صفحة الإعلانات الرسمية
- **السبب:** وجود HTML entities / BOM / علامات اتجاه (Bidi) في النص.
- **الحل:** تطبيع النص عبر دالة `normalizeRichText()` قبل العرض والبحث.

### 4) أخطاء تجميع: `AppRoutes.pushAndClearStack` و `pushReplacement` غير موجودة
- **السبب:** ملفات قديمة ما زالت تعتمد دوال تنقل legacy.
- **الحل:** إعادة إضافة الدوال داخل `AppRoutes` كتغليف لـ GoRouter (`go` و`replace`).

### 5) Route مفقود في السايدبار: `adminMosques`
- **السبب:** وجود عنصر في السايدبار يشير لمسار غير موجود/غير معرف بالكامل.
- **الحل:** تعريف `AppRoutes.adminMosques` + إضافة GoRoute داخل PlatformAdminShell + شاشة Placeholder لتجنب الصفحات البيضاء.

### 6) عدم تطابق حقول Activity (titleAr/locationAr/descriptionAr)
- **السبب:** الشاشة استخدمت أسماء حقول غير موجودة في `Activity`.
- **الحل:** توحيد الاعتماد على الحقول الموجودة فعليًا في الموديل (title/description/location) + تحسين الفلاتر.



### 2025-12-29 – إصلاحات تجميع وتوحيد الواجهة

#### 1) MosqueManagementScreen: خطأ String غير مغلق
**العَرَض:** خطأ Compile: `String starting with ' must end with '`.
**السبب:** سطر نص متعدد الأسطر داخل `'...'` بدون `\n` أو دمج صحيح.
**الحل:** تعريف نص ثابت (const) واستخدام `\n` داخل نفس الـ string (بدون كسر السطر داخل علامات الاقتباس).

#### 2) ProjectsScreen: عدم تطابق AppFilterChip API
**العَرَض:** أخطاء Compile مثل: `No named parameter with the name 'selected'` أو `List<dynamic> can't be assigned to List<Widget>`.
**السبب:** AppFilterChip يعتمد `isSelected` و `onSelected` (VoidCallback)، بينما بعض الصفحات استخدمت `selected` أو `onSelected: (_)=>...`.
**الحل:** توحيد الاستخدام إلى:
- `isSelected: ...`
- `onSelected: () => ...`
- واستخدام `map<Widget>(...)` لضمان نوع `List<Widget>`.

#### 3) توحيد صفحات (الخدمات الإلكترونية/المشاريع/الرؤية والرسالة) على قالب WebPublicPage
**العَرَض:** صفحات تُظهر زر رجوع أو Scaffold مختلف على الويب → تذبذب تنقّل/واجهة غير موحّدة.
**الحل:** إضافة `kIsWeb` + `WebPublicPage` للويب، وترك `CustomAppBar` للموبايل.

#### 4) نقل فلاتر الإعلانات الرسمية إلى Header
**السبب:** اختلاف موضع الفلاتر عن النمط العام (الأخبار).
**الحل:** استخدام `headerExtras` في `WebPublicPage` لعرض الفلاتر تحت العنوان مباشرة.

#### 5) صفحات بيضاء/تكرار (Loop) في الويب بعد توحيد القالب
**العَرَض:** صفحات مثل (الخدمات الإلكترونية/المشاريع/الرؤية والرسالة) تصبح بيضاء أو تظهر شاشة خطأ عند التنقل.
**السبب:** `WebPublicPage` يحتوي `SingleChildScrollView`، وبالتالي إدراج `ListView`/`Expanded` داخل صفحته يسبب قيود ارتفاع غير محدودة (Unbounded height) فتظهر شاشة بيضاء/حمراء وقد يبدو كأنه Loop.
**الحل:** على الويب داخل `WebPublicPage`:
- لا نستخدم `ListView` كـ root.
- نستخدم `Column` + عناصر، أو `ListView` مع `shrinkWrap: true` و `NeverScrollableScrollPhysics`.

#### 6) صفحة الأنشطة: اختلاف تنسيق + نصوص تظهر بأحرف غير مفهومة
**العَرَض:** صفحة الأنشطة تختلف عن نمط (الأخبار) في مكان البحث/الفلاتر، وبعض النصوص تظهر بأحرف/رموز غريبة.
**السبب:**
- الفلاتر كانت داخل المحتوى بدل الهيدر (على الويب) بعكس نمط الأخبار.
- بعض بيانات الأنشطة تحتوي HTML entities / BOM / mojibake.
**الحل:**
- نقل البحث + شرائح الفلاتر إلى `headerExtras` في `WebPublicPage` مع `AppFilterChip(onDarkBackground: true)`.
- تطبيق `normalizeRichText(...)` عند العرض والبحث (العنوان/الوصف/المكان).

#### 7) صفحة الإعلانات الرسمية: أسماء الأولوية (Priority) تظهر بأحرف غريبة
**العَرَض:** كلمات مثل: `Ù…Ù†Ø®ÙØ¶` بدل (منخفض/متوسط…)
**السبب:** نصوص عربية مكتوبة/محفوظة بترميز خاطئ داخل `PriorityExtension.displayName`.
**الحل:** تصحيح قيم `displayName` في `lib/data/models/announcement.dart` إلى العربية الصحيحة:
- منخفض / متوسط / عالي / عاجل / طارئ

#### 8) Splash غير مناسب للموقع الرسمي + الحاجة لتنبيه الانتقال للأنظمة
**العَرَض:** فتح الموقع يُظهر Splash، بينما المواقع الرسمية عادةً تُظهر الصفحة الرئيسية مباشرة. وفي المقابل عند الانتقال لنظام خدمي (مثل المستكشف) يحتاج المستخدم لإشارة أنه انتقل لنظام آخر.
**الحل:**
- جعل `/` يعيد التوجيه مباشرة إلى `/home` (وزارة = home).
- إضافة صفحة انتقال خفيفة `/switch/:systemKey` (650ms) ثم التحويل تلقائيًا لمسار النظام (`/mustakshif` …).
- تحديث WebAppBar لإضافة قائمة (الأنظمة) وتوجيهها عبر `/switch/<slug>`.


## 2025-12-30 — Unit routes + ربط المحتوى بـ unit_id
**المشكلة:** احتجنا صفحات مديريات/وحدات متعددة بدون إنشاء صفحات وجداول لكل مديرية/نظام.
**الحل:**
- اعتماد `org_units.slug` كمسار ديناميكي: `/:unitSlug`
- إضافة مسارات فرعية موحّدة: `/:unitSlug/news`, `/:unitSlug/announcements`, `/:unitSlug/activities`
- تفعيل Redirect للمسارات القديمة (`/news`… إلخ) إلى `home`
- SQL Migration: إضافة `unit_id` + backfill + FK + Index في:
  - `news_articles`, `announcements`, `activities`

**ملفات مهمة:**
- `lib/app/routing/unit_routes.dart`
- `lib/app/routing/unit_path_utils.dart`
- `lib/presentation/providers/unit_context_provider.dart`
- `supabase/sql/palwakf_step5_unit_scoping_content_v1.sql`


## 2025-12-30 — أخطاء Build بعد تفعيل Unit Routes
**العَرَض:** أخطاء مثل `Undefined name 'UnitRoutes'` و `NewsArticle isn't a type` و `unitSlug isn't defined`.
**السبب:** Imports ناقصة + تمرير unitSlug غير مكتمل + Provider خاطئ للأنشطة.
**الحل:**
- إضافة Imports الناقصة في `lib/app/routing/go_router_config.dart`.
- تعديل `ActivitiesScreen` لاستخدام `filteredActivitiesForUnitProvider(unitSlug)` وتمرير `unitSlug` إلى `_ActivitiesBody`.

## 2025-12-30 — خطأ SQL: org_units.code NOT NULL
**العَرَض:** `null value in column "code" of relation "org_units" violates not-null constraint` أثناء backfill.
**السبب:** سكربت Step 5 كان ينشئ وحدة `home` بدون `code`.
**الحل:**
- تعديل `supabase/sql/palwakf_step5_unit_scoping_content_v1.sql` ليُدرج:
  - `code='HOME'` عند الإنشاء.
  - تحديث code إذا كانت الوحدة موجودة لكن code فارغ/NULL.
- تثبيت Normalize داخل نموذج إدخال Org Units (الكود Uppercase والـ slug lowercase).


## 2025-12-30 – أخطاء تجميع + SQL
1) **Not a constant expression (ActivitiesScreen)**
- **السبب:** `const Padding` يحتوي Widget يعتمد على متغير `unitSlug`.
- **الحل:** إزالة `const` من `Padding` في ActivitiesScreen.

2) **AppErrorWidget غير موجود**
- **السبب:** اسم Widget الحقيقي هو `CustomErrorWidget` داخل `widgets/common/error_widget.dart`.
- **الحل:** استبدال `AppErrorWidget` بـ `CustomErrorWidget` في NewsDetailRouteScreen.

3) **syntax error near ".." بسبب استخدام `...` في SQL**
- **السبب:** وجود ellipsis (`...`) في قيم INSERT (نسخ/لصق مثال غير مكتمل).
- **الحل:** تشغيل ملفات SQL من مجلد `supabase/sql/` كما هي، بدون `...`.
