-- Database Wave B-0C — Runtime Dependency Validation
-- 03_public_facade_dependency_preservation_read_only.sql
-- Purpose: confirm public facade contracts that must remain public/versioned.
-- Read-only. No DDL/DML.

with facades as (
  select * from (values
    ('v_platform_system_registry','platform_core_registry_facade'),
    ('v_platform_system_sections','platform_core_sections_facade'),
    ('v_platform_center_content','platform_content_public_facade'),
    ('v_public_waqf_assets','waqf_assets_public_read_facade'),
    ('org_units','core_org_units_compatibility_facade'),
    ('org_unit_profiles','core_org_unit_profiles_compatibility_facade')
  ) as f(object_name,contract_role)
)
select
  'public_facade_dependency_preservation' as section,
  f.object_name,
  f.contract_role,
  to_regclass('public.' || f.object_name) is not null as public_contract_exists,
  case
    when to_regclass('public.' || f.object_name) is not null then 'preserve_public_facade_or_version_contract'
    else 'missing_contract_review_required'
  end as b0c_decision
from facades f
order by object_name;
