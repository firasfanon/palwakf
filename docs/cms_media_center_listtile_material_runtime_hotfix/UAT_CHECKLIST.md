# UAT Checklist

## Analyzer

Run:

```bash
flutter analyze
```

Expected:

```text
No issues found
```

## Runtime

Run:

```bash
flutter run -d chrome
```

Open:

```text
/admin/media-center/news
/admin/media-center/announcements
```

Expected Console:

```text
No repeated "ListTile background color or ink splashes may be invisible"
```

## CMS Network Evidence

Keep using Network → Fetch/XHR for:

```text
/rest/v1/news_articles
/rest/v1/announcements
```

Expected for reads:

```text
Status 200
```

Expected for successful save/update:

```text
Status 201 / 200 / 204
```
