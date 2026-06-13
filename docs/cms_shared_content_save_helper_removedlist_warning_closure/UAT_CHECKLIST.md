# UAT Checklist

Run:

```bash
flutter analyze
```

Expected:

```text
No issues found
```

Then run:

```bash
flutter run -d chrome
```

Retest CMS Add News:

```text
/admin/media-center/news
```

Network evidence target:

```text
/rest/v1/news_articles
Status 201 / 200 / 204
```
