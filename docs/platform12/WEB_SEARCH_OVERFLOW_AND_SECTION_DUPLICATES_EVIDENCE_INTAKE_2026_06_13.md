# Platform 12 — Web Search Overflow + Homepage Section Duplicate Evidence Intake

Date: 2026-06-13  
Batch: `PLATFORM12_WEB_SEARCH_OVERFLOW_AND_SECTION_DUPLICATES_EVIDENCE_INTAKE`

## Evidence received

The browser evidence for `/home/search?q=مسجد` confirms that the search route now renders results. The search issue is therefore no longer a complete binding failure.

Observed result:

```text
/home/search?q=مسجد
نتائج البحث (1)
المساجد
```

The same screenshot shows console/runtime layout exceptions:

```text
RenderFlex overflowed by 3.5 pixels on the right.
RenderFlex overflowed by 29 pixels on the right.
```

The visible widget ancestry points to `WebAppBar`, so the immediate runtime defect is a responsive-width overflow in the public web app bar when the viewport is narrowed, for example when DevTools is docked.

## Source cause — AppBar overflow

`lib/presentation/widgets/web/web_app_bar.dart` used a fixed horizontal layout:

```text
logo + 60px gap + full navigation row + language + search + login
```

At medium/narrow widths this cannot fit. The issue is frontend layout, not Supabase/RPC.

## Remediation — AppBar responsive hardening

The web app bar now uses `LayoutBuilder` to select layout density:

- full navigation on wide screens;
- compact menu button under constrained width;
- icon-only logo under narrow width;
- smaller horizontal padding and spacing under narrow width;
- hidden language selector below the minimum safe width;
- preserved login/search controls.

This targets the exact `RenderFlex` overflow reported in the browser console.

## Search page responsive hardening

The search content area now changes from a two-column results/sidebar layout to a stacked layout below 900px, preventing secondary overflows in the result body when DevTools is docked or the browser is narrow.

The result summary header also uses a `Wrap` instead of a fixed `Row`, so the result count and query label can wrap safely.

## Homepage section duplicate diagnostics — evidence received

The diagnostic SQL returned canonical duplicate rows for the global home unit:

```text
pwf_footer: ["pwf_footer", "footer"] active_count=2
pwf_announcements: ["announcements", "pwf_announcements"] active_count=1
pwf_breaking_news_marquee: ["breaking_news", "pwf_breaking_news_marquee"] active_count=1
pwf_minister_word: ["minister", "pwf_minister_word"] active_count=1
pwf_news_tabs: ["news", "pwf_news_tabs"] active_count=1
pwf_quick_services: ["services", "pwf_quick_services"] active_count=1
pwf_stats_grid: ["statistics", "pwf_stats_grid"] active_count=1
```

Interpretation:

- `pwf_footer/footer` is the only returned canonical duplicate with both rows active.
- The other canonical duplicates are legacy/canonical pairs where only one row is active; the frontend canonical merge should prevent double rendering, but the data still needs cleanup for governance clarity.

The semantic overlap diagnostic also returned active overlaps:

```text
links_family: pwf_important_links + pwf_quick_links_grid
media_gallery_family: pwf_media_gallery_images + pwf_media_gallery_videos
news_family: pwf_news_tabs + pwf_news
services_family: pwf_eservices_portal + pwf_quick_services
```

Interpretation:

- These are not all strict database duplicates.
- They are content-policy overlaps: the platform must decide whether each pair is intentionally separate or one should be inactive on the homepage.
- Automatic deactivation is not safe for semantic families without a content/UX decision.

## Prepared guarded SQL

A guarded SQL pack was added under:

```text
sql_sandbox/platform12_homepage_sections_duplicate_remediation_guarded/
```

Files:

```text
00_READ_ME_FIRST.sql
01_preflight_duplicate_rows_read_only.sql
02_deactivate_legacy_alias_duplicates_GUARDED_DML.sql
03_post_apply_validation_read_only.sql
04_semantic_family_policy_matrix_read_only.sql
```

`02_deactivate_legacy_alias_duplicates_GUARDED_DML.sql` is not authorized or executed by this patch. It requires an explicit operator token and only targets legacy alias duplicate rows. It does not decide semantic family policy.

## Current decision

```text
SEARCH_ROUTE_RENDERING_CONFIRMED
WEB_APPBAR_RESPONSIVE_OVERFLOW_HOTFIX_PREPARED
SEARCH_PAGE_NARROW_LAYOUT_HARDENED
DUPLICATE_SECTION_SQL_EVIDENCE_ACCEPTED
LEGACY_ALIAS_DUPLICATE_GUARDED_DML_PREPARED_NOT_EXECUTED
SEMANTIC_FAMILY_POLICY_DECISION_REQUIRED
NO_SQL_EXECUTED_BY_THIS_PATCH
PRODUCTION_NOT_APPROVED
```

## Required local retest

```text
/home/search?q=مسجد
/home/search?q=الخدمات
/home/search?q=الأخبار
```

Retest with DevTools docked and normal width. The console should not show new `RenderFlex overflowed` errors from `WebAppBar` or search results layout.
