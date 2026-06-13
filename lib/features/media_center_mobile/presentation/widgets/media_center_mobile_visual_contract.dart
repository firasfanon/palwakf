
import 'package:flutter/material.dart';

class MediaCenterMobileVisualContract {
  const MediaCenterMobileVisualContract._();

  static const platformDark = Color(0xFF0B1220);
  static const platformBlue = Color(0xFF0E3A6D);
  static const platformGold = Color(0xFFD4AF37);
  static const royalRed = Color(0xFFB22222);
  static const background = Color(0xFFF5F7FB);
  static const card = Colors.white;
  static const text = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);
  static const border = Color(0xFFE2E8F0);
  static const success = Color(0xFF047857);
  static const successSoft = Color(0xFFECFDF5);
  static const warningSoft = Color(0xFFFFFBEB);

  static ThemeData theme(BuildContext context) {
    final base = Theme.of(context);
    return base.copyWith(
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: platformDark,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 19,
          fontWeight: FontWeight.w800,
        ),
      ),
      colorScheme: base.colorScheme.copyWith(
        primary: platformBlue,
        secondary: platformGold,
        error: royalRed,
        surface: card,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(color: muted),
        helperStyle: const TextStyle(color: muted, height: 1.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: platformGold, width: 1.6),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: card,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: border),
        ),
      ),
    );
  }

  static ButtonStyle primaryButtonStyle() {
    return FilledButton.styleFrom(
      backgroundColor: platformGold,
      foregroundColor: platformDark,
      disabledBackgroundColor: border,
      disabledForegroundColor: muted,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      textStyle: const TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 14,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    );
  }

  static ButtonStyle secondaryButtonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: platformBlue,
      side: const BorderSide(color: platformGold),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      textStyle: const TextStyle(fontWeight: FontWeight.w800),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    );
  }

  static BoxDecoration heroDecoration() {
    return BoxDecoration(
      color: platformDark,
      borderRadius: BorderRadius.circular(28),
      border: const Border(
        top: BorderSide(color: platformGold, width: 3),
      ),
      boxShadow: [
        BoxShadow(
          color: platformDark.withOpacity(0.12),
          blurRadius: 24,
          offset: const Offset(0, 16),
        ),
      ],
    );
  }
}

class MediaCenterMobileShell extends StatelessWidget {
  const MediaCenterMobileShell({
    super.key,
    required this.title,
    required this.body,
    this.bottomNavigationBar,
    this.floatingActionButton,
  });

  final String title;
  final Widget body;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: MediaCenterMobileVisualContract.theme(context),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: MediaCenterMobileVisualContract.background,
          appBar: AppBar(
            title: Text(title),
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(3),
              child: ColoredBox(
                color: MediaCenterMobileVisualContract.platformGold,
                child: SizedBox(height: 3, width: double.infinity),
              ),
            ),
          ),
          body: SafeArea(child: body),
          bottomNavigationBar: bottomNavigationBar,
          floatingActionButton: floatingActionButton,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.startFloat,
        ),
      ),
    );
  }
}

class MediaCenterOfficialHero extends StatelessWidget {
  const MediaCenterOfficialHero({
    super.key,
    required this.title,
    required this.subtitle,
    required this.chips,
    this.icon = Icons.newspaper,
  });

  final String title;
  final String subtitle;
  final List<Widget> chips;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      padding: const EdgeInsets.all(18),
      decoration: MediaCenterMobileVisualContract.heroDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: MediaCenterMobileVisualContract.platformGold,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    icon,
                    color: MediaCenterMobileVisualContract.platformDark,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.78),
              fontSize: 13.5,
              height: 1.65,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(spacing: 8, runSpacing: 8, children: chips),
        ],
      ),
    );
  }
}

class MediaCenterContractChip extends StatelessWidget {
  const MediaCenterContractChip({
    super.key,
    required this.label,
    this.icon,
    this.emphasis = false,
    this.danger = false,
  });

  final String label;
  final IconData? icon;
  final bool emphasis;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final background = danger
        ? MediaCenterMobileVisualContract.royalRed
        : emphasis
            ? MediaCenterMobileVisualContract.platformGold
            : Colors.white.withOpacity(0.12);

    final foreground = emphasis
        ? MediaCenterMobileVisualContract.platformDark
        : Colors.white;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: emphasis
              ? MediaCenterMobileVisualContract.platformGold
              : Colors.white.withOpacity(0.18),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 15, color: foreground),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                color: foreground,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MediaCenterSoftChip extends StatelessWidget {
  const MediaCenterSoftChip({
    super.key,
    required this.label,
    this.icon,
    this.gold = false,
    this.red = false,
  });

  final String label;
  final IconData? icon;
  final bool gold;
  final bool red;

  @override
  Widget build(BuildContext context) {
    final bg = red
        ? const Color(0xFFFFF1F2)
        : gold
            ? const Color(0xFFFFF7D6)
            : const Color(0xFFF1F5F9);
    final fg = red
        ? MediaCenterMobileVisualContract.royalRed
        : gold
            ? const Color(0xFF7A5A00)
            : MediaCenterMobileVisualContract.platformBlue;

    return Chip(
      avatar: icon == null ? null : Icon(icon, size: 15, color: fg),
      label: Text(label),
      labelStyle: TextStyle(
        fontSize: 11.5,
        color: fg,
        fontWeight: FontWeight.w800,
      ),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      backgroundColor: bg,
      side: BorderSide(color: fg.withOpacity(0.16)),
    );
  }
}
