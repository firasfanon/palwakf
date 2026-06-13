# Error Record — Home Search + Homepage Sections Consolidation

Date: 2026-06-13  
Session: تطوير المنصة 12

## Error 1 — Search button produced no useful results

### Symptom

Homepage search was not providing results from the expected public search route.

### Cause

The search control was not consistently bound to a governed route with query parameter propagation.

### Resolution

Search now routes through:

```text
/home/search?q=<query>
/<unitSlug>/search?q=<query>
```

The search screen reads the initial query and synchronizes further searches back to the URL.

## Error 2 — WebAppBar RenderFlex overflow under constrained width

### Symptom

The browser screenshot showed search results, but Chrome DevTools docked mode produced `RenderFlex overflowed` messages in the public web app bar.

### Cause

The top app bar had too many fixed-width action clusters for the effective constrained viewport.

### Resolution

The app bar and search page were hardened with width-aware compact behavior and wrap/stack fallback.

## Error 3 — Homepage section duplicates

### Symptom

Read-only diagnostics showed duplicate canonical section keys, especially:

```text
pwf_footer = ["pwf_footer", "footer"]
active_count = 2
```

### Cause

Legacy aliases and canonical section keys coexist in the compatibility read surface.

### Resolution

Runtime section reads now canonicalize aliases, sort deterministically, prefer canonical/active rows, and render each canonical key once. SQL cleanup remains gated by explicit authorization.

## Last stable baseline before this record

```text
platform12_web_search_overflow_section_duplicates_evidence_intake_2026_06_13.zip
```

## New baseline candidate

```text
platform12_home_search_sections_source_consolidation_mega_batch_2026_06_13.zip
```
