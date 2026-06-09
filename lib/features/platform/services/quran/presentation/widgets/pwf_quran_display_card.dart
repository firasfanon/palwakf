import 'package:flutter/material.dart';
import '../../domain/pwf_quran_models.dart';
import 'pwf_quran_hero.dart';

class PwfQuranKeysDisplay {
  static const infoType = 'quran.display.info_type';
  static const infoAyahs = 'quran.display.info_ayahs';
  static const infoPart = 'quran.display.info_part';

  static const prev = 'quran.tools.prev';
  static const next = 'quran.tools.next';
  static const listen = 'quran.tools.listen';
  static const stop = 'quran.tools.stop';

  static const addBookmark = 'quran.tools.add_bookmark';
  static const addedBookmark = 'quran.tools.added_bookmark';
  static const tafsir = 'quran.tools.tafsir';
}

class PwfQuranDisplayCard extends StatelessWidget {
  const PwfQuranDisplayCard({
    super.key,
    required this.surah,
    required this.fontScaleRem,
    required this.isPlaying,
    required this.isBookmarked,
    required this.onPrev,
    required this.onNext,
    required this.onTogglePlay,
    required this.onToggleBookmark,
    required this.onTafsir,
  });

  final PwfQuranSurah surah;
  final double fontScaleRem;

  final bool isPlaying;
  final bool isBookmarked;

  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onTogglePlay;
  final VoidCallback onToggleBookmark;
  final VoidCallback onTafsir;

  @override
  Widget build(BuildContext context) {
    final fontSize = 18.0 * fontScaleRem;

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
        child: Column(
          children: [
            _SurahHeader(surah: surah),
            const SizedBox(height: 16),
            _AyahContainer(surah: surah, fontSize: fontSize),
            const SizedBox(height: 16),
            _ToolsRow(
              isPlaying: isPlaying,
              isBookmarked: isBookmarked,
              onPrev: onPrev,
              onNext: onNext,
              onTogglePlay: onTogglePlay,
              onToggleBookmark: onToggleBookmark,
              onTafsir: onTafsir,
            ),
          ],
        ),
      ),
    );
  }
}

class _SurahHeader extends StatelessWidget {
  const _SurahHeader({required this.surah});

  final PwfQuranSurah surah;

  @override
  Widget build(BuildContext context) {
    final typeLabel = PwfQuranTr.t(context, PwfQuranKeysDisplay.infoType);
    final ayahLabel = PwfQuranTr.t(context, PwfQuranKeysDisplay.infoAyahs);
    final partLabel = PwfQuranTr.t(context, PwfQuranKeysDisplay.infoPart);

    return Column(
      children: [
        Text(
          surah.name,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: PwfQuranPalette.primary,
            fontSize: 34,
            height: 1.2,
            fontWeight: FontWeight.w800,
            fontFamily: 'Scheherazade New',
          ),
        ),
        const SizedBox(height: 10),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: PwfQuranPalette.primary.withValues(alpha: 25),
                width: 2,
              ),
            ),
          ),
          child: const SizedBox(height: 1, width: double.infinity),
        ),
        const SizedBox(height: 10),
        Directionality(
          textDirection: TextDirection.rtl,
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 18,
            runSpacing: 10,
            children: [
              _InfoPill(
                icon: Icons.description_outlined,
                text: '$typeLabel: ${surah.type}',
              ),
              _InfoPill(
                icon: Icons.format_list_numbered,
                text: '$ayahLabel: ${surah.ayahCount}',
              ),
              _InfoPill(
                icon: Icons.schedule,
                text: '$partLabel: ${surah.part}',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: PwfQuranPalette.bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black.withValues(alpha: 18)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: PwfQuranPalette.gray),
            const SizedBox(width: 8),
            Text(
              text,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                color: PwfQuranPalette.gray,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AyahContainer extends StatelessWidget {
  const _AyahContainer({required this.surah, required this.fontSize});

  final PwfQuranSurah surah;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: PwfQuranPalette.accent.withValues(alpha: 12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          children: [
            for (int i = 0; i < surah.ayahText.length; i++) ...[
              _AyahLine(
                number: i + 1,
                text: surah.ayahText[i],
                fontSize: fontSize,
              ),
              if (i != surah.ayahText.length - 1) const SizedBox(height: 14),
            ],
          ],
        ),
      ),
    );
  }
}

