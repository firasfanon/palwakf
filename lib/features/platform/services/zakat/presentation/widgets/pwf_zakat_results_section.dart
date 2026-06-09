import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'pwf_zakat_theme.dart';

class PwfZakatResultsSection extends StatelessWidget {
  const PwfZakatResultsSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.items,
    required this.totalLabel,
    required this.totalValue,
    required this.printLabel,
    required this.donateNowLabel,
    required this.newCalculationLabel,
    required this.onPrint,
    required this.onDonateNow,
    required this.onNewCalculation,
  });

  final String title;
  final String subtitle;
  final List<PwfResultItem> items;

  final String totalLabel;
  final String totalValue;

  final String printLabel;
  final String donateNowLabel;
  final String newCalculationLabel;

  final VoidCallback onPrint;
  final VoidCallback onDonateNow;
  final VoidCallback onNewCalculation;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PwfZakatPalette.primary.withValues(alpha: 13),
        borderRadius: PwfZakatDecorations.br,
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              fontWeight: FontWeight.w800,
              color: PwfZakatPalette.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(color: PwfZakatPalette.gray),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          _ResultsGrid(items: items),
          const SizedBox(height: 18),
          _TotalCard(totalLabel: totalLabel, totalValue: totalValue),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: <Widget>[
              OutlinedButton.icon(
                onPressed: onPrint,
                icon: const Icon(Icons.print),
                label: Text(printLabel),
              ),
              ElevatedButton.icon(
                onPressed: onDonateNow,
                icon: const Icon(Icons.volunteer_activism),
                label: Text(donateNowLabel),
              ),
              TextButton.icon(
                onPressed: onNewCalculation,
                icon: const Icon(Icons.refresh),
                label: Text(newCalculationLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ResultsGrid extends StatelessWidget {
  const _ResultsGrid({required this.items});
  final List<PwfResultItem> items;

  int _colsForWidth(double w) {
    final int c = (w / 280).floor();
    return c.clamp(1, 4);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final cols = _colsForWidth(c.maxWidth);
        return GridView.builder(
          itemCount: items.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.2,
          ),
          itemBuilder: (context, i) {
            final item = items[i];
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: PwfZakatDecorations.br,
                boxShadow: PwfZakatDecorations.shadow,
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    item.label,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: PwfZakatPalette.gray,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.value,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: PwfZakatPalette.primary2,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.totalLabel, required this.totalValue});

  final String totalLabel;
  final String totalValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: <Color>[PwfZakatPalette.primary, PwfZakatPalette.primary2],
        ),
        borderRadius: PwfZakatDecorations.br,
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        children: <Widget>[
          Text(
            totalLabel,
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: Colors.white.withAlpha(235),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            totalValue,
            style: Theme.of(context).textTheme.displaySmall!.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            DateFormat.yMMMMd(
              Localizations.localeOf(context).toLanguageTag(),
            ).format(DateTime.now()),
            style: Theme.of(
              context,
            ).textTheme.bodySmall!.copyWith(color: Colors.white.withAlpha(210)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class PwfResultItem {
  const PwfResultItem({required this.label, required this.value});
  final String label;
  final String value;
}
