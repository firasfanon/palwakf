-- PalWakf V4 Wave1 Dependency Remediation Apply Design + Role/RLS UAT Execution Pack
-- Date: 2026-06-01
-- Safety: READ ONLY unless file name explicitly says FUTURE/SKELETON; no DDL/DML/GRANT/REVOKE/DROP/DELETE/ARCHIVE/RENAME.
-- Context: SQL02 move already applied. Do not rerun Wave1 SQL02 move.
-- Production: NOT APPROVED.

with smoke(surface_group, route_or_operation, expected_runtime_source, required_evidence, production_blocking) as (
  values
    ('platform_navigation','/home/services + /home/eservices','owner schema table behind public compatibility surface or owner-read RPC','browser page opens; console marker; no 400/404; no legacy table write', true),
    ('media_center','/home/news + /admin/media-center/news','media_center owner schema table through accepted runtime adapters','browser page opens; admin list opens; console clean for media scope', true),
    ('service_center','/home/services/request + /home/services/track + /admin/surfaces-services/request-queue','platform_services owner runtime + public RPC wrappers','submit/track/admin queue smoke; transition check if authorized', true),
    ('platform_access','/admin/dashboard + /admin/system-registry + login gateway','platform_access owner tables with RBAC/RLS','superuser positive; unauthorized negative; bthusr1 scoped sidebar', true),
    ('awqaf_system','/systems/awqaf-system + Awqaf Assist workspace','awqaf_system owner tables; no waqf_assets mutation','browser route opens; analyzer clean; role scoped checks', true),
    ('core_gis_reference','governorates/cities/location lookup RPCs','core/gis owner references through safe RPC/views','lookup smoke; no direct public source-of-truth assumption', true),
    ('wave3_collision_tables','assistant/core/gis collision tables','not moved in Wave1','confirm still excluded; no compare/merge executed', true)
)
select
  'v4_wave1_browser_runtime_smoke_matrix_detail' as section,
  surface_group,
  route_or_operation,
  expected_runtime_source,
  required_evidence,
  production_blocking,
  false as browser_uat_confirmed_by_this_script,
  false as production_approved,
  true as read_only
from smoke
order by surface_group;
