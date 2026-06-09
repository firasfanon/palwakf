import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pwf_zakat_calculator_notifier.dart';

final pwfZakatCalculatorProvider =
    StateNotifierProvider<PwfZakatCalculatorNotifier, PwfZakatCalculatorState>(
      (ref) => PwfZakatCalculatorNotifier(),
    );
