-- Public Route Canonicalization Certification Status
-- Read-only marker. Does not touch application tables.
select 'public_route_canonicalization_certification' as section,
       'NAVIGATION_CERTIFICATION_DEFERRED_PENDING_POST_APPLY_EVIDENCE' as decision,
       'Post-apply browser/console evidence is required before certification.' as note;
