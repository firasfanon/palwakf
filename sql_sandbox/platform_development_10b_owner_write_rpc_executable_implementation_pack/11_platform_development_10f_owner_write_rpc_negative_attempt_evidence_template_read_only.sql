-- Platform Development 10F
-- Owner-write RPC negative attempt evidence template.
-- This script is read-only as shipped: it returns the required cases and exact evidence columns.
-- Do not convert this into executable RPC calls unless you are in a controlled staging transaction
-- with known test actors and an explicit rollback plan.

with actor_case(actor_key, required_attempt, expected_result, required_evidence) as (
  values
    ('anonymous', 'Call each owner-write RPC without authenticated JWT/session.', 'DENIED: anon has no EXECUTE after 10C; no data mutation.', 'screenshot + console clean + SQL/RLS proof of denial'),
    ('unauthorized_authenticated_user', 'Call representative core/admin and platform owner-write RPCs with a valid but unauthorized user.', 'DENIED by SQL-level actor guard; audit/error captured without unsafe mutation.', 'denied RPC response + console clean + actor identifier redacted'),
    ('scoped_user', 'Attempt role/permission grant outside permitted module/system scope.', 'DENIED: out-of-scope system/permission change rejected.', 'RBAC wrapper evidence + denied write attempt'),
    ('unit_admin', 'Attempt platform-wide unsafe write or cross-unit write.', 'DENIED: unit scope cannot mutate platform-wide ownership/RBAC.', 'browser evidence + denied write-path evidence'),
    ('platform_admin', 'Attempt privilege escalation beyond platform_admin authority.', 'DENIED: cannot bypass SQL guards or escalate unsafe permissions.', 'positive access evidence + negative escalation denial'),
    ('superuser', 'Attempt self-lockout or unsafe self-demotion path.', 'DENIED: self-lockout guard rejects unsafe mutation.', 'positive access evidence + self-lockout denial')
), decision as (
  select
    '10f_negative_uat_template'::text as section,
    actor_key as check_key,
    false::boolean as passed,
    'required_attempt=' || required_attempt || ' | expected=' || expected_result || ' | evidence=' || required_evidence as note
  from actor_case
)
select * from decision
union all
select 'production_gate', 'implementation_production_approved', false, 'Not approved by template. Submit actual actor-case evidence results.'
union all
select 'sovereign_boundary', 'no_destructive_sql', true, 'Template only; no DDL/DML.';
