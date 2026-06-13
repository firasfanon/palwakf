# UAT Checklist

## Analyzer

Run:

```bash
flutter analyze
```

Expected:
- No errors from `pwf_technical_service_operations_models.dart`.
- No protected `state` warnings from the technical services extension files.

## CMS Add News

1. Open `/admin/media-center/news`.
2. Open DevTools → Network → Fetch/XHR.
3. Add a news item without filling the optional writer field.
4. Save.

Expected:
- Request target remains `/rest/v1/news_articles`.
- The `author` not-null error should be closed by fallback.
- Status should move to `201/200/204` unless another DB constraint appears.

If another 400 appears, send the Response body.