class _AyahLine extends StatelessWidget {
  const _AyahLine({
    required this.number,
    required this.text,
    required this.fontSize,
  });

  final int number;
  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 10,
        runSpacing: 6,
        children: [
          _AyahNumberBadge(number: number),
          SelectableText(
            text,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: fontSize,
              height: 1.7,
              color: const Color(0xFF1A472A),
              fontFamily: 'Scheherazade New',
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AyahNumberBadge extends StatelessWidget {
  const _AyahNumberBadge({required this.number});
  final int number;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: PwfQuranPalette.gold,
        shape: BoxShape.circle,
      ),
      child: SizedBox(
        width: 30,
        height: 30,
        child: Center(
          child: Text(
            '$number',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 12,
              fontFamily: 'Cairo',
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolsRow extends StatelessWidget {
  const _ToolsRow({
    required this.isPlaying,
    required this.isBookmarked,
    required this.onPrev,
    required this.onNext,
    required this.onTogglePlay,
    required this.onToggleBookmark,
    required this.onTafsir,
  });

  final bool isPlaying;
  final bool isBookmarked;

  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onTogglePlay;
  final VoidCallback onToggleBookmark;
  final VoidCallback onTafsir;

  @override
  Widget build(BuildContext context) {
    final prev = PwfQuranTr.t(context, PwfQuranKeysDisplay.prev);
    final next = PwfQuranTr.t(context, PwfQuranKeysDisplay.next);
    final listen = PwfQuranTr.t(
      context,
      isPlaying ? PwfQuranKeysDisplay.stop : PwfQuranKeysDisplay.listen,
    );
    final bookmarkText = PwfQuranTr.t(
      context,
      isBookmarked
          ? PwfQuranKeysDisplay.addedBookmark
          : PwfQuranKeysDisplay.addBookmark,
    );
    final tafsir = PwfQuranTr.t(context, PwfQuranKeysDisplay.tafsir);

    return LayoutBuilder(
      builder: (ctx, c) {
        final isNarrow = c.maxWidth < 992;

        final leftGroup = Wrap(
          spacing: 12,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: [
            _PwfBtn(
              onPressed: onPrev,
              background: PwfQuranPalette.primary,
              icon: Icons.chevron_right,
              label: prev,
            ),
            _PwfBtn(
              onPressed: onTogglePlay,
              background: isPlaying
                  ? PwfQuranPalette.accent
                  : PwfQuranPalette.gold,
              icon: isPlaying ? Icons.pause : Icons.play_arrow,
              label: listen,
              foreground: Colors.white,
            ),
            _PwfBtn(
              onPressed: onNext,
              background: PwfQuranPalette.primary,
              icon: Icons.chevron_left,
              label: next,
              iconAtEnd: true,
            ),
          ],
        );

        final rightGroup = Wrap(
          spacing: 12,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: [
            _PwfBtn(
              onPressed: onToggleBookmark,
              background: isBookmarked
                  ? PwfQuranPalette.accent
                  : PwfQuranPalette.gold,
              icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              label: bookmarkText,
              foreground: Colors.white,
            ),
            _PwfBtn(
              onPressed: onTafsir,
              background: PwfQuranPalette.gold,
              icon: Icons.info_outline,
              label: tafsir,
              foreground: Colors.white,
            ),
          ],
        );

        if (isNarrow) {
          return Column(
            children: [leftGroup, const SizedBox(height: 12), rightGroup],
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Align(alignment: Alignment.centerRight, child: leftGroup),
            ),
            Expanded(
              child: Align(alignment: Alignment.centerLeft, child: rightGroup),
            ),
          ],
        );
      },
    );
  }
}

class _PwfBtn extends StatelessWidget {
  const _PwfBtn({
    required this.onPressed,
    required this.background,
    required this.icon,
    required this.label,
    this.foreground = Colors.white,
    this.iconAtEnd = false,
  });

  final VoidCallback onPressed;
  final Color background;
  final Color foreground;
  final IconData icon;
  final String label;
  final bool iconAtEnd;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: iconAtEnd
          ? [
              Text(label, textDirection: TextDirection.rtl),
              const SizedBox(width: 8),
              Icon(icon, size: 18),
            ]
          : [
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Text(label, textDirection: TextDirection.rtl),
            ],
    );

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
      onPressed: onPressed,
      child: Directionality(textDirection: TextDirection.rtl, child: child),
    );
  }
}
