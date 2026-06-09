import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/pwf_accessibility_settings_provider.dart';
import '../../../domain/models/pwf_accessibility_settings.dart';

class PwfAccessibilityPage extends ConsumerWidget {
  const PwfAccessibilityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(pwfAccessibilitySettingsProvider);
    final notifier = ref.read(pwfAccessibilitySettingsProvider.notifier);

    final scheme = PwfAccessibilityScheme.from(settings);

    final base = MediaQuery.of(context);
    final scale = (settings.fontPx / 16.0).clamp(0.85, 1.45);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: MediaQuery(
        data: base.copyWith(textScaler: TextScaler.linear(scale)),
        child: Scaffold(
          backgroundColor: scheme.bg,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      20,
                      60,
                      20,
                      60,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        PwfAccessibilitySectionTitle(scheme: scheme),
                        const SizedBox(height: 40),
                        PwfResponsiveGrid(
                          minTileWidth: 300,
                          gap: 30,
                          children: [
                            PwfFeatureCard(
                              scheme: scheme,
                              topBorderColor: scheme.primary,
                              icon: Icons.text_fields,
                              title: PwfAccessibilityI18n.of(
                                context,
                              ).t(PwfAccKey.fontTitle),
                              description: PwfAccessibilityI18n.of(
                                context,
                              ).t(PwfAccKey.fontDesc),
                              child: PwfFontSizeControl(
                                scheme: scheme,
                                fontPx: settings.fontPx,
                                onDecrease: notifier.decreaseFont,
                                onIncrease: notifier.increaseFont,
                              ),
                            ),
                            PwfFeatureCard(
                              scheme: scheme,
                              topBorderColor: scheme.primary,
                              icon: Icons.contrast,
                              title: PwfAccessibilityI18n.of(
                                context,
                              ).t(PwfAccKey.contrastTitle),
                              description: PwfAccessibilityI18n.of(
                                context,
                              ).t(PwfAccKey.contrastDesc),
                              child: Column(
                                children: [
                                  const SizedBox(height: 10),
                                  PwfPrimaryButton(
                                    scheme: scheme,
                                    onPressed: notifier.toggleHighContrast,
                                    label: settings.highContrast
                                        ? PwfAccessibilityI18n.of(
                                            context,
                                          ).t(PwfAccKey.contrastOff)
                                        : PwfAccessibilityI18n.of(
                                            context,
                                          ).t(PwfAccKey.contrastOn),
                                  ),
                                  const SizedBox(height: 14),
                                  PwfInfoLine(
                                    scheme: scheme,
                                    text: PwfAccessibilityI18n.of(
                                      context,
                                    ).t(PwfAccKey.contrastHint),
                                  ),
                                ],
                              ),
                            ),
                            PwfFeatureCard(
                              scheme: scheme,
                              topBorderColor: scheme.primary,
                              icon: Icons.menu_book,
                              title: PwfAccessibilityI18n.of(
                                context,
                              ).t(PwfAccKey.readingTitle),
                              description: PwfAccessibilityI18n.of(
                                context,
                              ).t(PwfAccKey.readingDesc),
                              child: Column(
                                children: [
                                  const SizedBox(height: 10),
                                  PwfSecondaryButton(
                                    scheme: scheme,
                                    onPressed: notifier.toggleReadingMode,
                                    label: settings.readingMode
                                        ? PwfAccessibilityI18n.of(
                                            context,
                                          ).t(PwfAccKey.readingOff)
                                        : PwfAccessibilityI18n.of(
                                            context,
                                          ).t(PwfAccKey.readingOn),
                                  ),
                                  const SizedBox(height: 14),
                                  PwfInfoLine(
                                    scheme: scheme,
                                    text: PwfAccessibilityI18n.of(
                                      context,
                                    ).t(PwfAccKey.readingHint),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        PwfCustomInterfacesCard(
                          scheme: scheme,
                          activePreset: settings.preset,
                          onPickSenior: () {
                            notifier.setPreset(PwfAccessibilityPreset.senior);
                            _snack(
                              context,
                              scheme,
                              PwfAccessibilityI18n.of(
                                context,
                              ).t(PwfAccKey.snackSenior),
                            );
                          },
                          onPickKids: () {
                            notifier.setPreset(PwfAccessibilityPreset.kids);
                            _snack(
                              context,
                              scheme,
                              PwfAccessibilityI18n.of(
                                context,
                              ).t(PwfAccKey.snackKids),
                            );
                          },
                          onPickRecitation: () {
                            notifier.setPreset(
                              PwfAccessibilityPreset.recitation,
                            );
                            _snack(
                              context,
                              scheme,
                              PwfAccessibilityI18n.of(
                                context,
                              ).t(PwfAccKey.snackRecitation),
                            );
                          },
                          onReset: () {
                            notifier.reset();
                            _snack(
                              context,
                              scheme,
                              PwfAccessibilityI18n.of(
                                context,
                              ).t(PwfAccKey.snackReset),
                            );
                          },
                        ),
                        const SizedBox(height: 50),
                        PwfTipsCard(scheme: scheme),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static void _snack(
    BuildContext context,
    PwfAccessibilityScheme scheme,
    String text,
  ) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(text, textAlign: TextAlign.right),
          backgroundColor: scheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

/* -----------------------------  i18n (feature-local, ar/en) ----------------------------- */

enum PwfAccKey {
  pageTitle,
  pageSubtitle,

  fontTitle,
  fontDesc,

  contrastTitle,
  contrastDesc,
  contrastOn,
  contrastOff,
  contrastHint,

  readingTitle,
  readingDesc,
  readingOn,
  readingOff,
  readingHint,

  customTitle,
  customSubtitle,

  seniorTitle,
  seniorDesc,
  seniorAuto,

  kidsTitle,
  kidsDesc,
  kidsHint,

  recitationTitle,
  recitationDesc,
  recitationHint,

  reset,

  tipsTitle,
  tipDeviceTitle,
  tipDeviceDesc,
  tipLightTitle,
  tipLightDesc,
  tipBreaksTitle,
  tipBreaksDesc,

  snackSenior,
  snackKids,
  snackRecitation,
  snackReset,

  incFontSem,
  decFontSem,
}

class PwfAccessibilityI18n {
  const PwfAccessibilityI18n(this.locale);

  final Locale locale;

  static PwfAccessibilityI18n of(BuildContext context) {
    return PwfAccessibilityI18n(Localizations.localeOf(context));
  }

  String t(PwfAccKey key) {
    final code = locale.languageCode.toLowerCase();
    final map = code == 'en' ? _en : _ar;
    return map[key] ?? _ar[key] ?? key.name;
  }

  static const Map<PwfAccKey, String> _ar = {
    PwfAccKey.pageTitle: 'إمكانية الوصول',
    PwfAccKey.pageSubtitle:
        'تهيئة المنصة لتلائم احتياجات جميع المستخدمين بسهولة وسلاسة',
    PwfAccKey.fontTitle: 'تكبير وتصغير الخط',
    PwfAccKey.fontDesc: 'تعديل حجم النص حسب راحتك ورؤيتك',
    PwfAccKey.contrastTitle: 'التباين العالي',
    PwfAccKey.contrastDesc:
        'تفعيل وضع التباين العالي لتحسين وضوح النصوص والعناصر',
    PwfAccKey.contrastOn: 'تفعيل التباين العالي',
    PwfAccKey.contrastOff: 'إلغاء التباين العالي',
    PwfAccKey.contrastHint: 'مناسب للمصابين بمشاكل في الرؤية',
    PwfAccKey.readingTitle: 'وضع القراءة',
    PwfAccKey.readingDesc: 'وضع مخصص للقراءة المريحة مع خلفية ملائمة',
    PwfAccKey.readingOn: 'تفعيل وضع القراءة',
    PwfAccKey.readingOff: 'إلغاء وضع القراءة',
    PwfAccKey.readingHint: 'يقلل إجهاد العين أثناء القراءة الطويلة',
    PwfAccKey.customTitle: 'واجهات مخصصة',
    PwfAccKey.customSubtitle: 'اختر الواجهة المناسبة لك من الخيارات التالية',
    PwfAccKey.seniorTitle: 'واجهة كبار السن',
    PwfAccKey.seniorDesc: 'خطوط كبيرة، ألوان واضحة، تبسيط الواجهة',
    PwfAccKey.seniorAuto: 'تلقائياً: تكبير الخط + تباين عالي',
    PwfAccKey.kidsTitle: 'واجهة الأطفال',
    PwfAccKey.kidsDesc: 'ألوان زاهية، رسومات جذابة، تبسيط المحتوى',
    PwfAccKey.kidsHint: 'مصممة للأعمار من 6-12 سنة',
    PwfAccKey.recitationTitle: 'وضع التلاوة',
    PwfAccKey.recitationDesc: 'خلفية مريحة، تباعد بين الأسطر، تركيز على النص',
    PwfAccKey.recitationHint: 'مثالي لقراءة القرآن والمواد الدينية',
    PwfAccKey.reset: 'إعادة الضبط إلى الوضع الافتراضي',
    PwfAccKey.tipsTitle: 'نصائح لتحسين تجربة الاستخدام',
    PwfAccKey.tipDeviceTitle: 'اختيار جهاز مناسب',
    PwfAccKey.tipDeviceDesc: 'استخدام شاشة كبيرة مع دقة عالية يسهل القراءة',
    PwfAccKey.tipLightTitle: 'إضاءة مناسبة',
    PwfAccKey.tipLightDesc: 'تأكد من وجود إضاءة كافية في مكان الجلوس',
    PwfAccKey.tipBreaksTitle: 'فترات راحة',
    PwfAccKey.tipBreaksDesc: 'خذ فترات راحة منتظمة عند القراءة لفترات طويلة',
    PwfAccKey.snackSenior: 'تم تفعيل واجهة كبار السن',
    PwfAccKey.snackKids: 'تم تفعيل واجهة الأطفال',
    PwfAccKey.snackRecitation: 'تم تفعيل وضع التلاوة',
    PwfAccKey.snackReset: 'تم إعادة جميع الإعدادات إلى الوضع الافتراضي',
    PwfAccKey.incFontSem: 'تكبير الخط',
    PwfAccKey.decFontSem: 'تصغير الخط',
  };

  static const Map<PwfAccKey, String> _en = {
    PwfAccKey.pageTitle: 'Accessibility',
    PwfAccKey.pageSubtitle:
        'Make the platform easier for all users to use smoothly',
    PwfAccKey.fontTitle: 'Text size',
    PwfAccKey.fontDesc: 'Adjust text size to your comfort',
    PwfAccKey.contrastTitle: 'High contrast',
    PwfAccKey.contrastDesc: 'Enable high contrast to improve readability',
    PwfAccKey.contrastOn: 'Enable high contrast',
    PwfAccKey.contrastOff: 'Disable high contrast',
    PwfAccKey.contrastHint: 'Helpful for users with low vision',
    PwfAccKey.readingTitle: 'Reading mode',
    PwfAccKey.readingDesc: 'A comfortable background for long reading',
    PwfAccKey.readingOn: 'Enable reading mode',
    PwfAccKey.readingOff: 'Disable reading mode',
    PwfAccKey.readingHint: 'Reduces eye strain during long sessions',
    PwfAccKey.customTitle: 'Custom interfaces',
    PwfAccKey.customSubtitle: 'Choose the interface that fits you best',
    PwfAccKey.seniorTitle: 'Senior interface',
    PwfAccKey.seniorDesc: 'Large text, clear colors, simplified UI',
    PwfAccKey.seniorAuto: 'Auto: larger text + high contrast',
    PwfAccKey.kidsTitle: 'Kids interface',
    PwfAccKey.kidsDesc: 'Bright colors, friendly visuals, simplified content',
    PwfAccKey.kidsHint: 'Designed for ages 6–12',
    PwfAccKey.recitationTitle: 'Recitation mode',
    PwfAccKey.recitationDesc:
        'Comfortable background, better spacing, text-focused',
    PwfAccKey.recitationHint: 'Ideal for Quran and religious reading',
    PwfAccKey.reset: 'Reset to default',
    PwfAccKey.tipsTitle: 'Tips for better experience',
    PwfAccKey.tipDeviceTitle: 'Pick a suitable device',
    PwfAccKey.tipDeviceDesc:
        'A larger high-resolution screen improves readability',
    PwfAccKey.tipLightTitle: 'Good lighting',
    PwfAccKey.tipLightDesc: 'Make sure your area has enough light',
    PwfAccKey.tipBreaksTitle: 'Take breaks',
    PwfAccKey.tipBreaksDesc: 'Take regular breaks during long reading',
    PwfAccKey.snackSenior: 'Senior interface enabled',
    PwfAccKey.snackKids: 'Kids interface enabled',
    PwfAccKey.snackRecitation: 'Recitation mode enabled',
    PwfAccKey.snackReset: 'All settings reset to default',
    PwfAccKey.incFontSem: 'Increase text size',
    PwfAccKey.decFontSem: 'Decrease text size',
  };
}

/* -----------------------------  Scheme (page-local “CSS vars”) ----------------------------- */

@immutable
class PwfAccessibilityScheme {
  const PwfAccessibilityScheme({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.bg,
    required this.card,
    required this.text,
    required this.muted,
    required this.shadow,
    required this.shadowHover,
    required this.radius,
  });

  final Color primary;
  final Color secondary;
  final Color accent;
  final Color bg;
  final Color card;
  final Color text;
  final Color muted;
  final List<BoxShadow> shadow;
  final List<BoxShadow> shadowHover;
  final double radius;

  static PwfAccessibilityScheme from(PwfAccessibilitySettings s) {
    Color primary = const Color(0xFF0D3C61);
    Color secondary = const Color(0xFFC19A50);
    Color accent = const Color(0xFF2A6E3F);

    Color bg = const Color(0xFFF5F7FA);
    Color card = const Color(0xFFFFFFFF);
    Color text = const Color(0xFF1A1A1A);
    Color muted = const Color(0xFF6C757D);

    if (s.readingMode) {
      bg = const Color(0xFFF5F0E6);
      card = const Color(0xFFFFFAF0);
      text = const Color(0xFF333333);
      muted = const Color(0xFF6C757D);
    }

    if (s.highContrast) {
      primary = const Color(0xFF000000);
      secondary = const Color(0xFFFFFF00);
      accent = const Color(0xFF008000);
      bg = const Color(0xFFFFFFFF);
      card = const Color(0xFFFFFFFF);
      text = const Color(0xFF000000);
      muted = const Color(0xFF000000);
    }

    switch (s.preset) {
      case PwfAccessibilityPreset.senior:
        primary = const Color(0xFF4A148C);
        break;
      case PwfAccessibilityPreset.kids:
        primary = const Color(0xFF4A148C);
        secondary = const Color(0xFFFF9800);
        accent = const Color(0xFF0097A7);
        break;
      case PwfAccessibilityPreset.recitation:
        break;
      case PwfAccessibilityPreset.none:
        break;
    }

    final shadow = <BoxShadow>[
      BoxShadow(
        color: Colors.black.withAlpha(20),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ];
    final shadowHover = <BoxShadow>[
      BoxShadow(
        color: Colors.black.withAlpha(31),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ];

    return PwfAccessibilityScheme(
      primary: primary,
      secondary: secondary,
      accent: accent,
      bg: bg,
      card: card,
      text: text,
      muted: muted,
      shadow: shadow,
      shadowHover: shadowHover,
      radius: 8,
    );
  }
}

/* -----------------------------  UI Widgets ----------------------------- */

class PwfAccessibilitySectionTitle extends StatelessWidget {
  const PwfAccessibilitySectionTitle({super.key, required this.scheme});

  final PwfAccessibilityScheme scheme;

  @override
  Widget build(BuildContext context) {
    final i18n = PwfAccessibilityI18n.of(context);
    return Column(
      children: [
        Text(
          i18n.t(PwfAccKey.pageTitle),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: scheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Text(
            i18n.t(PwfAccKey.pageSubtitle),
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: scheme.muted, height: 1.6),
          ),
        ),
      ],
    );
  }
}

class PwfResponsiveGrid extends StatelessWidget {
  const PwfResponsiveGrid({
    super.key,
    required this.children,
    required this.minTileWidth,
    required this.gap,
  });

  final List<Widget> children;
  final double minTileWidth;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final cols = (w / (minTileWidth + gap)).floor().clamp(1, 4);
        return GridView.count(
          crossAxisCount: cols,
          mainAxisSpacing: gap,
          crossAxisSpacing: gap,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: cols == 1 ? 1.15 : 1.05,
          children: children,
        );
      },
    );
  }
}

class PwfFeatureCard extends StatelessWidget {
  const PwfFeatureCard({
    super.key,
    required this.scheme,
    required this.icon,
    required this.title,
    required this.description,
    required this.child,
    required this.topBorderColor,
  });

  final PwfAccessibilityScheme scheme;
  final IconData icon;
  final String title;
  final String description;
  final Widget child;
  final Color topBorderColor;

  @override
  Widget build(BuildContext context) {
    return PwfHoverLift(
      radius: scheme.radius,
      child: Container(
        decoration: BoxDecoration(
          color: scheme.card,
          borderRadius: BorderRadius.circular(scheme.radius),
          boxShadow: scheme.shadow,
          border: Border(top: BorderSide(color: topBorderColor, width: 4)),
        ),
        padding: const EdgeInsetsDirectional.fromSTEB(30, 30, 30, 30),
        child: Column(
          children: [
            Icon(icon, size: 48, color: scheme.primary),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.muted,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class PwfFontSizeControl extends StatelessWidget {
  const PwfFontSizeControl({
    super.key,
    required this.scheme,
    required this.fontPx,
    required this.onDecrease,
    required this.onIncrease,
  });

  final PwfAccessibilityScheme scheme;
  final int fontPx;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    final i18n = PwfAccessibilityI18n.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Semantics(
            button: true,
            label: i18n.t(PwfAccKey.decFontSem),
            child: PwfCircleIconButton(
              scheme: scheme,
              icon: Icons.remove,
              onPressed: onDecrease,
            ),
          ),
          const SizedBox(width: 18),
          Text(
            '${fontPx}px',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 18),
          Semantics(
            button: true,
            label: i18n.t(PwfAccKey.incFontSem),
            child: PwfCircleIconButton(
              scheme: scheme,
              icon: Icons.add,
              onPressed: onIncrease,
            ),
          ),
        ],
      ),
    );
  }
}

class PwfCircleIconButton extends StatefulWidget {
  const PwfCircleIconButton({
    super.key,
    required this.scheme,
    required this.icon,
    required this.onPressed,
  });

  final PwfAccessibilityScheme scheme;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  State<PwfCircleIconButton> createState() => PwfCircleIconButtonState();
}

class PwfCircleIconButtonState extends State<PwfCircleIconButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final bg = _hover ? widget.scheme.secondary : widget.scheme.primary;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 150),
        scale: _hover ? 1.08 : 1.0,
        child: InkWell(
          onTap: widget.onPressed,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Icon(widget.icon, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }
}

class PwfPrimaryButton extends StatelessWidget {
  const PwfPrimaryButton({
    super.key,
    required this.scheme,
    required this.label,
    required this.onPressed,
  });

  final PwfAccessibilityScheme scheme;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return PwfFilledButton(
      bg: scheme.primary,
      fg: Colors.white,
      label: label,
      onPressed: onPressed,
    );
  }
}

class PwfSecondaryButton extends StatelessWidget {
  const PwfSecondaryButton({
    super.key,
    required this.scheme,
    required this.label,
    required this.onPressed,
  });

  final PwfAccessibilityScheme scheme;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return PwfFilledButton(
      bg: scheme.secondary,
      fg: Colors.white,
      label: label,
      onPressed: onPressed,
    );
  }
}

class PwfFilledButton extends StatefulWidget {
  const PwfFilledButton({
    super.key,
    required this.bg,
    required this.fg,
    required this.label,
    required this.onPressed,
  });

  final Color bg;
  final Color fg;
  final String label;
  final VoidCallback onPressed;

  @override
  State<PwfFilledButton> createState() => PwfFilledButtonState();
}

class PwfFilledButtonState extends State<PwfFilledButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final bg = _hover ? _darken(widget.bg) : widget.bg;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          onTap: widget.onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 10),
            child: Text(
              widget.label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: widget.fg,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _darken(Color c) {
    final r = (c.red * 0.90).round().clamp(0, 255);
    final g = (c.green * 0.90).round().clamp(0, 255);
    final b = (c.blue * 0.90).round().clamp(0, 255);
    return Color.fromARGB(c.alpha, r, g, b);
  }
}

class PwfInfoLine extends StatelessWidget {
  const PwfInfoLine({super.key, required this.scheme, required this.text});

  final PwfAccessibilityScheme scheme;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.info_outline, size: 18, color: scheme.muted),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: scheme.muted, height: 1.5),
          ),
        ),
      ],
    );
  }
}

