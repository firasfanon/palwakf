import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/pwf_zakat_models.dart';

@immutable
class PwfZakatCalculatorState {
  const PwfZakatCalculatorState({
    this.tab = PwfZakatTab.cash,
    this.calculation,
    this.selectedDonationOption,
    this.reference = const PwfZakatReference(),
  });

  final PwfZakatTab tab;
  final PwfZakatCalculation? calculation;
  final PwfZakatDonationOption? selectedDonationOption;
  final PwfZakatReference reference;

  PwfZakatCalculatorState copyWith({
    PwfZakatTab? tab,
    PwfZakatCalculation? calculation,
    bool clearCalculation = false,
    PwfZakatDonationOption? selectedDonationOption,
    bool clearDonationOption = false,
    PwfZakatReference? reference,
  }) {
    return PwfZakatCalculatorState(
      tab: tab ?? this.tab,
      calculation: clearCalculation ? null : (calculation ?? this.calculation),
      selectedDonationOption: clearDonationOption
          ? null
          : (selectedDonationOption ?? this.selectedDonationOption),
      reference: reference ?? this.reference,
    );
  }
}

class PwfZakatCalculatorNotifier
    extends StateNotifier<PwfZakatCalculatorState> {
  PwfZakatCalculatorNotifier() : super(const PwfZakatCalculatorState());

  void selectTab(PwfZakatTab tab) {
    state = state.copyWith(tab: tab);
  }

  void reset() {
    state = state.copyWith(clearCalculation: true, clearDonationOption: true);
  }

  void updateReference(PwfZakatReference reference) {
    if (state.reference.sameValues(reference)) return;
    state = state.copyWith(reference: reference, clearCalculation: true);
  }

  void selectDonationOption(PwfZakatDonationOption option) {
    state = state.copyWith(selectedDonationOption: option);
  }

  PwfZakatCalcOutcome calculateCash({
    required double amount,
    required double debts,
    required int periodDays,
  }) {
    if (amount <= 0) {
      return const PwfZakatCalcError(code: PwfZakatCalcErrorCode.invalidAmount);
    }

    final net = amount - debts;
    final nisab = state.reference.cashNisabIls;

    if (net < nisab) {
      return PwfZakatCalcError(
        code: PwfZakatCalcErrorCode.belowNisabCash,
        args: <String, Object?>{'nisab': nisab},
      );
    }

    final percentage = state.reference.cashAndTradeRate * (periodDays / 365.0);
    final zakat = net * percentage;

    final calc = PwfCashZakatCalculation(
      zakatAmount: zakat,
      calculatedAt: DateTime.now(),
      amount: amount,
      debts: debts,
      netAmount: net,
      nisabIls: nisab,
      periodDays: periodDays,
      zakatPercentage: percentage,
    );

    state = state.copyWith(calculation: calc);
    return PwfZakatCalcSuccess(calc);
  }

  PwfZakatCalcOutcome calculateTrade({
    required double goodsValue,
    required double cashInHand,
    required double receivables,
    required double payables,
  }) {
    final total = goodsValue + cashInHand + receivables;
    if (total <= 0) {
      return const PwfZakatCalcError(code: PwfZakatCalcErrorCode.invalidValues);
    }

    final net = total - payables;
    final nisab = state.reference.cashNisabIls;

    if (net < nisab) {
      return PwfZakatCalcError(
        code: PwfZakatCalcErrorCode.belowNisabTrade,
        args: <String, Object?>{'nisab': nisab},
      );
    }

    final zakat = net * state.reference.cashAndTradeRate;

    final calc = PwfTradeZakatCalculation(
      zakatAmount: zakat,
      calculatedAt: DateTime.now(),
      goodsValue: goodsValue,
      cashInHand: cashInHand,
      receivables: receivables,
      payables: payables,
      totalAssets: total,
      netAssets: net,
      nisabIls: nisab,
    );

    state = state.copyWith(calculation: calc);
    return PwfZakatCalcSuccess(calc);
  }

  PwfZakatCalcOutcome calculateAgriculture({
    required PwfAgricultureType type,
    required double quantityKg,
    required double pricePerKg,
  }) {
    if (quantityKg <= 0 || pricePerKg <= 0) {
      return const PwfZakatCalcError(code: PwfZakatCalcErrorCode.invalidValues);
    }

    final nisabKg = state.reference.agricultureNisabKg;
    if (quantityKg < nisabKg) {
      return PwfZakatCalcError(
        code: PwfZakatCalcErrorCode.belowNisabAgriculture,
        args: <String, Object?>{'nisabKg': nisabKg},
      );
    }

    final totalValue = quantityKg * pricePerKg;
    final rate = type == PwfAgricultureType.rain
        ? state.reference.rainAgricultureRate
        : state.reference.irrigatedAgricultureRate;
    final zakat = totalValue * rate;

    final calc = PwfAgricultureZakatCalculation(
      zakatAmount: zakat,
      calculatedAt: DateTime.now(),
      type: type,
      quantityKg: quantityKg,
      pricePerKg: pricePerKg,
      totalValue: totalValue,
      nisabKg: nisabKg,
      zakatRate: rate,
    );

    state = state.copyWith(calculation: calc);
    return PwfZakatCalcSuccess(calc);
  }
}
