
# CMS Add News Network Evidence Gate

## Objective

Close CMS Add News as browser/runtime verified only when the Network request proves a successful write.

## Route

```text
/admin/media-center/news
```

## Required Action

Create or update a test news item from the CMS UI.

## Required DevTools Evidence

Open Chrome DevTools → Network → Fetch/XHR.

Expected request:

```text
/rest/v1/news_articles
```

Accepted status:

```text
201 Created
200 OK
204 No Content
```

## Required Evidence Fields

| Field | Required |
|---|---|
| Route screenshot | Yes |
| Network request URL | Yes |
| HTTP status | Yes |
| Request method | Yes |
| Payload must not include unsupported fields | Yes |
| Response must not include PGRST204 | Yes |
| Console critical errors absent | Yes |

## Payload Contract Checks

The outgoing payload must not include:

```text
attachment_url
attachment_path
is_pinned
sort_order
publish_at
```

For `news_articles`, if `author` is blank, the contract should default it to:

```text
إدارة المحتوى
```

## Closure Decision

| Condition | Decision |
|---|---|
| `/rest/v1/news_articles` returns 201/200/204 | CMS_ADD_NEWS_NETWORK_VERIFIED |
| `PGRST204` appears | CMS_ADD_NEWS_SCHEMA_CONTRACT_FAILED |
| `author null` appears | CMS_ADD_NEWS_REQUIRED_FIELD_CONTRACT_FAILED |
| No Network evidence supplied | CMS_ADD_NEWS_BROWSER_EVIDENCE_PENDING |

## Evidence Paste Template

```text
Route:
Action:
Network URL:
Method:
Status:
Console:
Decision:
Notes:
```
