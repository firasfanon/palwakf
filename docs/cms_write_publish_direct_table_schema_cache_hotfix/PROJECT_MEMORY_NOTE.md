# CMS Write/Publish Evidence Update

Based on browser Network evidence:

```text
CMS Add News / Add Announcement uses direct Supabase REST table access.
Observed endpoint examples:
- /rest/v1/news_articles
- /rest/v1/announcements
```

No `/rpc/` endpoint was observed for the tested Add/Save operation.

Current classification:

```text
Option B: CMS write/save uses direct table access for the tested operation.
```

Caveat:

```text
The observed request returned 400 before this hotfix. Therefore, the previous screenshot confirms access type but not successful save. After this hotfix, a 2xx Network screenshot is still required to close successful write evidence.
```
