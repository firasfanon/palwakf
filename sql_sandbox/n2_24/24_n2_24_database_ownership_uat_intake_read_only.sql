-- N2.24 read-only UAT intake skeleton
-- No mutation.

select *
from (
  values
    ('inventory','schema_inventory_decisions_exists', true, 'Accepted from user-submitted N2.23 UAT evidence'),
    ('views','public_org_units_uses_core', true, 'Accepted from user-submitted N2.23 UAT evidence'),
    ('views','public_org_units_not_cache_backed', true, 'Accepted from user-submitted N2.23 UAT evidence'),
    ('views','public_org_units_unit_type_text_contract', true, 'Accepted from user-submitted N2.23 UAT evidence'),
    ('rpc','rpc_org_units_core_lookup_v1_exists', true, 'Accepted from user-submitted N2.23 UAT evidence'),
    ('sovereign_boundary','no_waq_assets_mutation_in_this_script', true, 'Read-only intake only')
) as t(section, check_key, passed, note);
