class PwfHijriDate {
  final int day;
  final int month; // 1..12
  final int year;

  const PwfHijriDate({
    required this.day,
    required this.month,
    required this.year,
  });
}

/// Tabular Islamic calendar (approx) — بدون حزم خارجية.
class PwfHijriConverter {
  static PwfHijriDate fromGregorian(DateTime date) {
    final d = DateTime.utc(date.year, date.month, date.day);

    // Julian Day Number (Gregorian)
    final a = ((14 - d.month) / 12).floor();
    final y = d.year + 4800 - a;
    final m = d.month + 12 * a - 3;

    final jdn =
        d.day +
        ((153 * m + 2) / 5).floor() +
        365 * y +
        (y / 4).floor() -
        (y / 100).floor() +
        (y / 400).floor() -
        32045;

    const int islamicEpoch = 1948439; // approx
    final daysSinceEpoch = jdn - islamicEpoch;

    final islamicYear = ((30 * daysSinceEpoch + 10646) / 10631).floor();
    final yearStart = _islamicToJdn(islamicYear, 1, 1);
    var dayOfYear = jdn - yearStart + 1;

    int islamicMonth = 1;
    while (islamicMonth <= 12) {
      final monthLength = _islamicMonthLength(islamicYear, islamicMonth);
      if (dayOfYear <= monthLength) break;
      dayOfYear -= monthLength;
      islamicMonth++;
    }

    return PwfHijriDate(day: dayOfYear, month: islamicMonth, year: islamicYear);
  }

  static int _islamicToJdn(int year, int month, int day) {
    final y = year - 1;
    final monthsDays = ((month - 1) * 29.5).ceil();
    return day +
        monthsDays +
        354 * y +
        ((3 + 11 * year) / 30).floor() +
        1948439 -
        1;
  }

  static int _islamicMonthLength(int year, int month) {
    if (month == 12) {
      return _islamicLeapYear(year) ? 30 : 29;
    }
    return (month % 2 == 1) ? 30 : 29;
  }

  static bool _islamicLeapYear(int year) {
    final mod = year % 30;
    const leapMods = <int>{2, 5, 7, 10, 13, 16, 18, 21, 24, 26, 29};
    return leapMods.contains(mod);
  }
}
