abstract final class PwfTemporalOrdering {
  static int newestFirst(
    DateTime? a,
    DateTime? b, {
    Object? leftStableKey,
    Object? rightStableKey,
  }) {
    if (a == null && b == null) {
      if (leftStableKey != null && rightStableKey != null) {
        return leftStableKey.toString().compareTo(rightStableKey.toString());
      }
      return 0;
    }
    if (a == null) return 1;
    if (b == null) return -1;
    final cmp = b.compareTo(a);
    if (cmp != 0) return cmp;
    if (leftStableKey != null && rightStableKey != null) {
      return leftStableKey.toString().compareTo(rightStableKey.toString());
    }
    return 0;
  }

  static int oldestFirst(
    DateTime? a,
    DateTime? b, {
    Object? leftStableKey,
    Object? rightStableKey,
  }) =>
      newestFirst(b, a, leftStableKey: rightStableKey, rightStableKey: leftStableKey);
}
