# Internal Assistant Scope Update — N2.22

يجب أن يتعامل المساعد الداخلي مع جداول قاعدة البيانات وفق مصدر الحقيقة المعتمد.

## قواعد

- عند الإجابة عن الوحدات التنظيمية الحديثة، يرجع إلى `core.org_units` أو public RPC/view فوق core.
- لا يعتبر `public.org_units_cache` أو `public.pwf_org_units_cache` مصدرًا موثوقًا.
- يميز بين historical/Mustakshif-only والجداول الإدارية الحديثة.
- عند اقتراح SQL، يلتزم بـ read-only audit قبل أي نقل.
- لا يقترح حذف جداول مباشرة.
