
-- Read-only billing integration contract evidence.
select 'billing_integration_contract' as section,
       *
from public.v_zakat_billing_integration_contract_v1;

select 'billing_schema_presence' as section,
       'billing_system' as contract_name,
       exists(select 1 from information_schema.schemata where schema_name='billing_system') as present,
       'billing_system remains financial owner; no payment workflow is implemented by this Zakat ownership pack.' as note;
