# UAT Checklist

1. Apply the update.
2. Run:

```bash
flutter analyze
```

Expected:

```text
No issues found
```

3. Run:

```bash
flutter run -d chrome
```

Expected:

```text
Application compiles and opens in Chrome
```

4. Retest Add News:

```text
/admin/media-center/news
```

Expected:

```text
/rest/v1/news_articles
Status 201 / 200 / 204
```

If another `400` appears, send the Response body.
