-- Database Wave B-1A — Media/Locations Blocker Matrix
-- READ ONLY. No DDL. No DML. No migration.

select * from (
  values
    ('media_center','media_legacy_tables','bootstrap_required','no_activation','Create/certify sovereign media runtime, RLS, editorial workflow, and public/admin mapping before wrapper activation.'),
    ('media_center','public_activities_announcements','high_risk_public_dependency','no_extraction','Do not move public activities/announcements in B-1A.'),
    ('media_center','public_news_articles','high_risk_public_dependency','no_extraction','Keep public media tables unchanged until media_center readiness is certified.'),
    ('locations','public_locations_vs_gis_locations','authority_unresolved','blocked','Manual authority decision required before any location wrapper activation.'),
    ('servicepoints','service_points_and_providers','owner_ambiguous','blocked','Decide services vs facilities vs GIS ownership before reroute/extraction.'),
    ('services','services_compatibility_closure','closed_and_preserved','preserve','No new service reroute in this pack.'),
    ('waqf','waqf_assets_boundary','critical_read_only','forbidden','No mutation, no extraction, no wrapper activation in this pack.'),
    ('wave_b1b','selective_sovereign_extraction','not_ready','blocked','Extraction remains unauthorized.')
) as t(domain_key, blocker_key, readiness_status, b1a_decision, note);
