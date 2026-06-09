-- Database Wave B-1A Media Bootstrap Draft Pack
-- 03_media_editorial_workflow_contract_draft_readiness.sql
-- READ ONLY. No DDL/DML.

with workflow_states(state_key, state_order, public_visible, terminal_state) as (
  values
    ('draft', 10, false, false),
    ('in_review', 20, false, false),
    ('approved', 30, false, false),
    ('scheduled', 40, false, false),
    ('published', 50, true, false),
    ('archived', 60, false, true),
    ('rejected', 70, false, true)
), transitions(from_state, action_key, to_state, actor_scope) as (
  values
    ('draft', 'submit_review', 'in_review', 'media_editor'),
    ('in_review', 'approve', 'approved', 'media_approver'),
    ('in_review', 'reject', 'rejected', 'media_approver'),
    ('approved', 'schedule', 'scheduled', 'media_publisher'),
    ('approved', 'publish', 'published', 'media_publisher'),
    ('scheduled', 'publish', 'published', 'media_publisher'),
    ('published', 'archive', 'archived', 'media_publisher')
)
select
  'media_editorial_workflow_contract_draft' as section,
  ws.state_key,
  ws.state_order,
  ws.public_visible,
  ws.terminal_state,
  coalesce(jsonb_agg(jsonb_build_object(
    'action_key', tr.action_key,
    'to_state', tr.to_state,
    'actor_scope', tr.actor_scope
  ) order by tr.action_key) filter (where tr.action_key is not null), '[]'::jsonb) as allowed_transitions,
  'draft_contract_only_not_applied' as b1a_media_decision
from workflow_states ws
left join transitions tr on tr.from_state = ws.state_key
group by ws.state_key, ws.state_order, ws.public_visible, ws.terminal_state
order by ws.state_order;
