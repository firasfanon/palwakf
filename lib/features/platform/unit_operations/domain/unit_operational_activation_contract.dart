class UnitOperationalActivationState {
  final String unitId;
  final String slug;
  final String unitNameAr;
  final bool isPubliclyEligible;

  const UnitOperationalActivationState({
    required this.unitId,
    required this.slug,
    required this.unitNameAr,
    this.isPubliclyEligible = false,
  });
}

class UnitOperationalActivationContract {
  final String unitId;
  final bool isActive;

  const UnitOperationalActivationContract({
    required this.unitId,
    this.isActive = false,
  });
}
