enum TaskLinkType { waqfAsset, caseFile, lease, invoice, unit, activity }

extension TaskLinkTypeX on TaskLinkType {
  String get dbValue => switch (this) {
    TaskLinkType.waqfAsset => 'waqf_asset',
    TaskLinkType.caseFile => 'case',
    TaskLinkType.lease => 'lease',
    TaskLinkType.invoice => 'invoice',
    TaskLinkType.unit => 'unit',
    TaskLinkType.activity => 'activity',
  };

  String get labelAr => switch (this) {
    TaskLinkType.waqfAsset => 'أصل وقفي',
    TaskLinkType.caseFile => 'قضية',
    TaskLinkType.lease => 'عقد',
    TaskLinkType.invoice => 'فاتورة',
    TaskLinkType.unit => 'وحدة',
    TaskLinkType.activity => 'نشاط',
  };

  String get sourceSystem => switch (this) {
    TaskLinkType.waqfAsset => 'awqaf_system',
    TaskLinkType.caseFile => 'waqf_cases_system',
    TaskLinkType.lease => 'billing_system',
    TaskLinkType.invoice => 'billing_system',
    TaskLinkType.unit => 'awqaf_system',
    TaskLinkType.activity => 'activity_system',
  };

  static TaskLinkType fromDb(dynamic value) {
    switch ('$value') {
      case 'waqf_asset':
        return TaskLinkType.waqfAsset;
      case 'case':
        return TaskLinkType.caseFile;
      case 'lease':
        return TaskLinkType.lease;
      case 'invoice':
        return TaskLinkType.invoice;
      case 'unit':
        return TaskLinkType.unit;
      case 'activity':
        return TaskLinkType.activity;
      default:
        return TaskLinkType.waqfAsset;
    }
  }
}
