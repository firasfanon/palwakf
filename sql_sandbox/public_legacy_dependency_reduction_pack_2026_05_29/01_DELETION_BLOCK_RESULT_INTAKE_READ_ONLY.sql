-- Public Legacy Dependency Reduction Pack
-- 01_DELETION_BLOCK_RESULT_INTAKE_READ_ONLY.sql
-- Read-only result-intake marker. No DDL/DML/GRANT/DROP.

select *
from (
  values
    ('public_legacy_dependency_reduction', 'delete_candidate_count', '0', 'No public legacy media/service table is safe to delete now.'),
    ('public_legacy_dependency_reduction', 'media_tables_decision', 'DATA_MOVED_BUT_DB_DEPENDENCIES_REMAIN_DO_NOT_DELETE', 'Media rows are present in media_center owner schema, but routines/policies/grants still reference legacy public surfaces.'),
    ('public_legacy_dependency_reduction', 'service_tables_decision', 'PRESERVE_FOR_NOW_SERVICE_CATALOG_OR_TAXONOMY_NOT_SAFE_TO_DELETE', 'Service catalog/taxonomy tables remain runtime/dependency surfaces.'),
    ('public_legacy_dependency_reduction', 'next_action', 'DEPENDENCY_REDUCTION_NOT_DELETION', 'Export exact function bodies before any rewrite.'),
    ('public_legacy_dependency_reduction', 'production_approved', 'false', 'This pack does not approve global production.'),
    ('public_legacy_dependency_reduction', 'destructive_sql_authorized', 'false', 'No destructive SQL authorized.'),
    ('public_legacy_dependency_reduction', 'read_only', 'true', 'This script is SELECT-only.')
) as t(section, key, value, note);
