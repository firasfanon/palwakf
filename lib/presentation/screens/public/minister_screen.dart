import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:waqf/core/constants/app_constants.dart';
import 'package:waqf/data/repositories/homepage_repository.dart'
    show MinisterSectionSettings;
import 'package:waqf/features/platform/home/data/models/pwf_site_page.dart';
import 'package:waqf/features/platform/home/data/providers/pwf_site_pages_providers.dart';
import 'package:waqf/features/platform/home/presentation/screens/pwf_web_page_scaffold.dart';
import 'package:waqf/presentation/providers/homepage_settings_provider.dart';

class MinisterScreen extends ConsumerWidget {
  const MinisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSettings = ref.watch(ministerSectionProvider);
    final cmsPageAsync = ref.watch(pwfGlobalSitePageProvider('minister'));

    final vm = _MinisterPageVm.fromSources(
      cmsPage: cmsPageAsync.valueOrNull,
      settings: asyncSettings.maybeWhen(
        data: (settings) => settings,
        orElse: () => null,
      ),
    );

    final body = _MinisterPageBody(
      vm: vm,
      isLoading: asyncSettings.isLoading || cmsPageAsync.isLoading,
      cmsPublished: cmsPageAsync.valueOrNull?.isPublished ?? true,
      cmsUpdatedAt: cmsPageAsync.valueOrNull?.updatedAt,
    );

    if (kIsWeb) {
      return PwfWebPageScaffold(
        unitSlug: 'home',
        title: 'كلمة الوزير',
        showTitleSection: false,
        child: body,
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7FB),
        appBar: AppBar(title: const Text('كلمة الوزير'), centerTitle: true),
        body: SafeArea(child: body),
      ),
    );
  }
}

class _MinisterPageBody extends StatelessWidget {
  const _MinisterPageBody({
    required this.vm,
    required this.isLoading,
    required this.cmsPublished,
    required this.cmsUpdatedAt,
  });

  final _MinisterPageVm vm;
  final bool isLoading;
  final bool cmsPublished;
  final DateTime? cmsUpdatedAt;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF8FAFD), Color(0xFFF1F5FA)],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1320),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _MinisterHero(vm: vm),
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: _LoadingHint(),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _MinisterCmsStatusBar(
                      isPublished: cmsPublished,
                      updatedAt: cmsUpdatedAt,
                    ),
                  ),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 980;
                    if (wide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 360,
                            child: Column(
                              children: [
                                _MinisterProfileCard(vm: vm),
                                const SizedBox(height: 18),
                                _MinisterContactCard(vm: vm),
                              ],
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              children: [
                                _MinisterMessageCard(vm: vm),
                                const SizedBox(height: 18),
                                _MinisterPrioritiesCard(vm: vm),
                              ],
                            ),
                          ),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        _MinisterProfileCard(vm: vm),
                        const SizedBox(height: 18),
                        _MinisterMessageCard(vm: vm),
                        const SizedBox(height: 18),
                        _MinisterPrioritiesCard(vm: vm),
                        const SizedBox(height: 18),
                        _MinisterContactCard(vm: vm),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MinisterHero extends StatelessWidget {
  const _MinisterHero({required this.vm});

  final _MinisterPageVm vm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF0F2C55), Color(0xFF144A75)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final wide = c.maxWidth >= 980;
          final info = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                  ),
                ),
                child: const Text(
                  'منصة الأوقاف الفلسطينية',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'كلمة الوزير',
                style: TextStyle(
                  fontSize: 34,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                vm.headline,
                style: TextStyle(
                  fontSize: 17,
                  height: 1.8,
                  color: Colors.white.withValues(alpha: 0.92),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          );

          final quote = Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '❝',
                  style: TextStyle(
                    fontSize: 42,
                    color: Color(0xFFD4AF37),
                    height: 1,
                  ),
                ),
                Text(
                  vm.quote,
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.9,
                    color: Colors.white.withValues(alpha: 0.98),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          );

          if (wide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: info),
                const SizedBox(width: 24),
                Expanded(flex: 2, child: quote),
              ],
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [info, const SizedBox(height: 18), quote],
          );
        },
      ),
    );
  }
}

class _MinisterProfileCard extends StatelessWidget {
  const _MinisterProfileCard({required this.vm});

  final _MinisterPageVm vm;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        children: [
          Container(
            width: 180,
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: const Color(0xFFD4AF37), width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: vm.imageUrl.trim().isEmpty
                ? _ImagePlaceholder(name: vm.name)
                : Image.network(
                    vm.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _ImagePlaceholder(name: vm.name),
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
          ),
          const SizedBox(height: 18),
          Text(
            vm.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F2C55),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            vm.position,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFFB08A40),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 18),
          const Divider(height: 1),
          const SizedBox(height: 18),
          ...vm.profileHighlights.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _MiniInfoRow(icon: item.$1, text: item.$2),
            ),
          ),
        ],
      ),
    );
  }
}

