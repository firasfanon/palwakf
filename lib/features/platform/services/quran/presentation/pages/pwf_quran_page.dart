import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:waqf/features/platform/home/presentation/theme/pwf_home_palette.dart';
import 'package:waqf/features/platform/home/presentation/widgets/pwf_internal_public_page_contract_widgets.dart';
import '../../data/pwf_quran_in_memory_repository.dart';
import '../../data/pwf_quran_repository.dart';
import '../../domain/pwf_quran_models.dart';

class PwfQuranPage extends StatefulWidget {
  const PwfQuranPage({
    super.key,
    this.embedInPublicShell = false,
    this.unitSlug = 'home',
  });

  final bool embedInPublicShell;
  final String unitSlug;

  @override
  State<PwfQuranPage> createState() => _PwfQuranPageState();
}

class _PwfQuranPageState extends State<PwfQuranPage> {
  final PwfQuranRepository _repo = PwfQuranInMemoryRepository();

  List<PwfQuranSurah> _all = const [];
  List<PwfQuranSurah> _filtered = const [];
  PwfQuranSurah? _selected;

  double _fontScale = 1.0;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final surahs = await _repo.listSurahs();
    if (!mounted) return;
    setState(() {
      _all = surahs;
      _filtered = surahs;
      _selected = surahs.isNotEmpty ? surahs.first : null;
    });
  }

  void _applySearch(String q) {
    final query = q.trim();
    setState(() {
      _query = query;
      if (query.isEmpty) {
        _filtered = _all;
      } else {
        _filtered = _all
            .where((s) => s.name.contains(query))
            .toList(growable: false);
      }
      if (_selected != null && !_filtered.any((x) => x.id == _selected!.id)) {
        _selected = _filtered.isNotEmpty ? _filtered.first : null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(
      context,
    ).languageCode.toLowerCase().startsWith('ar');
    final body = _QuranPublicBody(
      isAr: isAr,
      all: _all,
      filtered: _filtered,
      selected: _selected,
      query: _query,
      fontScale: _fontScale,
      onQueryChanged: _applySearch,
      onSelect: (s) => setState(() => _selected = s),
      onFontScaleChanged: (v) => setState(() => _fontScale = v),
      embedded: widget.embedInPublicShell,
      unitSlug: widget.unitSlug,
    );

    return Directionality(
      textDirection: isAr ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: widget.embedInPublicShell
          ? body
          : Scaffold(
              appBar: AppBar(title: Text(isAr ? 'القرآن الكريم' : 'Quran')),
              body: body,
            ),
    );
  }
}

class _QuranPublicBody extends StatelessWidget {
  const _QuranPublicBody({
    required this.isAr,
    required this.all,
    required this.filtered,
    required this.selected,
    required this.query,
    required this.fontScale,
    required this.onQueryChanged,
    required this.onSelect,
    required this.onFontScaleChanged,
    required this.embedded,
    required this.unitSlug,
  });

  final bool isAr;
  final List<PwfQuranSurah> all;
  final List<PwfQuranSurah> filtered;
  final PwfQuranSurah? selected;
  final String query;
  final double fontScale;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<PwfQuranSurah> onSelect;
  final ValueChanged<double> onFontScaleChanged;
  final bool embedded;
  final String unitSlug;

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final boundedHeight = embedded
        ? math.max(760.0, math.min(980.0, screenH * 0.82))
        : double.infinity;

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: embedded ? 20 : 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!embedded) _QuranHeroBanner(isAr: isAr),
          Container(
            color: const Color(0xFFF7F8FA),
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (embedded) ...[
                      PwfInternalPublicPageIntro(
                        specKey: 'quran',
                        unitSlug: unitSlug,
                        verticalPadding: 0,
                      ),
                      const SizedBox(height: 20),
                    ],
                    _QuranIntroCard(isAr: isAr, totalSurahs: all.length),
                    const SizedBox(height: 20),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 18,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        height: boundedHeight,
                        child: all.isEmpty
                            ? const Center(child: CircularProgressIndicator())
                            : Padding(
                                padding: const EdgeInsets.all(16),
                                child: LayoutBuilder(
                                  builder: (context, c) {
                                    final wide = c.maxWidth >= 980;
                                    final list = _SurahList(
                                      isAr: isAr,
                                      query: query,
                                      onQueryChanged: onQueryChanged,
                                      surahs: filtered,
                                      selectedId: selected?.id,
                                      onSelect: onSelect,
                                    );
                                    final detail = selected == null
                                        ? _EmptyState(isAr: isAr)
                                        : _SurahReader(
                                            isAr: isAr,
                                            surah: selected!,
                                            fontScale: fontScale,
                                            onFontScaleChanged:
                                                onFontScaleChanged,
                                          );
                                    if (!wide) {
                                      return Column(
                                        children: [
                                          SizedBox(height: 240, child: list),
                                          const SizedBox(height: 12),
                                          const Divider(height: 1),
                                          const SizedBox(height: 12),
                                          Expanded(child: detail),
                                        ],
                                      );
                                    }
                                    return Row(
                                      children: [
                                        SizedBox(width: 360, child: list),
                                        const VerticalDivider(width: 24),
                                        Expanded(child: detail),
                                      ],
                                    );
                                  },
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isAr
                          ? 'نسخة أولية مهيأة للواجهة العامة بهوية الوزارة. سيُستكمل لاحقًا الفهرس الكامل، والبحث النصي، والتلاوات، والعلامات المرجعية المتقدمة.'
                          : 'Initial public version aligned with the ministry identity. Full index, text search, recitations, and advanced bookmarks will be added later.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF4B5563),
                        height: 1.8,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuranHeroBanner extends StatelessWidget {
  const _QuranHeroBanner({required this.isAr});

  final bool isAr;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [Color(0xFF0B3A6A), Color(0xFF0F4D7D)],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withValues(alpha: 40),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withValues(alpha: 100),
                  ),
                ),
                child: Text(
                  isAr
                      ? 'الواجهة العامة • القرآن الكريم'
                      : 'Public Interface • Quran',
                  style: const TextStyle(
                    color: Color(0xFFFFF4CC),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                isAr ? 'القرآن الكريم' : 'The Holy Quran',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                isAr
                    ? 'واجهة عامة مهيأة لقراءة السور واستعراض الآيات بخط واضح وهوية بصرية منسجمة مع بوابة وزارة الأوقاف والشؤون الدينية.'
                    : 'A public reading interface for browsing surahs and verses with a clear layout aligned to the Ministry of Awqaf visual identity.',
                style: const TextStyle(
                  color: Color(0xFFE7EEF7),
                  fontSize: 15,
                  height: 1.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuranIntroCard extends StatelessWidget {
  const _QuranIntroCard({required this.isAr, required this.totalSurahs});

  final bool isAr;
  final int totalSurahs;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.all(18),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _InfoChip(
            icon: Icons.menu_book_rounded,
            label: isAr ? 'السور المتاحة' : 'Available Surahs',
            value: '$totalSurahs',
          ),
          _InfoChip(
            icon: Icons.search_rounded,
            label: isAr ? 'البحث' : 'Search',
            value: isAr ? 'مفعّل' : 'Enabled',
          ),
          _InfoChip(
            icon: Icons.text_fields_rounded,
            label: isAr ? 'حجم الخط' : 'Font size',
            value: isAr ? 'قابل للتعديل' : 'Adjustable',
          ),
          _InfoChip(
            icon: Icons.public_rounded,
            label: isAr ? 'الهوية' : 'Identity',
            value: isAr ? 'سيادية' : 'Sovereign',
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF0B3A6A).withValues(alpha: 18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF0B3A6A), size: 18),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SurahList extends StatelessWidget {
  const _SurahList({
    required this.isAr,
    required this.query,
    required this.onQueryChanged,
    required this.surahs,
    required this.selectedId,
    required this.onSelect,
  });

  final bool isAr;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final List<PwfQuranSurah> surahs;
  final int? selectedId;
  final ValueChanged<PwfQuranSurah> onSelect;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: isAr ? 'ابحث عن سورة...' : 'Search surah...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                filled: true,
                fillColor: Colors.white,
                isDense: true,
              ),
              onChanged: onQueryChanged,
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: surahs.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final s = surahs[i];
                final selected = s.id == selectedId;
                return ListTile(
                  selected: selected,
                  selectedTileColor: const Color(
                    0xFF0B3A6A,
                  ).withValues(alpha: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  leading: CircleAvatar(
                    backgroundColor: selected
                        ? const Color(0xFFB22222)
                        : const Color(0xFF0B3A6A),
                    foregroundColor: Colors.white,
                    child: Text('${s.id}'),
                  ),
                  title: Text(
                    s.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    isAr
                        ? '${s.type} • جزء ${s.part}'
                        : '${s.type} • Juz ${s.part}',
                  ),
                  trailing: Text('${s.ayahCount}'),
                  onTap: () => onSelect(s),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SurahReader extends StatelessWidget {
  const _SurahReader({
    required this.isAr,
    required this.surah,
    required this.fontScale,
    required this.onFontScaleChanged,
  });

  final bool isAr;
  final PwfQuranSurah surah;
  final double fontScale;
  final ValueChanged<double> onFontScaleChanged;

  @override
  Widget build(BuildContext context) {
    final base = 20.0;
    final fontSize = base * fontScale;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 560;
                final meta = Text(
                  isAr
                      ? '${surah.type} • جزء ${surah.part}'
                      : '${surah.type} • Juz ${surah.part}',
                  style: const TextStyle(color: Color(0xFF4B5563)),
                );
                if (compact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        surah.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0B3A6A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      meta,
                    ],
                  );
                }
                return Row(
                  children: [
                    Expanded(
                      child: Text(
                        surah.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0B3A6A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    meta,
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 520;
                final slider = Slider(
                  activeColor: PwfHomePalette.secondary,
                  value: fontScale,
                  min: 0.85,
                  max: 1.45,
                  onChanged: onFontScaleChanged,
                );
                if (compact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isAr ? 'حجم الخط' : 'Font'),
                      slider,
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: Text(fontScale.toStringAsFixed(2)),
                      ),
                    ],
                  );
                }
                return Row(
                  children: [
                    Text(isAr ? 'حجم الخط' : 'Font'),
                    Expanded(child: slider),
                    Text(fontScale.toStringAsFixed(2)),
                  ],
                );
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(14),
              itemCount: surah.ayahText.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final ayah = surah.ayahText[i];
                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _AyahBadge(number: i + 1),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            ayah,
                            style: TextStyle(fontSize: fontSize, height: 1.9),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AyahBadge extends StatelessWidget {
  const _AyahBadge({required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 16,
      backgroundColor: const Color(0xFFB22222),
      foregroundColor: Colors.white,
      child: Text(
        '$number',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isAr});

  final bool isAr;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        isAr ? 'لا توجد بيانات متاحة حاليًا' : 'No data available right now',
      ),
    );
  }
}
