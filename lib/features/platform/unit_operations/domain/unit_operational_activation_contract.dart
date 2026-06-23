class UnitOperationalActivationContract {
  final String unitId;
  final bool isActive;

  const UnitOperationalActivationContract({
    required this.unitId,
    this.isActive = false,
  });
}