class _MinisterMessageCard extends StatelessWidget {
  const _MinisterMessageCard({required this.vm});

  final _MinisterPageVm vm;

  @override
  Widget build(BuildContext context) {
    final paragraphs = vm.bodyParagraphs;
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.format_quote_rounded,
            title: 'نص كلمة الوزير',
            subtitle:
                'الرسالة العامة الموجهة للجمهور حول دور الوزارة ورسالتها السيادية.',
          ),
          const SizedBox(height: 20),
          for (final paragraph in paragraphs) ...[
            Text(
              paragraph,
              textAlign: TextAlign.justify,
              style: const TextStyle(
                fontSize: 18,
                height: 2.0,
                color: Color(0xFF24364A),
              ),
            ),
            const SizedBox(height: 14),
          ],
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vm.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F2C55),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  vm.position,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF7A8796),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MinisterPrioritiesCard extends StatelessWidget {
  const _MinisterPrioritiesCard({required this.vm});

  final _MinisterPageVm vm;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.flag_circle_rounded,
            title: 'الأولويات والمحاور',
            subtitle:
                'ملخص تنفيذي للمضامين التي تعكس توجه الوزارة في الإدارة والخدمة العامة.',
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: vm.priorities
                .map(
                  (item) => Container(
                    width: 280,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFD),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE1E7EE)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF0D4B7A),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.8,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF24364A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _MinisterContactCard extends StatelessWidget {
  const _MinisterContactCard({required this.vm});

  final _MinisterPageVm vm;

  @override
  Widget build(BuildContext context) {
    return _CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.contact_mail_rounded,
            title: 'بيانات التواصل',
            subtitle:
                'قنوات التواصل المرجعية المرتبطة بمكتب الوزير ضمن بيانات المنصة الحالية.',
          ),
          const SizedBox(height: 18),
          _MiniInfoRow(icon: Icons.email_rounded, text: vm.email),
          const SizedBox(height: 12),
          _MiniInfoRow(icon: Icons.phone_rounded, text: vm.phone),
          const SizedBox(height: 12),
          _MiniInfoRow(icon: Icons.location_on_rounded, text: vm.address),
        ],
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE6EBF1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFF0D4B7A).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: const Color(0xFF0D4B7A)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F2C55),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.7,
                  color: Color(0xFF6B7785),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniInfoRow extends StatelessWidget {
  const _MiniInfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF0D4B7A)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              height: 1.7,
              color: Color(0xFF24364A),
            ),
          ),
        ),
      ],
    );
  }
}

class _LoadingHint extends StatelessWidget {
  const _LoadingHint();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        SizedBox(width: 10),
        Text(
          'جارِ تحميل بيانات كلمة الوزير من الإعدادات المعتمدة',
          style: TextStyle(fontSize: 13, color: Color(0xFF6B7785)),
        ),
      ],
    );
  }
}

class _MinisterCmsStatusBar extends StatelessWidget {
  const _MinisterCmsStatusBar({
    required this.isPublished,
    required this.updatedAt,
  });

  final bool isPublished;
  final DateTime? updatedAt;

