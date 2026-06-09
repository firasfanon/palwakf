# RPC PWF Key Governance — v0.1.0

## 1) هدف العقد
تثبيت نقطة استدعاء واحدة لتوليد المفتاح الوطني PWF داخل المنصة، لمنع تعدد المعايير أو تضارب المفاتيح.

## 2) نقطة الاستدعاء الوحيدة (Public Wrapper)
- RPC المعتمد للتطبيق:
  - `public.generate_pwf_key(...)`
- التنفيذ الداخلي (اختياري):
  - `core.generate_pwf_key(...)`
- سبب wrapper:
  - إبقاء core غير مكشوف عبر PostgREST إن كانت سياسة المنصة كذلك.

## 3) منع السباق (Race condition) — قرار سيادي
- منع السباق يُعالج داخل DB فقط:
  - Transaction
  - Lock على scope
- ممنوع نقل منطق السباق إلى Flutter أو services.

## 4) Scope المعياري للتسلسل + checksum
المعيار الملزم:
- scope = (version, gov_code, lgu_code, asset_type)

ملاحظة:
- community_code (إن وُجد) يُسمح به كـ metadata أو استخدامات ثانوية،
  لكنه لا يدخل في scope ولا checksum حتى لا نصنع معيارين.

## 5) Checksum
- معيار checksum الملزم: MOD97

## 6) Payload ثابت (Request)
الحقول:
- version: string (افتراضي "V1")
- gov_code: string (مثل "JE")
- lgu_code: string (مثل "JE001")
- asset_type: string enum (مثال: BLD, LND, MSA, CEM, MAQ, ARC ...)

اختياري:
- community_code: string (لا يدخل في scope/checksum)
- unit_id: uuid (إن احتجنا عزل تسلسل لكل جهة تشغيل)

## 7) Response ثابت
- pwf_key: string
- seq: int
- checksum: int
- scope: json (للتدقيق/التتبع)

## 8) قواعد منع تلقائية (CI)
- ممنوع إنشاء RPC أخرى لتوليد المفتاح.
- ممنوع تغيير payload/response دون رفع نسخة العقود + نافذة deprecation.