class PwfCustomInterfacesCard extends StatelessWidget {
  const PwfCustomInterfacesCard({
    super.key,
    required this.scheme,
    required this.activePreset,
    required this.onPickSenior,
    required this.onPickKids,
    required this.onPickRecitation,
    required this.onReset,
  });

  final PwfAccessibilityScheme scheme;
  final PwfAccessibilityPreset activePreset;

  final VoidCallback onPickSenior;
  final VoidCallback onPickKids;
  final VoidCallback onPickRecitation;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final i18n = PwfAccessibilityI18n.of(context);

    return Container(
      decoration: BoxDecoration(
        color: scheme.primary.withAlpha(13),
        borderRadius: BorderRadius.circular(scheme.radius),
      ),
      padding: const EdgeInsetsDirectional.fromSTEB(50, 50, 50, 50),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.manage_accounts, color: scheme.primary, size: 24),
              const SizedBox(width: 10),
              Text(
                i18n.t(PwfAccKey.customTitle),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            i18n.t(PwfAccKey.customSubtitle),
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: scheme.muted),
          ),
          const SizedBox(height: 30),
          PwfResponsiveGrid(
            minTileWidth: 250,
            gap: 20,
            children: [
              PwfInterfaceCard(
                scheme: scheme,
                isActive: activePreset == PwfAccessibilityPreset.senior,
                icon: Icons.groups,
                iconColor: const Color(0xFF4A148C),
                title: i18n.t(PwfAccKey.seniorTitle),
                description: i18n.t(PwfAccKey.seniorDesc),
                footNote: i18n.t(PwfAccKey.seniorAuto),
                footBg: const Color(0xFF4A148C).withAlpha(26),
                onTap: onPickSenior,
                activeBorderColor: scheme.accent,
              ),
              PwfInterfaceCard(
                scheme: scheme,
                isActive: activePreset == PwfAccessibilityPreset.kids,
                icon: Icons.child_care,
                iconColor: const Color(0xFFFF9800),
                title: i18n.t(PwfAccKey.kidsTitle),
                description: i18n.t(PwfAccKey.kidsDesc),
                footNote: i18n.t(PwfAccKey.kidsHint),
                footBg: const Color(0xFFFF9800).withAlpha(26),
                onTap: onPickKids,
                activeBorderColor: scheme.accent,
              ),
              PwfInterfaceCard(
                scheme: scheme,
                isActive: activePreset == PwfAccessibilityPreset.recitation,
                icon: Icons.menu_book,
                iconColor: const Color(0xFF2A6E3F),
                title: i18n.t(PwfAccKey.recitationTitle),
                description: i18n.t(PwfAccKey.recitationDesc),
                footNote: i18n.t(PwfAccKey.recitationHint),
                footBg: const Color(0xFF2A6E3F).withAlpha(26),
                onTap: onPickRecitation,
                activeBorderColor: scheme.accent,
              ),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.restart_alt, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              SizedBox(
                height: 44,
                child: PwfPrimaryButton(
                  scheme: scheme,
                  onPressed: onReset,
                  label: i18n.t(PwfAccKey.reset),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PwfInterfaceCard extends StatefulWidget {
  const PwfInterfaceCard({
    super.key,
    required this.scheme,
    required this.isActive,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.footNote,
    required this.footBg,
    required this.onTap,
    required this.activeBorderColor,
  });

  final PwfAccessibilityScheme scheme;
  final bool isActive;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final String footNote;
  final Color footBg;
  final VoidCallback onTap;
  final Color activeBorderColor;

  @override
  State<PwfInterfaceCard> createState() => PwfInterfaceCardState();
}

class PwfInterfaceCardState extends State<PwfInterfaceCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final border = widget.isActive
        ? Border.all(color: widget.activeBorderColor, width: 3)
        : Border.all(color: Colors.transparent, width: 3);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 170),
        curve: Curves.easeOut,
        scale: _hover ? 1.03 : 1.0,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(widget.scheme.radius),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(widget.scheme.radius),
              boxShadow: widget.scheme.shadow,
              border: border,
            ),
            padding: const EdgeInsetsDirectional.fromSTEB(25, 25, 25, 25),
            child: Column(
              children: [
                Icon(widget.icon, size: 40, color: widget.iconColor),
                const SizedBox(height: 14),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: widget.scheme.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.description,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: widget.scheme.muted,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: widget.footBg,
                    borderRadius: BorderRadius.circular(widget.scheme.radius),
                  ),
                  padding: const EdgeInsetsDirectional.fromSTEB(10, 8, 10, 8),
                  child: Text(
                    widget.footNote,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: widget.scheme.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PwfTipsCard extends StatelessWidget {
  const PwfTipsCard({super.key, required this.scheme});

  final PwfAccessibilityScheme scheme;

  @override
  Widget build(BuildContext context) {
    final i18n = PwfAccessibilityI18n.of(context);

    return Container(
      decoration: BoxDecoration(
        color: scheme.card,
        borderRadius: BorderRadius.circular(scheme.radius),
        boxShadow: scheme.shadow,
      ),
      padding: const EdgeInsetsDirectional.fromSTEB(30, 30, 30, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: scheme.primary, size: 22),
              const SizedBox(width: 10),
              Text(
                i18n.t(PwfAccKey.tipsTitle),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          PwfResponsiveGrid(
            minTileWidth: 250,
            gap: 20,
            children: [
              PwfTipItem(
                scheme: scheme,
                borderColor: scheme.secondary,
                icon: Icons.desktop_windows,
                title: i18n.t(PwfAccKey.tipDeviceTitle),
                description: i18n.t(PwfAccKey.tipDeviceDesc),
              ),
              PwfTipItem(
                scheme: scheme,
                borderColor: scheme.accent,
                icon: Icons.wb_sunny_outlined,
                title: i18n.t(PwfAccKey.tipLightTitle),
                description: i18n.t(PwfAccKey.tipLightDesc),
              ),
              PwfTipItem(
                scheme: scheme,
                borderColor: scheme.primary,
                icon: Icons.pause_circle_outline,
                title: i18n.t(PwfAccKey.tipBreaksTitle),
                description: i18n.t(PwfAccKey.tipBreaksDesc),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PwfTipItem extends StatelessWidget {
  const PwfTipItem({
    super.key,
    required this.scheme,
    required this.borderColor,
    required this.icon,
    required this.title,
    required this.description,
  });

  final PwfAccessibilityScheme scheme;
  final Color borderColor;
  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(15, 15, 15, 15),
      decoration: BoxDecoration(
        border: BorderDirectional(
          end: BorderSide(color: borderColor, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: scheme.text),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: scheme.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: scheme.muted, height: 1.6),
          ),
        ],
      ),
    );
  }
}

class PwfHoverLift extends StatefulWidget {
  const PwfHoverLift({super.key, required this.child, required this.radius});

  final Widget child;
  final double radius;

  @override
  State<PwfHoverLift> createState() => PwfHoverLiftState();
}

class PwfHoverLiftState extends State<PwfHoverLift> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        transform: Matrix4.identity()..translate(0.0, _hover ? -10.0 : 0.0),
        child: widget.child,
      ),
    );
  }
}
