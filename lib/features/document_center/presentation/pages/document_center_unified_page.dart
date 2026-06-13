
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:waqf/app/routing/app_routes.dart';
import 'package:waqf/presentation/widgets/admin/admin_layout.dart';

import '../../domain/document_center_models.dart';
import '../document_center_providers.dart';

class DocumentCenterUnifiedPage extends ConsumerWidget {
  const DocumentCenterUnifiedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(documentCenterDashboardProvider);

    return AdminLayout(
      currentRoute: AppRoutes.adminDocuments,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: dashboard.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => _DocumentCenterError(error: error),
            data: (data) => _DocumentCenterBody(dashboard: data),
          ),
        ),
      ),
    );
  }
}

class _DocumentCenterBody extends StatelessWidget {
  const _DocumentCenterBody({required this.dashboard});

  final DocumentCenterDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final metrics = dashboard.metrics;

    return RefreshIndicator(
      onRefresh: () async {},
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _Header(dashboard: dashboard),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetricCard(
                label: 'إجمالي السجلات',
                value: metrics.total.toString(),
                icon: Icons.folder_copy_outlined,
              ),
              _MetricCard(
                label: 'ذكاء وثائقي',
                value: metrics.documentIntelligence.toString(),
                icon: Icons.psychology_alt_outlined,
              ),
              _MetricCard(
                label: 'مرفقات خدمات',
                value: metrics.serviceAttachments.toString(),
                icon: Icons.assignment_turned_in_outlined,
              ),
              _MetricCard(
                label: 'أصول إعلامية',
                value: metrics.mediaAssets.toString(),
                icon: Icons.perm_media_outlined,
              ),
              _MetricCard(
                label: 'ملفات تخزين محكومة',
                value: metrics.storageObjects.toString(),
                icon: Icons.inventory_2_outlined,
              ),
              _MetricCard(
                label: 'مراجع طويلة/أدلة',
                value: metrics.longLived.toString(),
                icon: Icons.gavel_outlined,
              ),
              _MetricCard(
                label: 'مرتبطة بالتخزين',
                value: metrics.withStorageReference.toString(),
                icon: Icons.cloud_done_outlined,
              ),
            ],
          ),
          const SizedBox(height: 20),
          _LifecycleNotice(dashboard: dashboard),
          const SizedBox(height: 20),
          _SurfaceErrors(errors: dashboard.surfaceErrors),
          const SizedBox(height: 20),
          _DocumentCenterTable(items: dashboard.items),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.dashboard});

  final DocumentCenterDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          spacing: 20,
          runSpacing: 16,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const SizedBox(
              width: 520,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مركز الوثائق الموحّد',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'بوابة موحّدة تعرض الذكاء الوثائقي ومرفقات الخدمات وأصول المركز الإعلامي وسجل ملفات التخزين المحكوم، مع تصنيف أولي لدورة حياة الوثائق.',
                  ),
                ],
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () => context.go(AppRoutes.adminDocumentIntelligence),
                  icon: const Icon(Icons.psychology_outlined),
                  label: const Text('الذكاء الوثائقي'),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.go('/admin/media-center/news'),
                  icon: const Icon(Icons.perm_media_outlined),
                  label: const Text('المركز الإعلامي'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LifecycleNotice extends StatelessWidget {
  const _LifecycleNotice({required this.dashboard});

  final DocumentCenterDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: const Color(0xFFFFFBEB),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, color: Color(0xFF92400E)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'هذه الشاشة لا تحذف الملفات ولا تغيّر سياسات الاحتفاظ. ملفات التخزين غير المسندة تبقى restricted + unassigned ولا تُنسب إلى وحدة أو تُنشر إلا عبر ربط مالك صريح.',
                style: TextStyle(color: Colors.orange.shade900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SurfaceErrors extends StatelessWidget {
  const _SurfaceErrors({required this.errors});

  final Map<String, String> errors;

  @override
  Widget build(BuildContext context) {
    if (errors.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 0,
      color: const Color(0xFFFEF2F2),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'أسطح لم تُحمّل بالكامل',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            ...errors.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text('${entry.key}: ${entry.value}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 210,
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Icon(icon, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(label, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocumentCenterTable extends StatelessWidget {
  const _DocumentCenterTable({required this.items});

  final List<DocumentCenterItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Card(
        elevation: 0,
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('لا توجد سجلات قابلة للعرض من الأسطح المتاحة حاليًا.'),
        ),
      );
    }

    return Card(
      elevation: 0,
      child: Column(
        children: [
          const ListTile(
            title: Text(
              'آخر الوثائق والملفات عبر الأنظمة',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: Text(
              'قراءة موحّدة فقط؛ إجراءات الحذف والأرشفة تحتاج سياسة lifecycle معتمدة.',
            ),
          ),
          const Divider(height: 1),
          ...items.map((item) => _DocumentCenterTile(item: item)),
        ],
      ),
    );
  }
}

class _DocumentCenterTile extends StatelessWidget {
  const _DocumentCenterTile({required this.item});

  final DocumentCenterItem item;

  @override
  Widget build(BuildContext context) {
    final isLongLived = item.isLongLived;
    final icon = switch (item.surface) {
      DocumentCenterSurface.documentIntelligence => Icons.psychology_outlined,
      DocumentCenterSurface.serviceAttachment => Icons.assignment_outlined,
      DocumentCenterSurface.mediaAsset => Icons.perm_media_outlined,
      DocumentCenterSurface.storageObject => Icons.inventory_2_outlined,
    };

    return ListTile(
      leading: CircleAvatar(child: Icon(icon)),
      title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            _ChipLabel(text: item.surfaceLabel),
            _ChipLabel(text: item.retentionLabel),
            if (item.status != null && item.status!.isNotEmpty)
              _ChipLabel(text: 'الحالة: ${item.status}'),
            if (item.hasStorageReference) const _ChipLabel(text: 'Storage linked'),
            if (item.raw['visibility_scope'] != null)
              _ChipLabel(text: 'الرؤية: ${item.raw['visibility_scope']}'),
            if (item.raw['unit_assignment_status'] != null)
              _ChipLabel(text: 'الوحدة: ${item.raw['unit_assignment_status']}'),
            if (item.raw['mapping_status'] != null)
              _ChipLabel(text: 'الربط: ${item.raw['mapping_status']}'),
            if (isLongLived) const _ChipLabel(text: 'لا حذف عشوائي'),
          ],
        ),
      ),
      trailing: const Icon(Icons.chevron_left),
    );
  }
}

class _ChipLabel extends StatelessWidget {
  const _ChipLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(text),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class _DocumentCenterError extends StatelessWidget {
  const _DocumentCenterError({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('تعذر تحميل مركز الوثائق: $error'),
        ),
      ),
    );
  }
}
