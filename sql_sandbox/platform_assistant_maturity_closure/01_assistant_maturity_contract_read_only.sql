-- Platform Assistant Maturity Closure — read-only contract check
-- This script is intentionally SELECT-only.
-- It does not create/alter/drop tables, does not grant privileges, and does not
-- mutate auth.users, waqf, waqf_assets, awqaf_system, or assistant data.

with expected_contracts(check_key, expected_object) as (
  values
    ('assistant_schema_exists', 'assistant'),
    ('assistant_conversations_contract', 'assistant.assistant_conversations'),
    ('assistant_messages_contract', 'assistant.assistant_messages'),
    ('assistant_rag_documents_contract', 'assistant.assistant_rag_documents'),
    ('assistant_rag_chunks_contract', 'assistant.assistant_rag_chunks'),
    ('assistant_citations_contract', 'assistant.assistant_citations'),
    ('assistant_tool_invocations_contract', 'assistant.assistant_tool_invocations'),
    ('assistant_eval_runs_contract', 'assistant.assistant_eval_runs'),
    ('document_assistant_candidate_rpc', 'public.rpc_document_assistant_knowledge_candidate_v1')
), resolved as (
  select
    check_key,
    expected_object,
    case
      when expected_object = 'assistant'
        then exists(select 1 from information_schema.schemata where schema_name = 'assistant')
      when expected_object like 'public.rpc_%'
        then to_regprocedure(expected_object || '(uuid,text)') is not null
             or to_regprocedure(expected_object || '(text,text)') is not null
             or to_regprocedure(expected_object) is not null
      else to_regclass(expected_object) is not null
    end as passed
  from expected_contracts
)
select
  'platform_assistant_maturity_closure_read_only' as section,
  check_key,
  passed,
  expected_object,
  case
    when passed then 'present'
    else 'evidence_required_before_assistant_production_gate'
  end as note
from resolved
union all
select
  'sovereign_boundary' as section,
  'no_waq_assets_mutation_in_this_script' as check_key,
  true as passed,
  'waqf/waq_assets/awqaf_system/auth.users' as expected_object,
  'SELECT-only maturity contract check; no DML/DDL included.' as note;
