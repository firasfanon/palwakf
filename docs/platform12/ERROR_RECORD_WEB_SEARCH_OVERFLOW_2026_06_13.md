# Error Record — Platform 12 Web Search RenderFlex Overflow

Date: 2026-06-13

## Error

```text
RenderFlex overflowed by 3.5 pixels on the right.
RenderFlex overflowed by 29 pixels on the right.
```

## Trigger

Opening `/home/search?q=مسجد` with Chrome DevTools docked, causing a constrained viewport.

## Cause

`WebAppBar` used a fixed-width desktop row with full logo text, full navigation, language selector, search button, and login button. At medium/narrow widths the row exceeded available width.

## Files involved

```text
lib/presentation/widgets/web/web_app_bar.dart
lib/presentation/screens/public/search/web_search_screen.dart
```

## Fix

- Added responsive `LayoutBuilder` behavior to `WebAppBar`.
- Collapsed navigation into compact menu below safe width.
- Switched logo to icon-only below narrow width.
- Reduced padding and gaps under constrained width.
- Stacked search results/sidebar below 900px.
- Replaced result header fixed row with wrap-safe layout.

## Validation status

Static patch prepared. Flutter analyzer/browser runtime retest must be executed locally because Flutter SDK is unavailable in this sandbox.

## Last stable baseline

```text
platform12_home_search_sections_source_remediation_2026_06_13.zip
```
