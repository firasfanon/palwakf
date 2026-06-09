import 'pwf_zakat_models.dart';

/// Official public Zakat configuration contract for `/home/zakat`.
///
/// The production-facing source is the public compatibility wrapper
/// `public.v_zakat_public_config_v1`, backed by the sovereign `zakat` schema.
/// Local constants remain fallback values only when the `zakat` ownership
/// wrapper is not yet applied in a development environment.
class PwfZakatOfficialConfigContract {
  const PwfZakatOfficialConfigContract._();

  static const String canonicalRoute = '/home/zakat';
  static const String owner = 'zakat / zakat_public_config';
  static const String currentSource = 'public.v_zakat_public_config_v1';
  static const String targetSource = 'public.v_zakat_public_config_v1';
  static const String readiness =
      'zakat-schema-official-config-wrapper-declared-compile-contract-synchronized-browser-uat-required';
  static const String certificationGate =
      'تعتمد صفحة الزكاة إنتاجيًا بعد تطبيق wrapper/RPC الرسمي وفحص SQL/UAT، وتبقى القيم المحلية fallback للتطوير فقط.';

  static const double defaultGoldNisabGrams = 85;
  static const double defaultGoldGramPriceIls = 180;
  static const double defaultAgricultureNisabKg = 653;
  static const double cashAndTradeRate = 0.025;
  static const double irrigatedAgricultureRate = 0.05;
  static const double rainAgricultureRate = 0.10;

  static const List<String> visibleGuards = [
    'المسار الرسمي: /home/zakat',
    'المالك: zakat / zakat_public_config',
    'المصدر الرسمي المستهدف: public.v_zakat_public_config_v1 ← zakat.public_config',
    'القيم المحلية تستخدم fallback فقط عند عدم تطبيق wrapper في بيئة التطوير',
  ];

  static PwfZakatPublicConfig fallbackConfig() => const PwfZakatPublicConfig(
    goldNisabGrams: defaultGoldNisabGrams,
    goldGramPriceIls: defaultGoldGramPriceIls,
    agricultureNisabKg: defaultAgricultureNisabKg,
    cashAndTradeRate: cashAndTradeRate,
    irrigatedAgricultureRate: irrigatedAgricultureRate,
    rainAgricultureRate: rainAgricultureRate,
    currencyCode: 'ILS',
    source: 'local-fallback-after-zakat-schema-wrapper-contract',
    sourceLabelAr: 'قيم fallback محلية بعد عقد zakat schema الرسمي',
    isRuntimeOfficial: false,
  );
}

class PwfZakatPublicConfig {
  const PwfZakatPublicConfig({
    required this.goldNisabGrams,
    required this.goldGramPriceIls,
    required this.agricultureNisabKg,
    required this.cashAndTradeRate,
    required this.irrigatedAgricultureRate,
    required this.rainAgricultureRate,
    required this.currencyCode,
    required this.source,
    required this.sourceLabelAr,
    required this.isRuntimeOfficial,
    this.effectiveFrom,
    this.notesAr,
  });

  final double goldNisabGrams;
  final double goldGramPriceIls;
  final double agricultureNisabKg;
  final double cashAndTradeRate;
  final double irrigatedAgricultureRate;
  final double rainAgricultureRate;
  final String currencyCode;
  final String source;
  final String sourceLabelAr;
  final bool isRuntimeOfficial;
  final DateTime? effectiveFrom;
  final String? notesAr;

  factory PwfZakatPublicConfig.fromJson(Map<String, dynamic> json) {
    return PwfZakatPublicConfig(
      goldNisabGrams: _double(
        json['gold_nisab_grams'],
        PwfZakatOfficialConfigContract.defaultGoldNisabGrams,
      ),
      goldGramPriceIls: _double(
        json['gold_gram_price_ils'],
        PwfZakatOfficialConfigContract.defaultGoldGramPriceIls,
      ),
      agricultureNisabKg: _double(
        json['agriculture_nisab_kg'],
        PwfZakatOfficialConfigContract.defaultAgricultureNisabKg,
      ),
      cashAndTradeRate: _double(
        json['cash_and_trade_rate'],
        PwfZakatOfficialConfigContract.cashAndTradeRate,
      ),
      irrigatedAgricultureRate: _double(
        json['irrigated_agriculture_rate'],
        PwfZakatOfficialConfigContract.irrigatedAgricultureRate,
      ),
      rainAgricultureRate: _double(
        json['rain_agriculture_rate'],
        PwfZakatOfficialConfigContract.rainAgricultureRate,
      ),
      currencyCode: (json['currency_code'] ?? 'ILS').toString(),
      source: (json['source'] ?? PwfZakatOfficialConfigContract.currentSource)
          .toString(),
      sourceLabelAr: (json['source_label_ar'] ?? 'مصدر إعداد رسمي').toString(),
      isRuntimeOfficial: json['is_runtime_official'] == true,
      effectiveFrom: DateTime.tryParse(
        (json['effective_from'] ?? '').toString(),
      ),
      notesAr: json['notes_ar']?.toString(),
    );
  }

  static double _double(Object? value, double fallback) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  PwfZakatReference toReference() => PwfZakatReference(
    goldGramPriceIls: goldGramPriceIls,
    cashNisabGoldGrams: goldNisabGrams,
    agricultureNisabKg: agricultureNisabKg,
    cashAndTradeRate: cashAndTradeRate,
    irrigatedAgricultureRate: irrigatedAgricultureRate,
    rainAgricultureRate: rainAgricultureRate,
    currencyCode: currencyCode,
    officialSource: source,
    isOfficialRuntimeSource: isRuntimeOfficial,
  );
}

class PwfZakatOfficialConfigUatDecision {
  const PwfZakatOfficialConfigUatDecision._();

  static const String decision =
      'zakat-domain-ownership-realigned-compile-contract-synchronized-production-content-certification-pending-browser-uat';
  static const bool visualHarmonizationAccepted = true;
  static const bool calculationLogicChanged = false;
  static const bool donationWorkflowChanged = false;
  static const bool zakatSchemaOwnsConfig = true;
  static const bool billingSystemOwnsPaymentsReceiptsTransactions = true;
  static const bool platformServicesLimitedToPublicServiceRequests = true;
  static const bool publicSurfaceIsWrappersOnly = true;
  static const bool productionConfigWrapperPrepared = true;
  static const bool productionContentCertificationPendingSqlUat = true;
}

class PwfZakatDomainOwnershipDecision {
  const PwfZakatDomainOwnershipDecision._();

  static const String decision =
      'zakat-schema-owns-operational-zakat-rules-billing-system-owns-financial-events';
  static const String zakatOwner = 'zakat';
  static const String billingOwner = 'billing_system';
  static const String platformServicesRole =
      'public-service-request-interface-only';
  static const String publicRole = 'wrappers-rpc-views-only';
  static const bool previousPlatformServicesConfigSqlSuperseded = true;
  static const bool paymentWorkflowImplementedInThisBatch = false;
}
