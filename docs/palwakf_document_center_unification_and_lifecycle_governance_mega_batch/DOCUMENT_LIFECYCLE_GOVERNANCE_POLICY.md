
# Document Lifecycle Governance Policy

## Classification

| Class | Arabic | Delete Rule | Typical Systems |
|---|---|---|---|
| `transient` | مؤقت | يحذف بعد مدة قصيرة أو عند فشل العملية | Upload drafts |
| `operational` | تشغيلي | يحتفظ حسب دورة الطلب/الإجراء | Services |
| `long_term_reference` | مرجع طويل الأمد | لا يحذف إلا بقرار مؤسسي | Awqaf, official docs |
| `legal_evidence` | دليل قانوني | immutable قدر الإمكان + audit | Cases/legal |
| `public_media` | إعلامي عام | ينشر/يؤرشف حسب سياسة الإعلام | Media Center |

## Required Metadata

Any governed file should eventually expose:

```text
document_type_id
retention_class
retention_until
legal_hold
confidentiality_level
is_original
derived_from_id
checksum_sha256
lifecycle_status
```

## Key Rule

Do not delete or overwrite files classified as:

```text
long_term_reference
legal_evidence
```

without an explicit governed action and audit trail.
