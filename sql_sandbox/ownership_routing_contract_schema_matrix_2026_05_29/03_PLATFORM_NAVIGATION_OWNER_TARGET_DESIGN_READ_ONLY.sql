select *
from (values
  ('platform_navigation','route_entries','canonical registry for public/admin route entries','design_only_not_created'),
  ('platform_navigation','service_entries','replacement owner for public.services','design_only_not_created'),
  ('platform_navigation','home_entries','replacement owner for public.home_services','design_only_not_created'),
  ('platform_navigation','navigation_sections','sidebar/homepage grouping and display order','design_only_not_created')
) as t(recommended_schema, recommended_table, purpose, status)
order by recommended_table;
