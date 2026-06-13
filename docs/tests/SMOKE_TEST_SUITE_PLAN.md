# PalWakf Smoke Test Suite

## Goal

Create a lightweight repeatable smoke suite that detects integration contract breaks before manual UAT.

## Scope

The first smoke suite should focus on the most fragile integration points:

1. CMS writes
2. CMS public reads
3. Technical Services dashboard RPC
4. Core locations summary
5. Media Center compatibility wrappers
6. RBAC route access

## Smoke Test Cases

| Test ID | Area | Test | Expected |
|---|---|---|---|
| SMK-01 | CMS News | Create or update news with valid payload | `/rest/v1/news_articles` returns 201/200/204 |
| SMK-02 | CMS News | Ensure unsupported fields are stripped | No PGRST204 unknown-column error |
| SMK-03 | CMS Announcements | Read announcements list | `/rest/v1/announcements` returns 200 |
| SMK-04 | CMS Announcements | Update/toggle announcement | `/rest/v1/announcements?id=eq.*` returns 204/200 |
| SMK-05 | Media Center | Public news wrapper read | `v_media_news_compat_v1` returns data |
| SMK-06 | Media Center | Public announcements wrapper read | `v_media_announcements_compat_v1` returns data |
| SMK-07 | Media Center | Public activities wrapper read | `v_media_activities_compat_v1` returns data |
| SMK-08 | Technical Services | Dashboard RPC | `rpc_platform_technical_services_dashboard_v1` returns 200 |
| SMK-09 | Technical Services | Operations Center render | Evidence/Notifications/Decisions section renders |
| SMK-10 | RBAC | Restricted route with unauthorized user | Access denied screen appears |
| SMK-11 | Core Locations | Location summary route/RPC | Returns 200 or governed empty state |
| SMK-12 | Analyzer | Static analysis | `flutter analyze` has no blocking errors |

## Execution Modes

### Manual Smoke

- Browser + DevTools Network
- Screenshot evidence
- Console evidence

### Automated Smoke — Future

Recommended future options:

- Flutter integration test
- Supabase RPC smoke script
- Playwright browser smoke script
- CI smoke step after build

## Acceptance Criteria

A release candidate should not be considered stable unless:

- SMK-01 to SMK-08 pass
- `flutter analyze` has no errors
- Any warning is documented and accepted
- Network evidence is captured for critical RPC/direct table operations
