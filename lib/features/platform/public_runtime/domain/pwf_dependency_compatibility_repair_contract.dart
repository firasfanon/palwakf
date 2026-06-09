/// Platform Dependency Compatibility Repair contract for the
/// font_awesome_flutter IconData-final migration.
///
/// Scope:
/// - Runtime compilation compatibility with Flutter SDKs where IconData is final.
/// - font_awesome_flutter 11.x adoption.
/// - Source migration from FontAwesomeIcons-as-IconData to the v11-safe API.
///
/// Non-goals:
/// - No production approval.
/// - No SQL/DDL/DML/GRANT/DROP.
/// - No changes to Service Center ownership contracts.
/// - No mutation to waqf, waqf_assets, awqaf_system, or GIS.
class PwfDependencyCompatibilityRepairContract {
  const PwfDependencyCompatibilityRepairContract._();

  static const String patchKey =
      'platform_dependency_font_awesome_icondata_final_migration_2026_05_31';

  static const String dependency = 'font_awesome_flutter';
  static const String oldRuntimeBlockedVersion = '10.12.0';
  static const String targetConstraint = '^11.0.0';

  static const String blocker =
      'Flutter IconData is final; older font_awesome_flutter subclasses IconData and fails chrome compilation.';

  static const List<String> migratedSurfaces = <String>[
    'pubspec.yaml dependency constraint',
    'FontAwesomeIcons usages in public header/navigation/widgets',
    'FaIcon variable-call sites converted to IconData-safe Icon rendering',
    'FontAwesome literal-call sites preserved as FaIcon',
  ];

  static const List<String> preservedClosures = <String>[
    'Service Center runtime source closure preserved',
    'Public Services root cutover preserved',
    'Media Center scoped runtime closure preserved',
    'Prayer Times resilience preserved',
  ];

  static const List<String> forbiddenActions = <String>[
    'no production approval',
    'no SQL production change',
    'no DDL/DML/GRANT/DROP',
    'no deletion or archive',
    'no service_role in Flutter',
    'no waqf/waqf_assets/awqaf_system/GIS mutation',
  ];
}
