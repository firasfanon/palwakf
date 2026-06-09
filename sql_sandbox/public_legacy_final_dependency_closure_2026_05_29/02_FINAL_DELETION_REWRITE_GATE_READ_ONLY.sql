select *
from (
  values
    ('public_media_legacy_tables', 'preserve', 'No deletion because previous census and classifier did not authorize deletion.'),
    ('public_services', 'preserve', 'Classified as navigation/service-entry catalog, not operational forms registry.'),
    ('public_home_services', 'preserve', 'Classified as homepage/navigation service surface.'),
    ('media_routine_rewrite', 'blocked', 'No exact runtime table dependency proven.'),
    ('service_runtime_rewrite', 'blocked', 'Mapping gap: 9 public services vs 6 operational forms.'),
    ('production_global', 'not_approved', 'Scoped closure only; global production still requires the separate production gate.')
) as t(gate_key, decision, note);
