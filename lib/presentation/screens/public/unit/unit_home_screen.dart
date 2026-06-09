import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../home/home_screen.dart';
import '../../../providers/unit_context_provider.dart';

/// Unit page (/:unitSlug)
///
/// Renders the same Home Dashboard but scoped by unitSlug.
class UnitHomeScreen extends ConsumerWidget {
  final String unitSlug;

  const UnitHomeScreen({super.key, required this.unitSlug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unitAsync = ref.watch(orgUnitBySlugProvider(unitSlug));

    return unitAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => HomeScreen(unitSlug: unitSlug),
      data: (unit) {
        final nameAr = (unit?['name_ar'] ?? '').toString().trim();
        final title = nameAr.isNotEmpty ? nameAr : null;
        return HomeScreen(unitSlug: unitSlug, unitTitle: title);
      },
    );
  }
}
