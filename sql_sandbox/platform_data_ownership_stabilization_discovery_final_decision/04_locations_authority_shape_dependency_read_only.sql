select 'locations_authority_presence' as section, * from (
  values
    ('core.org_units', to_regclass('core.org_units') is not null, 'administrative/unit authority'),
    ('public.org_units', to_regclass('public.org_units') is not null, 'compatibility surface only'),
    ('gis.locations', to_regclass('gis.locations') is not null, 'spatial authority candidate'),
    ('public.locations', to_regclass('public.locations') is not null, 'legacy/public candidate requiring review'),
    ('gis.lgus_boundary', to_regclass('gis.lgus_boundary') is not null, 'LGU geometry/source for spatial filtering'),
    ('gis.governorates_boundary', to_regclass('gis.governorates_boundary') is not null, 'governorate geometry/source for spatial filtering')
) as t(contract_name, present, proposed_role)
union all
select 'locations_authority_decision', 'decision' as contract_name, true as present,
       'core owns administrative org-unit identity; gis owns geometry/spatial locations; public must expose wrappers/views only, not sovereign storage' as proposed_role;
