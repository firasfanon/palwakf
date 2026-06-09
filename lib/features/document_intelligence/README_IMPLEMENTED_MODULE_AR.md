# Document Intelligence — Implemented Module

تم تنفيذ الموديول الأولي داخل المنصة ويشمل:
- Dashboard
- Create Job
- Job Detail
- Review Queue
- Review Page
- Linking Page
- GoRouter routes
- Repository يستهلك RPC wrappers الحالية

## المسارات
- /admin/document-intelligence
- /admin/document-intelligence/jobs/new
- /admin/document-intelligence/jobs/:jobId
- /admin/document-intelligence/review-queue
- /admin/document-intelligence/review/:jobId
- /admin/document-intelligence/linking/:jobId

## الملاحظات
- الربط الحالي يعتمد على RPC draft wrappers الموجودة في sql_sandbox/document_intelligence/
- ما زال التطبيق بحاجة إلى migration فعلية وتأكيد RBAC في قاعدة البيانات قبل الإنتاج
