import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/access/access_provider.dart';
import '../../../../../../core/enums/enums.dart';

class MosquesManagementScreen extends ConsumerWidget {
  const MosquesManagementScreen({super.key});

  static const String _placeholderText =
      'قيد التطوير: سيتم هنا بناء إدارة المساجد (CRUD + خرائط + ربط المديريات).\n'
      'تم إضافة المسار لإكمال إطار المنصة بدون شاشات بيضاء.';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(accessProfileProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('نظام المساجد'),
        ),
        body: profileAsync.when(
          data: (profile) {
            // MVP: gate by viewer role at least for mosques system; refine later.
            final allowed = profile?.hasRoleAtLeast(SystemKey.mosques, UserRole.viewer) ?? false;
            if (!allowed) {
              return const Center(
                child: Text('غير مصرح لك بالدخول إلى نظام المساجد.'),
              );
            }
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  _placeholderText,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(e.toString())),
        ),
      ),
    );
  }
}
