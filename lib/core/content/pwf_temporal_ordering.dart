abstract final class PwfTemporalOrdering {
  static int newestFirst(DateTime? a, DateTime? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    return b.compareTo(a);
  }

  static int oldestFirst(DateTime? a, DateTime? b) => newestFirst(b, a);
}
