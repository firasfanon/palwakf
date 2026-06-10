-- Read-only smoke as authenticated role.
-- Run as a role that can SET ROLE authenticated.

begin;
set local role authenticated;

select 'platform11k_authenticated_runtime_certification_rpc_smoke' as section, *
from public.rpc_core_location_runtime_certification_v1();

select 'platform11k_authenticated_backlog_summary_rpc_smoke' as section, *
from public.rpc_core_location_backlog_summary_v1();

select 'platform11k_authenticated_backlog_queue_rpc_smoke' as section, *
from public.rpc_core_location_backlog_operational_queue_v1(null, null, null, 10, 0);

rollback;
