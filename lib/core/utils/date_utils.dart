import 'package:intl/intl.dart';

class AppDateUtils {
  // Arabic month names
  static const List<String> arabicMonths = [
    'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
  ];

  // Arabic day names
  static const List<String> arabicDays = [
    'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'
  ];

  // Islamic month names
  static const List<String> islamicMonths = [
    'محرم', 'صفر', 'ربيع الأول', 'ربيع الآخر', 'جمادى الأولى', 'جمادى الآخرة',
    'رجب', 'شعبان', 'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة'
  ];

  // Arabic number mapping
  static const Map<String, String> arabicNumerals = {
    '0': '٠', '1': '١', '2': '٢', '3': '٣', '4': '٤',
    '5': '٥', '6': '٦', '7': '٧', '8': '٨', '9': '٩'
  };

  /// Format date in Arabic format: "الثلاثاء، ١٥ يناير ٢٠٢٤"
  static String formatArabicDate(DateTime date) {
    final dayName = arabicDays[date.weekday - 1];
    final day = _toArabicNumerals(date.day.toString());
    final monthName = arabicMonths[date.month - 1];
    final year = _toArabicNumerals(date.year.toString());

    return '$dayName، $day $monthName $year';
  }

  /// Alias used across the app for a standard date label.
  /// Currently mapped to short Arabic format for consistency.
  static String formatDate(DateTime date) => formatShortArabicDate(date);

  /// Format date in short Arabic format: "١٥/١/٢٠٢٤"
  static String formatShortArabicDate(DateTime date) {
    final day = _toArabicNumerals(date.day.toString());
    final month = _toArabicNumerals(date.month.toString());
    final year = _toArabicNumerals(date.year.toString());

    return '$day/$month/$year';
  }

  /// Format time in Arabic format: "٢:٣٠ مساءً"
  static String formatArabicTime(DateTime date) {
    final hour = date.hour;
    final minute = date.minute;

    String period;
    int displayHour;

    if (hour == 0) {
      displayHour = 12;
      period = 'صباحاً';
    } else if (hour < 12) {
      displayHour = hour;
      period = 'صباحاً';
    } else if (hour == 12) {
      displayHour = 12;
      period = 'ظهراً';
    } else {
      displayHour = hour - 12;
      period = 'مساءً';
    }

    final hourStr = _toArabicNumerals(displayHour.toString());
    final minuteStr = _toArabicNumerals(minute.toString().padLeft(2, '0'));

    return '$hourStr:$minuteStr $period';
  }

  /// Format date and time in Arabic: "الثلاثاء، ١٥ يناير ٢٠٢٤ - ٢:٣٠ مساءً"
  static String formatArabicDateTime(DateTime date) {
    return '${formatArabicDate(date)} - ${formatArabicTime(date)}';
  }

