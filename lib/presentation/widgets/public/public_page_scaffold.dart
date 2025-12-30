import 'package:flutter/material.dart';
import '../common/custom_app_bar.dart';

class PublicPageScaffold extends StatelessWidget {
  final String title;
  final Widget? toolbar;
  final Widget child;

  const PublicPageScaffold({
    super.key,
    required this.title,
    required this.child,
    this.toolbar,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: CustomAppBar(title: title),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (toolbar != null) ...[
                toolbar!,
                const SizedBox(height: 12),
              ],
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}
