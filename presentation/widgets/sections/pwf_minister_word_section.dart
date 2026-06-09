import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import 'package:waqf/app/routing/app_routes.dart';
import 'package:waqf/features/platform/public_runtime/presentation/widgets/pwf_public_image_fallback.dart';
import 'package:waqf/presentation/providers/homepage_settings_provider.dart';

import '../../theme/pwf_home_palette.dart';
import '../pwf_section_container.dart';

class PwfMinisterWordSection extends ConsumerWidget {
  const PwfMinisterWordSection({super.key, this.unitSlug = 'home'});

  final String unitSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSettings = ref.watch(ministerSectionProvider);

    final data = asyncSettings.maybeWhen(
      data: (s) {
        if (s == null) return _PwfMinisterVM.fallback;
        return _PwfMinisterVM(
          // Align with existing MinisterSectionSettings model fields.
          name: s.name,
          title: s.position,
          message: s.message,
          imageUrl: s.imageUrl,
          link: s.messageLink.isEmpty ? AppRoutes.minister : s.messageLink,
        );
      },
      orElse: () => _PwfMinisterVM.fallback,
    );

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            PwfHomePalette.primary.withValues(alpha: 0.05),
            PwfHomePalette.secondary.withValues(alpha: 0.05),
          ],
        ),
      ),
      margin: const EdgeInsets.only(bottom: 40),
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: PwfSectionContainer(
        sectionKey: 'PwfMinisterWordSection',
        child: LayoutBuilder(
          builder: (context, c) {
            final wide = c.maxWidth >= 900;
            final image = _MinisterImage(url: data.imageUrl);
            final content = _MinisterContent(vm: data);

            return Column(
              children: [
                Flex(
                  direction: wide ? Axis.horizontal : Axis.vertical,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (wide) ...[
                      Expanded(flex: 1, child: image),
                      const SizedBox(width: 40),
                      Expanded(flex: 2, child: content),
                    ] else ...[
                      image,
                      const SizedBox(height: 24),
                      content,
                    ],
                  ],
                ),
                if (asyncSettings.isLoading) ...[
                  const SizedBox(height: 12),
                  Text(
                    '...جارِ تحميل كلمة الوزير من قاعدة البيانات',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: PwfHomePalette.gray,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MinisterImage extends StatelessWidget {
  const _MinisterImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 300,
        height: 350,
        decoration: BoxDecoration(
          borderRadius: PwfHomeRadii.br8,
          border: Border.all(color: PwfHomePalette.secondary, width: 5),
          boxShadow: PwfHomeShadows.card,
        ),
        clipBehavior: Clip.antiAlias,
        child: PwfPublicImage(
          imageUrl: url,
          fit: BoxFit.cover,
          fallbackColor: Colors.black.withValues(alpha: 0.06),
        ),
      ),
    );
  }
}

class _MinisterContent extends StatefulWidget {
  const _MinisterContent({required this.vm});

  final _PwfMinisterVM vm;

  @override
  State<_MinisterContent> createState() => _MinisterContentState();
}

class _MinisterContentState extends State<_MinisterContent> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'كلمة الوزير',
          style: GoogleFonts.scheherazadeNew(
            fontSize: 35,
            fontWeight: FontWeight.w700,
            color: PwfHomePalette.primary,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 20),
        Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 30),
              child: Text(
                widget.vm.message,
                style: GoogleFonts.cairo(
                  fontSize: 24,
                  fontStyle: FontStyle.italic,
                  color: PwfHomePalette.primary,
                  height: 1.8,
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: -10,
              child: Text(
                '❝',
                style: TextStyle(
                  fontSize: 48,
                  color: PwfHomePalette.secondary.withValues(alpha: 0.5),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        Text(
          widget.vm.name,
          style: GoogleFonts.cairo(
            fontSize: 21,
            fontWeight: FontWeight.w700,
            color: PwfHomePalette.secondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.vm.title,
          style: GoogleFonts.cairo(fontSize: 16, color: PwfHomePalette.gray),
        ),
        const SizedBox(height: 20),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hover = true),
          onExit: (_) => setState(() => _hover = false),
          child: GestureDetector(
            onTap: () => context.go(widget.vm.link),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              transform: _hover
                  ? (Matrix4.identity()..translate(0.0, -3.0))
                  : null,
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
              decoration: BoxDecoration(
                color: _hover
                    ? const Color(0xFFB08A40)
                    : PwfHomePalette.secondary,
                borderRadius: PwfHomeRadii.br8,
                boxShadow: _hover ? PwfHomeShadows.cardHover : null,
              ),
              child: Text(
                'اقرأ المزيد',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PwfMinisterVM {
  const _PwfMinisterVM({
    required this.name,
    required this.title,
    required this.message,
    required this.imageUrl,
    required this.link,
  });

  final String name;
  final String title;
  final String message;
  final String imageUrl;
  final String link;

  static const fallback = _PwfMinisterVM(
    name: 'معالي الوزير',
    title: 'وزير الأوقاف والشؤون الدينية',
    message:
        '"نؤكد التزامنا بخدمة أبناء شعبنا وتعزيز دور المساجد والأوقاف في بناء المجتمع، وتقديم الخدمات الدينية والاجتماعية بكل شفافية وكفاءة."',
    imageUrl:
        'https://images.unsplash.com/photo-1520975958228-3f2c6427f4f2?auto=format&fit=crop&w=900&q=60',
    link: AppRoutes.minister,
  );
}
