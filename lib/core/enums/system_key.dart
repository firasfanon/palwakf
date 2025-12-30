enum SystemKey {
  site,
  platformAdmin,
  mustakshif,
  adminData,
  lands,
  properties,
  cases,
  tasks,
  mosques,
  billing,
}

extension SystemKeyX on SystemKey {
  String get slug => switch (this) {
        SystemKey.site => 'site',
        SystemKey.platformAdmin => 'admin',
        SystemKey.mustakshif => 'mustakshif',
        SystemKey.adminData => 'admin-data',
        SystemKey.lands => 'lands',
        SystemKey.properties => 'properties',
        SystemKey.cases => 'cases',
        SystemKey.tasks => 'tasks',
        SystemKey.mosques => 'mosques',
        SystemKey.billing => 'billing',
      };
}
