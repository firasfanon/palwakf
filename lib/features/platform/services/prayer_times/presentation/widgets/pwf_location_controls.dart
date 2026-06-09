import 'package:flutter/material.dart';

import '../../domain/models/pwf_prayer_models.dart';
import 'pwf_prayer_i18n.dart';

class PwfLocationControls extends StatelessWidget {
  final List<PwfPrayerCity> cities;
  final List<PwfPrayerCalcMethod> methods;

  final PwfPrayerCity selectedCity;
  final PwfPrayerCalcMethod selectedMethod;
  final DateTime selectedDate;

  final bool notificationsEnabled;

  final VoidCallback onUpdateTimes;
  final Future<void> Function() onAutoLocation;
  final VoidCallback onToggleNotifications;
  final VoidCallback onScrollToCalendar;

  final Future<void> Function(PwfPrayerCity city) onCityChanged;
  final Future<void> Function(DateTime date) onDateChanged;
  final Future<void> Function(PwfPrayerCalcMethod method) onMethodChanged;

  const PwfLocationControls({
    super.key,
    required this.cities,
    required this.methods,
    required this.selectedCity,
    required this.selectedMethod,
    required this.selectedDate,
    required this.notificationsEnabled,
    required this.onUpdateTimes,
    required this.onAutoLocation,
    required this.onToggleNotifications,
    required this.onScrollToCalendar,
    required this.onCityChanged,
    required this.onDateChanged,
    required this.onMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.pwfPrayerI18n;

    return Container(
      decoration: BoxDecoration(
        color: PwfPrayerPalette.card,
        borderRadius: BorderRadius.circular(PwfPrayerPalette.radius),
        boxShadow: PwfPrayerPalette.shadow,
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth;
              final isNarrow = w < 900;

              return Wrap(
                spacing: 16,
                runSpacing: 14,
                children: [
                  SizedBox(
                    width: isNarrow ? double.infinity : (w - 32) / 3,
                    child: _SelectField(
                      icon: Icons.location_on,
                      label: t.cityLabel,
                      child: DropdownButtonFormField<String>(
                        value: selectedCity.id,
                        items: cities
                            .map(
                              (c) => DropdownMenuItem<String>(
                                value: c.id,
                                child: Text(t.isArabic ? c.nameAr : c.nameEn),
                              ),
                            )
                            .toList(),
                        onChanged: (v) async {
                          if (v == null) return;
                          final next = cities.firstWhere((e) => e.id == v);
                          await onCityChanged(next);
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    width: isNarrow ? double.infinity : (w - 32) / 3,
                    child: _SelectField(
                      icon: Icons.calendar_month,
                      label: t.dateLabel,
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000, 1, 1),
                            lastDate: DateTime(2100, 12, 31),
                            helpText: t.dateLabel,
                          );
                          if (picked != null) {
                            await onDateChanged(picked);
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: isNarrow ? double.infinity : (w - 32) / 3,
                    child: _SelectField(
                      icon: Icons.calculate,
                      label: t.methodLabel,
                      child: DropdownButtonFormField<String>(
                        value: selectedMethod.code,
                        items: methods
                            .map(
                              (m) => DropdownMenuItem<String>(
                                value: m.code,
                                child: Text(t.methodName(m)),
                              ),
                            )
                            .toList(),
                        onChanged: (code) async {
                          if (code == null) return;
                          final m = methods.firstWhere((e) => e.code == code);
                          await onMethodChanged(m);
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _PrimaryBtn(
                icon: Icons.sync,
                text: t.updateTimes,
                onPressed: onUpdateTimes,
              ),
              _SecondaryBtn(
                icon: Icons.my_location,
                text: t.autoLocation,
                onPressed: () async => onAutoLocation(),
              ),
              _PrimaryBtn(
                icon: notificationsEnabled
                    ? Icons.notifications_off
                    : Icons.notifications,
                text: notificationsEnabled
                    ? t.disableNotifications
                    : t.enableNotifications,
                onPressed: onToggleNotifications,
              ),
              _SecondaryBtn(
                icon: Icons.calendar_view_month,
                text: t.monthlyCalendar,
                onPressed: onScrollToCalendar,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SelectField extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget child;

  const _SelectField({
    required this.icon,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: PwfPrayerPalette.primaryBlue),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: PwfPrayerPalette.primaryBlue2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Theme(
          data: Theme.of(context).copyWith(
            inputDecorationTheme: const InputDecorationTheme(
              isDense: true,
              border: OutlineInputBorder(),
            ),
          ),
          child: child,
        ),
      ],
    );
  }
}

class _PrimaryBtn extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;

  const _PrimaryBtn({
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: PwfPrayerPalette.primaryBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PwfPrayerPalette.radius),
        ),
      ),
    );
  }
}

class _SecondaryBtn extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;

  const _SecondaryBtn({
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: PwfPrayerPalette.gold,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PwfPrayerPalette.radius),
        ),
      ),
    );
  }
}