  @override
  Widget build(BuildContext context) {
    final updatedLabel = updatedAt == null
        ? 'لم يتم تسجيل وقت تحديث بعد'
        : 'آخر تحديث: ${updatedAt!.toLocal().toString().substring(0, 16)}';

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        _StatusChip(
          icon: isPublished
              ? Icons.cloud_done_outlined
              : Icons.edit_note_outlined,
          label: isPublished
              ? 'مرتبطة بمحتوى منشور من site_pages'
              : 'مرتبطة بمحتوى draft من site_pages',
          color: isPublished
              ? const Color(0xFF0D7A46)
              : const Color(0xFF92400E),
        ),
        _StatusChip(
          icon: Icons.update_outlined,
          label: updatedLabel,
          color: const Color(0xFF0F2C55),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFEEF3F8),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_rounded, size: 72, color: Color(0xFF0D4B7A)),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F2C55),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MinisterPageVm {
  const _MinisterPageVm({
    required this.name,
    required this.position,
    required this.quote,
    required this.headline,
    required this.bodyParagraphs,
    required this.imageUrl,
    required this.profileHighlights,
    required this.priorities,
    required this.email,
    required this.phone,
    required this.address,
  });

  final String name;
  final String position;
  final String quote;
  final String headline;
  final List<String> bodyParagraphs;
  final String imageUrl;
  final List<(IconData, String)> profileHighlights;
  final List<String> priorities;
  final String email;
  final String phone;
  final String address;

  factory _MinisterPageVm.fromSources({
    required PwfSitePage? cmsPage,
    required MinisterSectionSettings? settings,
  }) {
    final s = settings;
    final cmsTitle = (cmsPage?.titleAr ?? '').trim();
    final cmsSubtitle = (cmsPage?.subtitleAr ?? '').trim();
    final cmsBody = (cmsPage?.bodyAr ?? '').trim();
    final settingsMessage = (s?.message ?? '').trim();

    final resolvedMessage = cmsBody.isNotEmpty
        ? cmsBody
        : (settingsMessage.isNotEmpty
              ? settingsMessage
              : fallback.bodyParagraphs.join('\n\n'));

    final paragraphs = resolvedMessage
        .split(RegExp(r'\n\s*\n|\n'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);

    final headline = cmsSubtitle.isNotEmpty
        ? cmsSubtitle
        : (cmsTitle.isNotEmpty
              ? cmsTitle
              : 'رسالة الوزارة ورؤيتها في خدمة الدين والوقف والمسجد والمجتمع ضمن إطار سيادي منضبط.');

    return _MinisterPageVm(
      name: (s?.name ?? '').trim().isEmpty ? fallback.name : s!.name.trim(),
      position: (s?.position ?? '').trim().isEmpty
          ? fallback.position
          : s!.position.trim(),
      quote: paragraphs.isNotEmpty ? paragraphs.first : fallback.quote,
      headline: headline,
      bodyParagraphs: paragraphs.isEmpty ? fallback.bodyParagraphs : paragraphs,
      imageUrl: (s?.imageUrl ?? '').trim().isEmpty
          ? fallback.imageUrl
          : s!.imageUrl.trim(),
      profileHighlights: fallback.profileHighlights,
      priorities: fallback.priorities,
      email: fallback.email,
      phone: fallback.phone,
      address: fallback.address,
    );
  }

  static final fallback = _MinisterPageVm(
    name: 'د. محمود الهباش',
    position: 'وزير الأوقاف والشؤون الدينية',
    quote:
        'يسعدني أن أرحب بكم في الموقع الإلكتروني لوزارة الأوقاف والشؤون الدينية الفلسطينية. نسعى إلى خدمة المساجد والأوقاف وتعزيز القيم الإسلامية السمحة في مجتمعنا.',
    headline:
        'صفحة داخلية رسمية تعرض كلمة الوزير ضمن هوية المنصة العامة، وبربط مباشر مع إعدادات الصفحة الرئيسية بدل الاعتماد على صفحة قديمة منفصلة.',
    bodyParagraphs: const [
      'بسم الله الرحمن الرحيم، يسعدني أن أرحب بكم في الموقع الإلكتروني لوزارة الأوقاف والشؤون الدينية الفلسطينية. نسعى في هذه الوزارة إلى خدمة المساجد والأوقاف الإسلامية في جميع أنحاء فلسطين، والعمل على تعزيز القيم الإسلامية السمحة في مجتمعنا.',
      'إن رسالتنا تتمثل في الحفاظ على المقدسات الإسلامية، وإدارة الأوقاف بكفاءة وشفافية، وتوفير الخدمات الدينية للمواطنين، ونشر الوعي الديني الصحيح.',
      'نحن ملتزمون بتطوير عمل الوزارة وتحديثه، والاستفادة من التكنولوجيا الحديثة لتسهيل تقديم خدماتنا للمواطنين، كما نعمل على تأهيل وتدريب الأئمة والخطباء ليكونوا قدوة حسنة في مجتمعنا.',
    ],
    imageUrl: '',
    profileHighlights: const [
      (
        Icons.school_rounded,
        'خلفية علمية شرعية وأكاديمية في الدراسات الإسلامية.',
      ),
      (
        Icons.account_balance_rounded,
        'متابعة مباشرة لملفات الأوقاف والمساجد والخطاب الديني العام.',
      ),
      (
        Icons.groups_rounded,
        'العمل على تطوير الخدمات الدينية والاجتماعية وتحديث البنية المؤسسية.',
      ),
    ],
    priorities: const [
      'تعزيز الحوكمة والشفافية في إدارة الأوقاف.',
      'رفع كفاءة الخدمات الدينية والرقمية المقدمة للجمهور.',
      'حماية المقدسات والهوية الدينية وتعميق الأثر المجتمعي للمساجد.',
      'تطوير البنية المؤسسية وربط الخدمات العامة ضمن منصة موحدة.',
    ],
    email: 'minister@awqaf.ps',
    phone: AppConstants.phoneNumber,
    address: AppConstants.address,
  );
}
