/// PalWakf Billing System financial contract bootstrap.
///
/// This is a readiness-only contract. It is intentionally not a payment
/// workflow and must not be used to issue receipts, post transactions, or
/// integrate a payment gateway before a dedicated billing implementation batch.
class PwfBillingSystemFinancialContract {
  const PwfBillingSystemFinancialContract._();

  static const String schema = 'billing_system';
  static const String publicZakatReadinessView =
      'public.v_billing_zakat_payment_readiness_v1';
  static const String publicZakatReadinessRpc =
      'public.rpc_billing_zakat_payment_readiness_v1()';

  static const bool ownsPaymentIntents = true;
  static const bool ownsReceipts = true;
  static const bool ownsTransactions = true;
  static const bool ownsZakatRules = false;
  static const bool ownsZakatConfig = false;
  static const bool paymentGatewayEnabled = false;
  static const bool receiptIssuanceEnabled = false;
  static const bool transactionPostingEnabled = false;
  static const bool productionFinancialApprovalGranted = false;

  static const List<String> ownershipBoundaries = [
    'billing_system owns future payment intents, receipts, transactions, refunds, settlements, and reconciliation',
    'zakat owns operational Zakat rules, nisab, rates, guidance, and public configuration',
    'platform_services owns public request/service interface only',
    'public exposes read-only wrappers/RPCs only',
  ];
}

class PwfZakatPaymentReadinessBridgeContract {
  const PwfZakatPaymentReadinessBridgeContract._();

  static const String sourceDomain = 'zakat';
  static const String sourceConfig = 'zakat.public_config';
  static const String financialOwner = 'billing_system';
  static const String readinessStatus = 'readiness_only';
  static const bool canCreatePaymentIntent = false;
  static const bool canIssueReceipt = false;
  static const bool canPostTransaction = false;
}
