import 'package:flutter/material.dart';

abstract class PwfWebHomeHtmlScreenBase extends StatelessWidget {
  final String unitSlug;
  final String? unitTitle;

  const PwfWebHomeHtmlScreenBase({
    super.key,
    this.unitSlug = 'home',
    this.unitTitle,
  });

  @override
  Widget build(BuildContext context) {
    // Non-web fallback (should not be used in production).
    return const SizedBox.shrink();
  }
}
