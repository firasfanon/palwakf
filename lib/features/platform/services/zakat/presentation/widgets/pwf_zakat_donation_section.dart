import 'package:flutter/material.dart';

import '../../domain/pwf_zakat_models.dart';
import 'pwf_zakat_theme.dart';

class PwfZakatDonationSection extends StatelessWidget {
  const PwfZakatDonationSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.options,
    required this.selected,
    required this.onSelect,
    required this.onProceed,
    required this.proceedLabel,
  });

  final String title;
  final String subtitle;

  final List<PwfZakatDonationOptionSpec> options;
  final PwfZakatDonationOption? selected;
  final ValueChanged<PwfZakatDonationOption> onSelect;

  final VoidCallback onProceed;
  final String proceedLabel;

  int _colsForWidth(double w) {
    final int c = (w / 300).floor();
    return c.clamp(1, 4);
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
          Text(
            title,
            style: PwfZakatTextStyles.sectionTitle(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(color: PwfZakatPalette.gray),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, c) {
              final cols = _colsForWidth(c.maxWidth);
              return GridView.builder(
                itemCount: options.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.25,
                ),
                itemBuilder: (context, i) {
                  final opt = options[i];
                  final bool isSelected = selected == opt.option;

                  return InkWell(
                    borderRadius: PwfZakatDecorations.br16,
                    onTap: () => onSelect(opt.option),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? PwfZakatPalette.primary.withValues(alpha: 26)
                            : PwfZakatPalette.primary.withValues(alpha: 13),
                        borderRadius: PwfZakatDecorations.br16,
                        border: Border.all(
                          color: isSelected
                              ? PwfZakatPalette.primary2
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            opt.icon,
                            size: 34,
                            color: PwfZakatPalette.primary2,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            opt.title,
                            style: Theme.of(context).textTheme.titleMedium!
                                .copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            opt.description,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall!
                                .copyWith(
                                  color: PwfZakatPalette.gray,
                                  height: 1.5,
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: onProceed,
            icon: const Icon(Icons.arrow_back),
            label: Text(proceedLabel),
            style: ElevatedButton.styleFrom(
              backgroundColor: PwfZakatPalette.primary2,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PwfZakatDonationOptionSpec {
  const PwfZakatDonationOptionSpec({
    required this.option,
    required this.icon,
    required this.title,
    required this.description,
  });

  final PwfZakatDonationOption option;
  final IconData icon;
  final String title;
  final String description;
}
