import 'package:flutter/material.dart';

import '../../domain/pwf_zakat_models.dart';
import 'pwf_zakat_theme.dart';

class PwfZakatTabSpec {
  const PwfZakatTabSpec({
    required this.tab,
    required this.label,
    required this.icon,
  });

  final PwfZakatTab tab;
  final String label;
  final IconData icon;
}

class PwfZakatCalculatorCard extends StatelessWidget {
  const PwfZakatCalculatorCard({
    super.key,
    required this.tabs,
    required this.activeTab,
    required this.onTabSelected,
    required this.body,
  });

  final List<PwfZakatTabSpec> tabs;
  final PwfZakatTab activeTab;
  final ValueChanged<PwfZakatTab> onTabSelected;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PwfZakatPalette.card,
        borderRadius: PwfZakatDecorations.br,
        border: Border.all(color: PwfZakatPalette.border),
        boxShadow: PwfZakatDecorations.shadow,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          _TabsBar(
            tabs: tabs,
            activeTab: activeTab,
            onTabSelected: onTabSelected,
          ),
          const SizedBox(height: 20),
          body,
        ],
      ),
    );
  }
}

class _TabsBar extends StatelessWidget {
  const _TabsBar({
    required this.tabs,
    required this.activeTab,
    required this.onTabSelected,
  });

  final List<PwfZakatTabSpec> tabs;
  final PwfZakatTab activeTab;
  final ValueChanged<PwfZakatTab> onTabSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: PwfZakatPalette.soft,
        borderRadius: PwfZakatDecorations.br16,
        border: Border.all(color: PwfZakatPalette.border),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: tabs.map((t) {
          final bool isActive = t.tab == activeTab;

          return InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => onTabSelected(t.tab),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: isActive ? PwfZakatPalette.primary : Colors.white,
                border: Border.all(
                  color: isActive
                      ? PwfZakatPalette.primary
                      : PwfZakatPalette.border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    t.icon,
                    size: 18,
                    color: isActive ? Colors.white : PwfZakatPalette.gray,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    t.label,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: isActive ? Colors.white : PwfZakatPalette.gray,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
