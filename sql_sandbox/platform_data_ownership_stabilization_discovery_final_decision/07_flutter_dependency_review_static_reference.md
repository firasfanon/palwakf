# Flutter Dependency Review — Static Reference

The generated file `evidence/platform_data_ownership_stabilization_discovery/code_dependency_matrix.csv` records current static dependencies.

Key finding: admin/legacy/task surfaces still contain direct references to `public.news_articles`, `public.announcements`, `public.activities`, and `public.media_gallery_items`. Therefore Wave B-1B must not delete or rename legacy tables. It must first provide compatibility wrappers and then reroute runtime paths deliberately.
