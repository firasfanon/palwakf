# Governing Contract Appendix — Database Wave B-1A Media Wrapper Runtime Gate

**Date:** 2026-05-20

## Contract update

أي تحويل Runtime للإعلام العام من جداول `public` القديمة إلى `media_center` عبر `public.v_media_*_compat_v1` مشروط بثلاث بوابات متتابعة:

1. SQL preflight nonzero + published-only + RPC gate.
2. Browser UAT للصفحات العامة المعنية.
3. قرار صريح لتعديل Flutter، مع fallback وخطة rollback.

## Prohibited shortcuts

- لا يجوز اعتبار وجود seed وحده كافيًا للتحويل.
- لا يجوز تحويل gallery قبل asset/content mapping.
- لا يجوز استخدام wrappers الفارغة كبديل runtime.
- لا يجوز حذف الجداول القديمة أو استخراجها في Wave B-1A.
