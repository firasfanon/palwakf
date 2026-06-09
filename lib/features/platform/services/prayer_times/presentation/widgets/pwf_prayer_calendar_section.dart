import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/models/pwf_prayer_models.dart';

class PwfPrayerCalendarSection extends StatelessWidget {
  final DateTime focusedMonth;
  final DateTime selectedDate;

  final VoidCallback onPrev;
  final VoidCallback onNext;
  final ValueChanged<DateTime> onSelectDate;

  const PwfPrayerCalendarSection({
    super.key,
    required this.focusedMonth,
    required this.selectedDate,
    required this.onPrev,
    required this.onNext,
    required this.onSelectDate,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    final title = DateFormat.yMMMM(locale).format(focusedMonth);

    final days = _buildGrid(focusedMonth);

    return Container(
      decoration: BoxDecoration(
        color: PwfPrayerPalette.card,
        borderRadius: BorderRadius.circular(PwfPrayerPalette.radius),
        boxShadow: PwfPrayerPalette.shadow,
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onPrev,
                icon: const Icon(Icons.chevron_right),
                color: PwfPrayerPalette.primaryBlue,
              ),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: PwfPrayerPalette.primaryBlue2,
                  ),
                ),
              ),
              IconButton(
                onPressed: onNext,
                icon: const Icon(Icons.chevron_left),
                color: PwfPrayerPalette.primaryBlue,
              ),
            ],
          ),
          const SizedBox(height: 14),
          _WeekHeader(),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: days.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.15,
            ),
            itemBuilder: (context, i) {
              final d = days[i];
              if (d.isEmpty) return const SizedBox.shrink();
              final isSelected = _isSameDate(d.date!, selectedDate);
              return _DayCell(
                day: d,
                isSelected: isSelected,
                onTap: () => onSelectDate(d.date!),
              );
            },
          ),
        ],
      ),
    );
  }

  List<_CalDay> _buildGrid(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final last = DateTime(month.year, month.month + 1, 0);
    final firstWeekday = first.weekday % 7; // Sunday=0 ... Saturday=6

    final cells = <_CalDay>[];

    for (var i = 0; i < firstWeekday; i++) {
      cells.add(const _CalDay.empty());
    }

    for (var d = 1; d <= last.day; d++) {
      final dt = DateTime(month.year, month.month, d);
      final isToday = _isSameDate(dt, DateTime.now());
      final isFriday = dt.weekday == DateTime.friday;
      cells.add(_CalDay(date: dt, isToday: isToday, isFriday: isFriday));
    }

    while (cells.length % 7 != 0) {
      cells.add(const _CalDay.empty());
    }

    return cells;
  }

  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _WeekHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('ar');
    final labels = isAr
        ? const ['أحد', 'اثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة', 'سبت']
        : const ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Row(
      children: labels
          .map(
            (e) => Expanded(
              child: Text(
                e,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: PwfPrayerPalette.primaryBlue2,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _DayCell extends StatelessWidget {
  final _CalDay day;
  final bool isSelected;
  final VoidCallback onTap;

  const _DayCell({
    required this.day,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isSelected
        ? PwfPrayerPalette.gold.withValues(alpha: 220)
        : (day.isToday ? PwfPrayerPalette.primaryBlue : Colors.white);

    final fg = isSelected
        ? Colors.black
        : (day.isToday ? Colors.white : PwfPrayerPalette.text);

    final border = day.isFriday
        ? PwfPrayerPalette.gold
        : Colors.black.withValues(alpha: 18);

    return InkWell(
      borderRadius: BorderRadius.circular(PwfPrayerPalette.radius),
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(PwfPrayerPalette.radius),
          border: Border.all(color: border, width: 1),
        ),
        child: Text(
          '${day.date!.day}',
          style: TextStyle(fontWeight: FontWeight.w900, color: fg),
        ),
      ),
    );
  }
}

class _CalDay {
  final DateTime? date;
  final bool isToday;
  final bool isFriday;

  const _CalDay({
    required this.date,
    required this.isToday,
    required this.isFriday,
  });
  const _CalDay.empty() : date = null, isToday = false, isFriday = false;

  bool get isEmpty => date == null;
}
