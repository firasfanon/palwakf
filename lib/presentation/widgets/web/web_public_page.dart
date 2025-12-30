import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import 'web_app_bar.dart';
import 'web_container.dart';
import 'web_footer.dart';

/// A unified public-page layout for Web.
///
/// Mirrors the structure used in the News page:
/// - Top navigation (WebAppBar)
/// - Gradient header (title + optional subtitle + optional filters)
/// - Content section wrapped in WebContainer
/// - Footer
class WebPublicPage extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget Function(BuildContext context)? headerExtras;
  final Widget child;
  final bool includeFooter;
  final EdgeInsetsGeometry contentPadding;

  const WebPublicPage({
    super.key,
    required this.title,
    this.subtitle,
    this.headerExtras,
    required this.child,
    this.includeFooter = true,
    this.contentPadding = const EdgeInsets.symmetric(vertical: 60),
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const WebAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            _buildContent(context),
            if (includeFooter) const WebFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      decoration: const BoxDecoration(
        gradient: AppConstants.islamicGradient,
      ),
      child: WebContainer(
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if ((subtitle ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white70,
                    ),
              ),
            ],
            if (headerExtras != null) ...[
              const SizedBox(height: 30),
              headerExtras!(context),
            ],
          ],
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
