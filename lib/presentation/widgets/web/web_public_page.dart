import 'package:flutter/material.dart';

import '../../../features/platform/home/presentation/theme/pwf_home_palette.dart';
import '../../../features/platform/home/presentation/widgets/pwf_internal_public_page_contract_widgets.dart';
import 'web_app_bar.dart';
import 'web_container.dart';
import 'web_footer.dart';

/// A unified public-page layout for Web.
///
/// Runtime consolidation contract:
/// - RTL is enforced at the shell level for public web pages.
/// - The body is bounded through LayoutBuilder + ConstrainedBox so pages keep a
///   stable footer/content relationship on tall and short screens.
/// - The content remains scrollable instead of overflowing when filters, stats,
///   or dynamic rows become denser during public UAT.
class WebPublicPage extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget Function(BuildContext context)? headerExtras;
  final Widget child;
  final bool includeFooter;
  final EdgeInsetsGeometry contentPadding;
  final String? pageSpecKey;
  final String unitSlug;

  const WebPublicPage({
    super.key,
    required this.title,
    this.subtitle,
    this.headerExtras,
    required this.child,
    this.includeFooter = true,
    this.contentPadding = const EdgeInsets.symmetric(vertical: 24),
    this.pageSpecKey,
    this.unitSlug = 'home',
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: const WebAppBar(),
        body: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final minHeight = constraints.hasBoundedHeight
                  ? constraints.maxHeight
                  : 0.0;

              return SingleChildScrollView(
                primary: true,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: minHeight),
                  child: Column(
                    children: [
                      _buildHeader(context),
                      _buildContent(context),
                      if (includeFooter) const WebFooter(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    if ((pageSpecKey ?? '').trim().isNotEmpty) {
      return Column(
        children: [
          PwfInternalPublicPageIntro(
            specKey: pageSpecKey!,
            unitSlug: unitSlug,
            title: title,
            subtitle: subtitle,
          ),
          if (headerExtras != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: WebContainer(child: headerExtras!(context)),
            ),
        ],
      );
    }
    return Container(
      padding: const EdgeInsets.only(top: 0, bottom: 18),
      child: WebContainer(
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: const Color(0xFF0F172A),
                  fontWeight: FontWeight.w800,
                ),
              ),
              if ((subtitle ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  subtitle!,
                  textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: PwfHomePalette.textSecondary,
                    height: 1.7,
                  ),
                ),
              ],
              if (headerExtras != null) ...[
                const SizedBox(height: 18),
                headerExtras!(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Container(
      padding: contentPadding,
      child: WebContainer(child: child),
    );
  }
}
