import 'package:flutter/material.dart';

import 'pwf_zakat_theme.dart';

class PwfZakatInfoSection extends StatelessWidget {
  const PwfZakatInfoSection({
    super.key,
    required this.title,
    required this.cards,
  });

  final String title;
  final List<PwfZakatInfoCardData> cards;

  int _colsForWidth(double w) {
    final int c = (w / 360).floor();
    return c.clamp(1, 3);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PwfZakatPalette.card,
        borderRadius: PwfZakatDecorations.br16,
        border: Border.all(color: PwfZakatPalette.border),
        boxShadow: PwfZakatDecorations.shadow,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.info, color: PwfZakatPalette.primary),
              const SizedBox(width: 10),
              Text(title, style: PwfZakatTextStyles.sectionTitle(context)),
            ],
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, c) {
              final cols = _colsForWidth(c.maxWidth);
              return GridView.builder(
                itemCount: cards.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.55,
                ),
                itemBuilder: (context, i) => _InfoCard(card: cards[i]),
              );
            },
          ),
        ],
      ),
    );
  }
}

class PwfZakatInfoCardData {
  const PwfZakatInfoCardData({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.card});
  final PwfZakatInfoCardData card;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PwfZakatPalette.soft,
        borderRadius: PwfZakatDecorations.br16,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(card.icon, color: PwfZakatPalette.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  card.title,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: PwfZakatPalette.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                card.body,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: PwfZakatPalette.gray,
                  height: 1.7,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
