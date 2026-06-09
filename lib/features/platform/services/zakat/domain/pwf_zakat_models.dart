import 'package:flutter/foundation.dart';

enum PwfZakatTab { cash, trade, agriculture }

enum PwfAgricultureType { irrigated, rain }

enum PwfZakatDonationOption { poor, students, mosques, orphans }

@immutable
class PwfZakatReference {
  const PwfZakatReference({
    this.goldGramPriceIls = 180.0,
    this.cashNisabGoldGrams = 85.0,
    this.agricultureNisabKg = 653.0,
    this.cashAndTradeRate = 0.025,
    this.irrigatedAgricultureRate = 0.05,
    this.rainAgricultureRate = 0.10,
    this.currencyCode = 'ILS',
    this.officialSource = 'local-default-contract',
    this.isOfficialRuntimeSource = false,
  });

  final double goldGramPriceIls;
  final double cashNisabGoldGrams;
  final double agricultureNisabKg;
  final double cashAndTradeRate;
  final double irrigatedAgricultureRate;
  final double rainAgricultureRate;
  final String currencyCode;
  final String officialSource;
  final bool isOfficialRuntimeSource;

  double get cashNisabIls => cashNisabGoldGrams * goldGramPriceIls;

  bool sameValues(PwfZakatReference other) {
    return goldGramPriceIls == other.goldGramPriceIls &&
        cashNisabGoldGrams == other.cashNisabGoldGrams &&
        agricultureNisabKg == other.agricultureNisabKg &&
        cashAndTradeRate == other.cashAndTradeRate &&
        irrigatedAgricultureRate == other.irrigatedAgricultureRate &&
        rainAgricultureRate == other.rainAgricultureRate &&
        currencyCode == other.currencyCode &&
        officialSource == other.officialSource &&
        isOfficialRuntimeSource == other.isOfficialRuntimeSource;
  }
}

sealed class PwfZakatCalculation {
  const PwfZakatCalculation({
    required this.zakatAmount,
    required this.calculatedAt,
  });

  final double zakatAmount;
  final DateTime calculatedAt;

  PwfZakatTab get tab;
}

class PwfCashZakatCalculation extends PwfZakatCalculation {
  const PwfCashZakatCalculation({
    required super.zakatAmount,
    required super.calculatedAt,
    required this.amount,
    required this.debts,
    required this.netAmount,
    required this.nisabIls,
    required this.periodDays,
    required this.zakatPercentage,
  });

  final double amount;
  final double debts;
  final double netAmount;
  final double nisabIls;
  final int periodDays;
  final double zakatPercentage;

  @override
  PwfZakatTab get tab => PwfZakatTab.cash;
}

class PwfTradeZakatCalculation extends PwfZakatCalculation {
  const PwfTradeZakatCalculation({
    required super.zakatAmount,
    required super.calculatedAt,
    required this.goodsValue,
    required this.cashInHand,
    required this.receivables,
    required this.payables,
    required this.totalAssets,
    required this.netAssets,
    required this.nisabIls,
  });

  final double goodsValue;
  final double cashInHand;
  final double receivables;
  final double payables;

  final double totalAssets;
  final double netAssets;
  final double nisabIls;

  @override
  PwfZakatTab get tab => PwfZakatTab.trade;
}

class PwfAgricultureZakatCalculation extends PwfZakatCalculation {
  const PwfAgricultureZakatCalculation({
    required super.zakatAmount,
    required super.calculatedAt,
    required this.type,
    required this.quantityKg,
    required this.pricePerKg,
    required this.totalValue,
    required this.nisabKg,
    required this.zakatRate,
  });

  final PwfAgricultureType type;
  final double quantityKg;
  final double pricePerKg;
  final double totalValue;
  final double nisabKg;
  final double zakatRate;

  @override
  PwfZakatTab get tab => PwfZakatTab.agriculture;
}

enum PwfZakatCalcErrorCode {
  invalidAmount,
  invalidValues,
  belowNisabCash,
  belowNisabTrade,
  belowNisabAgriculture,
}

sealed class PwfZakatCalcOutcome {
  const PwfZakatCalcOutcome();
}

class PwfZakatCalcSuccess extends PwfZakatCalcOutcome {
  const PwfZakatCalcSuccess(this.calculation);
  final PwfZakatCalculation calculation;
}

class PwfZakatCalcError extends PwfZakatCalcOutcome {
  const PwfZakatCalcError({
    required this.code,
    this.args = const <String, Object?>{},
  });

  final PwfZakatCalcErrorCode code;
  final Map<String, Object?> args;
}
