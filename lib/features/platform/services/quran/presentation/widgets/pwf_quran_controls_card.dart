import 'package:flutter/material.dart';
import '../../domain/pwf_quran_models.dart';
import 'pwf_quran_hero.dart';

class PwfQuranKeysControls {
  static const selectSurahLabel = 'quran.controls.select_surah';
  static const selectReciterLabel = 'quran.controls.select_reciter';
  static const fontSizeLabel = 'quran.controls.font_size';
  static const searchHint = 'quran.controls.search_hint';
  static const searchBtn = 'quran.controls.search_btn';
}

class PwfQuranControlsCard extends StatelessWidget {
  const PwfQuranControlsCard({
    super.key,
    required this.surahs,
    required this.reciters,
    required this.currentSurahId,
    required this.currentReciterId,
    required this.fontScaleRem,
    required this.searchController,
    required this.onSurahChanged,
    required this.onReciterChanged,
    required this.onFontScaleChanged,
    required this.onSearch,
  });

  final List<PwfQuranSurah> surahs;
  final List<PwfQuranReciter> reciters;

  final int currentSurahId;
  final int currentReciterId;
  final double fontScaleRem;

  final TextEditingController searchController;

  final ValueChanged<int> onSurahChanged;
  final ValueChanged<int> onReciterChanged;
  final ValueChanged<double> onFontScaleChanged;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: PwfQuranPalette.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 20),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: LayoutBuilder(
          builder: (ctx, c) {
            final w = c.maxWidth;
            final isNarrow = w < 992;

            final grid = isNarrow
                ? const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 5.2,
                  )
                : const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 3.2,
                  );

            return Column(
              children: [
                GridView(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: grid,
                  children: [
                    _LabeledField(
                      icon: Icons.menu_book_outlined,
                      label: PwfQuranTr.t(
                        context,
                        PwfQuranKeysControls.selectSurahLabel,
                      ),
                      child: DropdownButtonFormField<int>(
                        value: currentSurahId,
                        isExpanded: true,
                        decoration: _inputDecoration(),
                        items: surahs.map((s) {
                          return DropdownMenuItem<int>(
                            value: s.id,
                            child: Text(
                              s.name,
                              textDirection: TextDirection.rtl,
                            ),
                          );
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) onSurahChanged(v);
                        },
                      ),
                    ),
                    _LabeledField(
                      icon: Icons.record_voice_over_outlined,
                      label: PwfQuranTr.t(
                        context,
                        PwfQuranKeysControls.selectReciterLabel,
                      ),
                      child: DropdownButtonFormField<int>(
                        value: currentReciterId,
                        isExpanded: true,
                        decoration: _inputDecoration(),
                        items: reciters.map((r) {
                          return DropdownMenuItem<int>(
                            value: r.id,
                            child: Text(
                              r.name,
                              textDirection: TextDirection.rtl,
                            ),
                          );
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) onReciterChanged(v);
                        },
                      ),
                    ),
                    _LabeledField(
                      icon: Icons.tune,
                      label: PwfQuranTr.t(
                        context,
                        PwfQuranKeysControls.fontSizeLabel,
                      ),
                      child: _FontSlider(
                        value: fontScaleRem,
                        onChanged: onFontScaleChanged,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _SearchRow(controller: searchController, onSearch: onSearch),
              ],
            );
          },
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: PwfQuranPalette.card,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.black.withValues(alpha: 25)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.black.withValues(alpha: 25)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: PwfQuranPalette.primary,
          width: 1.4,
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.icon,
    required this.label,
    required this.child,
  });

  final IconData icon;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: PwfQuranPalette.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: PwfQuranPalette.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _FontSlider extends StatelessWidget {
  const _FontSlider({required this.value, required this.onChanged});

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: PwfQuranPalette.primary,
        inactiveTrackColor: PwfQuranPalette.primary.withValues(alpha: 40),
        thumbColor: PwfQuranPalette.gold,
        overlayColor: PwfQuranPalette.gold.withValues(alpha: 25),
      ),
      child: Slider(
        value: value,
        min: 1.0,
        max: 3.0,
        divisions: 20,
        onChanged: onChanged,
      ),
    );
  }
}

class _SearchRow extends StatelessWidget {
  const _SearchRow({required this.controller, required this.onSearch});

  final TextEditingController controller;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final hint = PwfQuranTr.t(context, PwfQuranKeysControls.searchHint);
    final btn = PwfQuranTr.t(context, PwfQuranKeysControls.searchBtn);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: hint,
                filled: true,
                fillColor: PwfQuranPalette.card,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(10),
                  ),
                  borderSide: BorderSide(
                    color: Colors.black.withValues(alpha: 25),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(10),
                  ),
                  borderSide: BorderSide(
                    color: Colors.black.withValues(alpha: 25),
                  ),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: BorderRadius.horizontal(
                    right: Radius.circular(10),
                  ),
                  borderSide: BorderSide(
                    color: PwfQuranPalette.primary,
                    width: 1.4,
                  ),
                ),
              ),
              onSubmitted: (_) => onSearch(),
            ),
          ),
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: PwfQuranPalette.primary,
                foregroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(10),
                  ),
                ),
                elevation: 0,
              ),
              onPressed: onSearch,
              icon: const Icon(Icons.search),
              label: Text(btn, textDirection: TextDirection.rtl),
            ),
          ),
        ],
      ),
    );
  }
}
