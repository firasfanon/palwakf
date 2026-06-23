import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/unit_operational_activation_contract.dart';

final unitOperationalActivationProvider =
    FutureProvider.family<UnitOperationalActivationContract?, String>(
  (ref, unitId) async {
    return UnitOperationalActivationContract(unitId: unitId);
  },
);

final unitOperationalActivationStatesProvider =
    FutureProvider<List<UnitOperationalActivationState>>((ref) async {
  return const <UnitOperationalActivationState>[];
});
