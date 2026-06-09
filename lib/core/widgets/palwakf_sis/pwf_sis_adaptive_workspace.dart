import 'package:flutter/material.dart';

import '../../theme/palwakf_sis_breakpoints.dart';

class PwfSisAdaptiveWorkspace extends StatelessWidget {
  const PwfSisAdaptiveWorkspace({
    super.key,
    required this.primary,
    this.contextPanel,
    this.mobileTabs,
    this.mobileTabLabels,
  });

  final Widget primary;
  final Widget? contextPanel;
  final List<Widget>? mobileTabs;
  final List<String>? mobileTabLabels;

  @override
  Widget build(BuildContext context) {
    final device = PalWakfSisBreakpoints.of(context);

    if (device == PalWakfSisDeviceClass.mobile &&
        mobileTabs != null &&
        mobileTabs!.length >= 2) {
      final labels = _labelsFor(mobileTabs!.length);
      final viewportHeight = MediaQuery.sizeOf(context).height;
      final tabHeight = (viewportHeight * .68).clamp(520.0, 760.0);
      return DefaultTabController(
        length: mobileTabs!.length,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TabBar(
              isScrollable: true,
              tabs: [for (final label in labels) Tab(text: label)],
            ),
            SizedBox(
              height: tabHeight,
              child: TabBarView(
                children: [
                  for (final tab in mobileTabs!)
                    SingleChildScrollView(
                      padding: const EdgeInsets.only(top: 12),
                      child: tab,
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (device == PalWakfSisDeviceClass.mobile || contextPanel == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          primary,
          if (contextPanel != null) ...[
            const SizedBox(height: 16),
            contextPanel!,
          ],
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: primary),
        const SizedBox(width: 16),
        SizedBox(width: 340, child: contextPanel!),
      ],
    );
  }

  List<String> _labelsFor(int count) {
    final custom = mobileTabLabels;
    if (custom != null && custom.length == count) return custom;
    const fallback = ['ملخص', 'عمل', 'أدلة', 'تفاصيل', 'مراجعة'];
    return List<String>.generate(
      count,
      (index) =>
          index < fallback.length ? fallback[index] : 'تبويب ${index + 1}',
      growable: false,
    );
  }
}
