# Browser UAT Checklist

Open these routes after running the app:

```text
flutter run -d chrome
```

## Required Routes

- `/admin/platform/technical-services`
- `/admin/platform/technical-services/backup`
- `/admin/platform/technical-services/maintenance`
- `/admin/platform/technical-services/health`
- `/admin/platform/technical-services/deployment`
- `/admin/platform/technical-services/audit`

## Expected Result

- Page renders without red screen.
- Sidebar shows the new entries under the platform/admin area.
- Dashboard shows a technical services quick-access group.
- Navigation between sub-pages works.
- No network mutation is triggered.
- Console has no critical Flutter errors.

## Evidence Required

- Screenshots for hub + backup + maintenance + health.
- Console clean screenshot.
- Optional: Network screenshot proving no write calls are fired by page load.
