import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../app/routing/app_routes.dart';
import '../../../../../../core/access/access_provider.dart';
import '../../../../../../core/enums/enums.dart';
import '../../../../../widgets/admin/admin_system_workspace_header.dart';

class MosquesManagementScreen extends ConsumerWidget {
  const MosquesManagementScreen({super.key});

  static const String _placeholderText =
      'قيد التطوير: سيتم هنا بناء إدارة المساجد (CRUD + خرائط + ربط المديريات).\n'
      'تم تنظيم الشاشة الآن وفق السجل المركزي حتى لا تبقى منفصلة عن بقية الأنظمة.';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(accessProfileProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('نظام المساجد')),
        body: profileAsync.when(
          data: (profile) {
            final allowed =
                profile?.hasRoleAtLeast(SystemKey.mosques, UserRole.viewer) ??
                false;
            if (!allowed) {
              return const Center(
                child: Text('غير مصرح لك بالدخول إلى نظام المساجد.'),
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AdminSystemWorkspaceHeader(
                    currentRoute: AppRoutes.adminMosques,
                    fallbackTitle: 'نظام المساجد',
                    fallbackSubtitle:
                        'تنظيم الشاشة وفق السجل المركزي حتى قبل اكتمال CRUD والربط التشغيلي.',
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: const Text(
                      _placeholderText,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
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