  /// Get relative time in Arabic (e.g., "منذ ساعتين", "قبل يوم")
  static String getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return 'منذ ${_toArabicNumerals(minutes.toString())} ${_getPluralForm(minutes, 'دقيقة', 'دقيقتين', 'دقائق')}';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return 'منذ ${_toArabicNumerals(hours.toString())} ${_getPluralForm(hours, 'ساعة', 'ساعتين', 'ساعات')}';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return 'منذ ${_toArabicNumerals(days.toString())} ${_getPluralForm(days, 'يوم', 'يومين', 'أيام')}';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'منذ ${_toArabicNumerals(weeks.toString())} ${_getPluralForm(weeks, 'أسبوع', 'أسبوعين', 'أسابيع')}';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return 'منذ ${_toArabicNumerals(months.toString())} ${_getPluralForm(months, 'شهر', 'شهرين', 'أشهر')}';
    } else {
      final years = (difference.inDays / 365).floor();
      return 'منذ ${_toArabicNumerals(years.toString())} ${_getPluralForm(years, 'سنة', 'سنتين', 'سنوات')}';
    }
  }

  /// Get remaining time in Arabic (e.g., "باقي ساعتين", "ينتهي خلال يوم")
  static String getTimeRemaining(DateTime futureDate) {
    final now = DateTime.now();
    final difference = futureDate.difference(now);

    if (difference.isNegative) {
      return 'انتهى';
    }

    if (difference.inSeconds < 60) {
      return 'باقي ثوانٍ';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return 'باقي ${_toArabicNumerals(minutes.toString())} ${_getPluralForm(minutes, 'دقيقة', 'دقيقتين', 'دقائق')}';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return 'باقي ${_toArabicNumerals(hours.toString())} ${_getPluralForm(hours, 'ساعة', 'ساعتين', 'ساعات')}';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return 'باقي ${_toArabicNumerals(days.toString())} ${_getPluralForm(days, 'يوم', 'يومين', 'أيام')}';
    } else {
      final weeks = (difference.inDays / 7).floor();
      return 'باقي ${_toArabicNumerals(weeks.toString())} ${_getPluralForm(weeks, 'أسبوع', 'أسبوعين', 'أسابيع')}';
    }
  }

  /// Format Islamic Hijri date
  static String formatHijriDate(DateTime date) {
    // This is a simplified implementation
    // In a real app, you would use a proper Hijri calendar library
    final islamicYear = ((date.year - 622) * 365.25 / 354.37).floor() + 1;
    final monthIndex = (date.month + 5) % 12; // Simplified calculation

    return '${_toArabicNumerals(date.day.toString())} ${islamicMonths[monthIndex]} ${_toArabicNumerals(islamicYear.toString())} هـ';
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  /// Check if date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  /// Check if date is this week
  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// Get start of day
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Get start of week (Monday)
  static DateTime startOfWeek(DateTime date) {
    final startOfDay = AppDateUtils.startOfDay(date);
    return startOfDay.subtract(Duration(days: date.weekday - 1));
  }

  /// Get end of week (Sunday)
  static DateTime endOfWeek(DateTime date) {
    final startOfWeek = AppDateUtils.startOfWeek(date);
    return endOfWeek(startOfWeek.add(const Duration(days: 6)));
  }

  /// Get start of month
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get end of month
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);
  }

  /// Convert numbers to Arabic numerals
  static String _toArabicNumerals(String input) {
    String result = input;
    arabicNumerals.forEach((key, value) {
      result = result.replaceAll(key, value);
    });
    return result;
  }

  /// Get proper Arabic plural form based on number
  static String _getPluralForm(int number, String singular, String dual, String plural) {
    if (number == 1) {
      return singular;
    } else if (number == 2) {
      return dual;
    } else if (number >= 3 && number <= 10) {
      return plural;
    } else {
      return singular; // For 11+ in Arabic
    }
  }

  /// Format duration in Arabic
  static String formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      final days = duration.inDays;
      return '${_toArabicNumerals(days.toString())} ${_getPluralForm(days, 'يوم', 'يومين', 'أيام')}';
    } else if (duration.inHours > 0) {
      final hours = duration.inHours;
      return '${_toArabicNumerals(hours.toString())} ${_getPluralForm(hours, 'ساعة', 'ساعتين', 'ساعات')}';
    } else if (duration.inMinutes > 0) {
      final minutes = duration.inMinutes;
      return '${_toArabicNumerals(minutes.toString())} ${_getPluralForm(minutes, 'دقيقة', 'دقيقتين', 'دقائق')}';
    } else {
      final seconds = duration.inSeconds;
      return '${_toArabicNumerals(seconds.toString())} ${_getPluralForm(seconds, 'ثانية', 'ثانيتين', 'ثوانٍ')}';
    }
  }

  /// Parse Arabic date input
  static DateTime? parseArabicDate(String input) {
    try {
      // Convert Arabic numerals to English first
      String englishInput = input;
      arabicNumerals.forEach((english, arabic) {
        englishInput = englishInput.replaceAll(arabic, english);
      });

      // Try different date formats
      final formats = [
        'dd/MM/yyyy',
        'dd-MM-yyyy',
        'yyyy-MM-dd',
        'dd/MM/yyyy HH:mm',
        'dd-MM-yyyy HH:mm',
      ];

      for (final format in formats) {
        try {
          return DateFormat(format).parse(englishInput);
        } catch (e) {
          continue;
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get age from birthdate in Arabic
  static String getAgeInArabic(DateTime birthDate) {
    final now = DateTime.now();
    final age = now.year - birthDate.year;

    // Adjust if birthday hasn't occurred this year
    final adjustedAge = (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day))
        ? age - 1 : age;

    return '${_toArabicNumerals(adjustedAge.toString())} ${_getPluralForm(adjustedAge, 'سنة', 'سنتين', 'سنوات')}';
  }

  /// Check if it's prayer time (simplified)
  static bool isPrayerTime(DateTime date) {
    final hour = date.hour;
    final minute = date.minute;

    // Simplified prayer times (would need proper calculation in real app)
    final prayerTimes = [
      {'name': 'الفجر', 'hour': 5, 'minute': 30},
      {'name': 'الظهر', 'hour': 12, 'minute': 30},
      {'name': 'العصر', 'hour': 15, 'minute': 30},
      {'name': 'المغرب', 'hour': 18, 'minute': 0},
      {'name': 'العشاء', 'hour': 19, 'minute': 30},
    ];

    for (final prayer in prayerTimes) {
      if (hour == prayer['hour'] &&
          minute >= (prayer['minute'] as int) &&
          minute <= (prayer['minute'] as int) + 15) {
        return true;
      }
    }

    return false;
  }

  /// Get next prayer time
  static String getNextPrayerTime(DateTime date) {
    final hour = date.hour;
    final minute = date.minute;
    final currentMinutes = hour * 60 + minute;

    final prayerTimes = [
      {'name': 'الفجر', 'minutes': 5 * 60 + 30},
      {'name': 'الظهر', 'minutes': 12 * 60 + 30},
      {'name': 'العصر', 'minutes': 15 * 60 + 30},
      {'name': 'المغرب', 'minutes': 18 * 60},
      {'name': 'العشاء', 'minutes': 19 * 60 + 30},
    ];

    for (final prayer in prayerTimes) {
      final prayerMinutes = prayer['minutes'] as int;
      if (currentMinutes < prayerMinutes) {
        final remainingMinutes = prayerMinutes - currentMinutes;
        final hours = remainingMinutes ~/ 60;
        final mins = remainingMinutes % 60;

        if (hours > 0) {
          return 'باقي ${_toArabicNumerals(hours.toString())}:${_toArabicNumerals(mins.toString().padLeft(2, '0'))} على ${prayer['name']}';
        } else {
          return 'باقي ${_toArabicNumerals(mins.toString())} دقيقة على ${prayer['name']}';
        }
      }
    }

    // If past all prayers, show next day's Fajr
    final minutesToFajr = (24 * 60) - currentMinutes + (5 * 60 + 30);
    final hours = minutesToFajr ~/ 60;
    final mins = minutesToFajr % 60;

    return 'باقي ${_toArabicNumerals(hours.toString())}:${_toArabicNumerals(mins.toString().padLeft(2, '0'))} على الفجر';
  }

  /// Format date range in Arabic
  static String formatDateRange(DateTime start, DateTime end) {
    if (isSameDay(start, end)) {
      return formatArabicDate(start);
    } else if (start.year == end.year && start.month == end.month) {
      return '${_toArabicNumerals(start.day.toString())}-${_toArabicNumerals(end.day.toString())} ${arabicMonths[start.month - 1]} ${_toArabicNumerals(start.year.toString())}';
    } else if (start.year == end.year) {
      return '${_toArabicNumerals(start.day.toString())} ${arabicMonths[start.month - 1]} - ${_toArabicNumerals(end.day.toString())} ${arabicMonths[end.month - 1]} ${_toArabicNumerals(start.year.toString())}';
    } else {
      return '${formatShortArabicDate(start)} - ${formatShortArabicDate(end)}';
    }
  }

  /// Check if two dates are the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Get readable time difference
  static String getReadableTimeDifference(DateTime start, DateTime end) {
    final difference = end.difference(start);

    if (difference.inDays > 0) {
      return formatDuration(difference);
    } else if (difference.inHours > 0) {
      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;
      if (minutes > 0) {
        return '${_toArabicNumerals(hours.toString())} ${_getPluralForm(hours, 'ساعة', 'ساعتين', 'ساعات')} و ${_toArabicNumerals(minutes.toString())} ${_getPluralForm(minutes, 'دقيقة', 'دقيقتين', 'دقائق')}';
      } else {
        return '${_toArabicNumerals(hours.toString())} ${_getPluralForm(hours, 'ساعة', 'ساعتين', 'ساعات')}';
      }
    } else {
      return formatDuration(difference);
    }
  }
}