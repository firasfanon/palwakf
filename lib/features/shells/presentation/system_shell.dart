import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/brand/brand_provider.dart';
import '../../../core/brand/brand_theme.dart';
import '../../../core/enums/enums.dart';
import '../../../core/brand/brand_registry.dart';

/// System shell: applies per-system Brand and can host system topbar/sidebar.
class SystemShell extends ConsumerWidget {
  final SystemKey systemKey;
  final Widget child;

  const SystemShell({
    super.key,
    required this.systemKey,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brand = BrandRegistry.of(systemKey);

    return ProviderScope(
      overrides: [
        brandProvider.overrideWithValue(brand),
      ],
      child: Theme(
        data: BrandTheme.buildTheme(brand),
        child: child,
      ),
    );
  }
}
