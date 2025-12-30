extension DateTimeExtensions on DateTime {
  // Arabic month names
  static const Map<int, String> _arabicMonths = {
    1: 'يناير',
    2: 'فبراير',
    3: 'مارس',
    4: 'أبريل',
    5: 'مايو',
    6: 'يونيو',
    7: 'يوليو',
    8: 'أغسطس',
    9: 'سبتمبر',
    10: 'أكتوبر',
    11: 'نوفمبر',
    12: 'ديسمبر',
  };

  // Arabic day names
  static const Map<int, String> _arabicDays = {
    1: 'الاثنين',
    2: 'الثلاثاء',
    3: 'الأربعاء',
    4: 'الخميس',
    5: 'الجمعة',
    6: 'السبت',
    7: 'الأحد',
  };

  // Get Arabic month name
  String get arabicMonth => _arabicMonths[month] ?? '';

  // Get Arabic day name
  String get arabicDay => _arabicDays[weekday] ?? '';

  // Format in Arabic
  String get arabicFormat => '$day $arabicMonth $year';

  // Format with Arabic day
  String get arabicFullFormat => '$arabicDay، $day $arabicMonth $year';

  // Time in Arabic format
  String get arabicTime {
    final period = hour >= 12 ? 'م' : 'ص';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  // Full Arabic date and time
  String get arabicDateTime => '$arabicFormat - $arabicTime';

  // Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  // Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  // Check if date is tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year && month == tomorrow.month && day == tomorrow.day;
  }

  // Check if date is this week
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  // Check if date is this month
  bool get isThisMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }

  // Check if date is this year
  bool get isThisYear {
    final now = DateTime.now();
    return year == now.year;
  }

  // Get time ago in Arabic
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? 'منذ سنة' : 'منذ $years سنوات';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? 'منذ شهر' : 'منذ $months أشهر';
    } else if (difference.inDays > 0) {
      return difference.inDays == 1 ? 'منذ يوم' : 'منذ ${difference.inDays} أيام';
    } else if (difference.inHours > 0) {
      return difference.inHours == 1 ? 'منذ ساعة' : 'منذ ${difference.inHours} ساعات';
    } else if (difference.inMinutes > 0) {
      return difference.inMinutes == 1 ? 'منذ دقيقة' : 'منذ ${difference.inMinutes} دقائق';
    } else {
      return 'الآن';
    }
  }

  // Get time remaining in Arabic
  String get timeRemaining {
    final now = DateTime.now();
    final difference = this.difference(now);

    if (difference.isNegative) {
      return 'انتهى';
    }

    if (difference.inDays > 0) {
      return difference.inDays == 1 ? 'يوم واحد' : '${difference.inDays} أيام';
    } else if (difference.inHours > 0) {
      return difference.inHours == 1 ? 'ساعة واحدة' : '${difference.inHours} ساعات';
    } else if (difference.inMinutes > 0) {
      return difference.inMinutes == 1 ? 'دقيقة واحدة' : '${difference.inMinutes} دقائق';
    } else {
      return 'أقل من دقيقة';
    }
  }

  // Get start of day
  DateTime get startOfDay => DateTime(year, month, day);

  // Get end of day
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  // Get start of week (Monday)
  DateTime get startOfWeek {
    final daysFromMonday = weekday - 1;
    return subtract(Duration(days: daysFromMonday)).startOfDay;
  }

  // Get end of week (Sunday)
  DateTime get endOfWeek {
    final daysToSunday = 7 - weekday;
    return add(Duration(days: daysToSunday)).endOfDay;
  }

  // Get start of month
  DateTime get startOfMonth => DateTime(year, month, 1);

  // Get end of month
  DateTime get endOfMonth => DateTime(year, month + 1, 0, 23, 59, 59, 999);

  // Get start of year
  DateTime get startOfYear => DateTime(year, 1, 1);

  // Get end of year
  DateTime get endOfYear => DateTime(year, 12, 31, 23, 59, 59, 999);

  // Check if date is weekend (Friday or Saturday in Arab countries)
  bool get isWeekend => weekday == DateTime.friday || weekday == DateTime.saturday;

  // Check if date is workday
  bool get isWorkday => !isWeekend;

  // Get age from birthdate
  int get age {
    final now = DateTime.now();
    int age = now.year - year;

    if (now.month < month || (now.month == month && now.day < day)) {
      age--;
    }

    return age;
  }

  // Get days until this date
  int get daysUntil {
    final now = DateTime.now().startOfDay;
    final target = startOfDay;
    return target.difference(now).inDays;
  }

  // Get days since this date
  int get daysSince {
    final now = DateTime.now().startOfDay;
    final target = startOfDay;
    return now.difference(target).inDays;
  }

  // Check if date is in the future
  bool get isFuture => isAfter(DateTime.now());

  // Check if date is in the past
  bool get isPast => isBefore(DateTime.now());

  // Get quarter of the year (1-4)
  int get quarter {
    return ((month - 1) / 3).floor() + 1;
  }

  // Get week number of the year
  int get weekOfYear {
    final startOfYear = DateTime(year, 1, 1);
    final dayOfYear = difference(startOfYear).inDays + 1;
    return ((dayOfYear - weekday + 10) / 7).floor();
  }

  // Get day of year (1-365/366)
  int get dayOfYear {
    final startOfYear = DateTime(year, 1, 1);
    return difference(startOfYear).inDays + 1;
  }

  // Check if year is leap year
  bool get isLeapYear {
    return (year % 4 == 0) && (year % 100 != 0) || (year % 400 == 0);
  }

  // Get number of days in month
  int get daysInMonth {
    return DateTime(year, month + 1, 0).day;
  }

  // Add business days (excluding weekends)
  DateTime addBusinessDays(int days) {
    DateTime result = this;
    int addedDays = 0;

    while (addedDays < days) {
      result = result.add(const Duration(days: 1));
      if (result.isWorkday) {
        addedDays++;
      }
    }

    return result;
  }

  // Subtract business days
  DateTime subtractBusinessDays(int days) {
    DateTime result = this;
    int subtractedDays = 0;

    while (subtractedDays < days) {
      result = result.subtract(const Duration(days: 1));
      if (result.isWorkday) {
        subtractedDays++;
      }
    }

    return result;
  }

  // Get next business day
  DateTime get nextBusinessDay {
    DateTime next = add(const Duration(days: 1));
    while (next.isWeekend) {
      next = next.add(const Duration(days: 1));
    }
    return next;
  }

  // Get previous business day
  DateTime get previousBusinessDay {
    DateTime previous = subtract(const Duration(days: 1));
    while (previous.isWeekend) {
      previous = previous.subtract(const Duration(days: 1));
    }
    return previous;
  }

  // Get next occurrence of a specific weekday
  DateTime nextWeekday(int weekday) {
    int daysToAdd = (weekday - this.weekday) % 7;
    if (daysToAdd == 0) daysToAdd = 7; // Next week if same day
    return add(Duration(days: daysToAdd));
  }

  // Get previous occurrence of a specific weekday
  DateTime previousWeekday(int weekday) {
    int daysToSubtract = (this.weekday - weekday) % 7;
    if (daysToSubtract == 0) daysToSubtract = 7; // Previous week if same day
    return subtract(Duration(days: daysToSubtract));
  }

  // Format for different contexts
  String get shortFormat => '$day/${month.toString().padLeft(2, '0')}/$year';
  String get mediumFormat => '$day ${_arabicMonths[month]} $year';
  String get longFormat => '$arabicDay، $day ${_arabicMonths[month]} $year';

  // Islamic calendar approximation (simplified)
  String get islamicDate {
    // Simplified Hijri conversion for display purposes
    final daysSinceEpoch = difference(DateTime(622, 7, 16)).inDays;
    final hijriYear = (daysSinceEpoch / 354.367).floor() + 1;
    final hijriMonth = ((daysSinceEpoch % 354.367) / 29.531).floor() + 1;
    final hijriDay = ((daysSinceEpoch % 354.367) % 29.531).floor() + 1;

    return '$hijriDay/$hijriMonth/$hijriYear هـ';
  }

  // Check if same date (ignoring time)
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  // Check if same week
  bool isSameWeek(DateTime other) {
    final thisWeekStart = startOfWeek;
    final otherWeekStart = other.startOfWeek;
    return thisWeekStart.isSameDate(otherWeekStart);
  }

  // Check if same month
  bool isSameMonth(DateTime other) {
    return year == other.year && month == other.month;
  }

  // Check if same year
  bool isSameYear(DateTime other) {
    return year == other.year;
  }

  // Get time difference in a readable format
  String timeDifference(DateTime other) {
    final difference = this.difference(other).abs();

    if (difference.inDays > 0) {
      return '${difference.inDays} يوم';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ساعة';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} دقيقة';
    } else {
      return '${difference.inSeconds} ثانية';
    }
  }

  // Get prayer time context (approximate)
  String get prayerTimeContext {
    final hourOfDay = hour;

    if (hourOfDay >= 5 && hourOfDay < 6) return 'وقت الفجر';
    if (hourOfDay >= 6 && hourOfDay < 12) return 'الضحى';
    if (hourOfDay >= 12 && hourOfDay < 15) return 'وقت الظهر';
    if (hourOfDay >= 15 && hourOfDay < 18) return 'وقت العصر';
    if (hourOfDay >= 18 && hourOfDay < 20) return 'وقت المغرب';
    if (hourOfDay >= 20 || hourOfDay < 5) return 'وقت العشاء';

    return 'النهار';
  }

  // Copy with new values
  DateTime copyWith({
    int? year,
    int? month,
    int? day,
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    int? microsecond,
  }) {
    return DateTime(
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
      millisecond ?? this.millisecond,
      microsecond ?? this.microsecond,
    );
  }

  // Check if between two dates
  bool isBetween(DateTime start, DateTime end) {
    return isAfter(start) && isBefore(end);
  }

  // Get closest date from a list of dates
  DateTime? closestFrom(List<DateTime> dates) {
    if (dates.isEmpty) return null;

    DateTime closest = dates.first;
    Duration smallestDifference = difference(closest).abs();

    for (final date in dates.skip(1)) {
      final diff = difference(date).abs();
      if (diff < smallestDifference) {
        closest = date;
        smallestDifference = diff;
      }
    }

    return closest;
  }

  // Format for API/JSON
  String get apiFormat => toIso8601String();

  // Format for display in different contexts
  String formatForContext(String context) {
    switch (context.toLowerCase()) {
      case 'short':
        return shortFormat;
      case 'medium':
        return mediumFormat;
      case 'long':
        return longFormat;
      case 'time':
        return arabicTime;
      case 'datetime':
        return arabicDateTime;
      case 'islamic':
        return islamicDate;
      case 'relative':
        return timeAgo;
      default:
        return arabicFormat;
    }
  }
}

// Extension for nullable DateTime
extension NullableDateTimeExtensions on DateTime? {
  bool get isNull => this == null;
  bool get isNotNull => this != null;

  String get timeAgoOrEmpty => this?.timeAgo ?? '';
  String get arabicFormatOrEmpty => this?.arabicFormat ?? '';

  DateTime orNow() => this ?? DateTime.now();
  DateTime orDefault(DateTime defaultDate) => this ?? defaultDate;
}