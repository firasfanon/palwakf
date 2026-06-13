# Data Contract Validation Policy

## Decision

All frontend write operations must pass through a payload contract before reaching Supabase direct table writes or RPC calls.

## Problem Addressed

Recent CMS defects showed that direct PostgREST writes can fail when the frontend sends fields not present in the target table, for example:

- `attachment_url` sent to `news_articles`
- optional UI fields sent to legacy public tables
- required database columns such as `author` missing from payload

## Policy

### 1. Public Reads

Public read surfaces must use stable compatibility views/wrappers.

Examples:

```text
public.v_media_news_compat_v1
public.v_media_announcements_compat_v1
public.v_media_activities_compat_v1
```

### 2. Admin Writes

Admin writes may use direct owner-table writes only for simple create/update operations, provided a payload contract is enforced.

### 3. Governance Actions

Governance actions must use RPC:

- publish
- unpublish
- transition
- approve
- reject
- close
- rollback
- audit/decision recording

### 4. Payload Contract Requirements

Each entity must define:

- allowed fields
- required fields
- default/fallback values
- enum/status normalization
- fields to strip before write
- mapping from UI labels to DB fields

## Acceptance Criteria

A write operation is accepted only if:

1. Unknown fields are removed.
2. Required fields are present or defaulted.
3. Enum/status values match DB constraints.
4. The Network request returns `201`, `200`, or `204`.
5. Evidence is captured in DevTools Network.
