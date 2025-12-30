import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/date_utils.dart' as app_date;
import '../../providers/friday_sermons_provider.dart';
import '../../../data/models/friday_sermon.dart';
import '../../widgets/web/web_public_page.dart';
import '../../../core/constants/app_constants.dart';

class FridaySermonScreen extends ConsumerStatefulWidget {
  const FridaySermonScreen({super.key});

  @override
  ConsumerState<FridaySermonScreen> createState() => _FridaySermonScreenState();
}

class _FridaySermonScreenState extends ConsumerState<FridaySermonScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(publicFridaySermonsProvider);

    if (kIsWeb) {
      return WebPublicPage(
        title: 'خطبة الجمعة',
        subtitle: 'نصوص وملخصات خطبة الجمعة والملفات المرفقة',
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBox(isWeb: true),
              const SizedBox(height: 16),
              async.when(
                data: (items) => _buildListWeb(context, items),
                loading: () => const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
                error: (e, _) => _buildError(e),
              ),
            ],
          ),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('خطبة الجمعة')),
        body: async.when(
          data: (items) {
            if (items.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('لا توجد خُطب منشورة حاليًا.'),
                ),
              );
            }
            final filtered = _applySearch(items);
            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(publicFridaySermonsProvider),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final s = filtered[i];
                  final date = app_date.AppDateUtils.formatArabicDate(s.sermonDate);
                  final subtitle = [
                    if ((s.speakerName ?? '').trim().isNotEmpty) 'الخطيب: ${s.speakerName}',
                    if ((s.mosqueName ?? '').trim().isNotEmpty) 'المسجد: ${s.mosqueName}',
                    'التاريخ: $date',
                  ].join('  •  ');

                  return Card(
                    child: ListTile(
                      title: Text(
                        s.titleAr.isNotEmpty ? s.titleAr : 'خطبة الجمعة',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.chevron_left),
                      onTap: () => _showDetails(context, s),
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(e.toString(), textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => ref.invalidate(publicFridaySermonsProvider),
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBox({required bool isWeb}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        onChanged: (v) => setState(() => _query = v),
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          hintText: 'بحث في الخُطب (العنوان/الخطيب/المسجد)...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  List<FridaySermon> _applySearch(List<FridaySermon> items) {
    final q = _query.trim();
    if (q.isEmpty) return items;
    final lower = q.toLowerCase();
    return items.where((s) {
      final t = s.titleAr.toLowerCase();
      final sp = (s.speakerName ?? '').toLowerCase();
      final m = (s.mosqueName ?? '').toLowerCase();
      final sum = (s.summaryAr ?? '').toLowerCase();
      return t.contains(lower) || sp.contains(lower) || m.contains(lower) || sum.contains(lower);
    }).toList();
  }

  Widget _buildListWeb(BuildContext context, List<FridaySermon> items) {
    final filtered = _applySearch(items);
    if (filtered.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.menu_book, size: 52, color: Colors.grey),
              const SizedBox(height: 12),
              const Text('لا توجد نتائج', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(_query.trim().isEmpty ? 'لا توجد خُطب منشورة حاليًا.' : 'جرّب تغيير كلمات البحث.'),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => ref.invalidate(publicFridaySermonsProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('تحديث'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () => ref.invalidate(publicFridaySermonsProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('تحديث'),
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final s = filtered[i];
            final date = app_date.AppDateUtils.formatArabicDate(s.sermonDate);
            final subtitle = [
              if ((s.speakerName ?? '').trim().isNotEmpty) 'الخطيب: ${s.speakerName}',
              if ((s.mosqueName ?? '').trim().isNotEmpty) 'المسجد: ${s.mosqueName}',
              'التاريخ: $date',
            ].join('  •  ');

            return Card(
              child: ListTile(
                title: Text(
                  s.titleAr.isNotEmpty ? s.titleAr : 'خطبة الجمعة',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.chevron_left),
                onTap: () => _showDetails(context, s),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildError(Object e) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(e.toString(), textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(publicFridaySermonsProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetails(BuildContext context, FridaySermon s) {
    final date = app_date.AppDateUtils.formatArabicDate(s.sermonDate);
    showDialog(
      context: context,
      builder: (_) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text(s.titleAr.isNotEmpty ? s.titleAr : 'خطبة الجمعة'),
            content: SizedBox(
              width: 680,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('التاريخ: $date'),
                    if ((s.speakerName ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text('الخطيب: ${s.speakerName}'),
                    ],
                    if ((s.mosqueName ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text('المسجد: ${s.mosqueName}'),
                    ],
                    const SizedBox(height: 12),
                    if ((s.summaryAr ?? '').trim().isNotEmpty) ...[
                      const Text('الملخص', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(s.summaryAr!),
                      const SizedBox(height: 12),
                    ],
                    if ((s.contentAr ?? '').trim().isNotEmpty) ...[
                      const Text('نص الخطبة', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(s.contentAr!),
                    ],
                    if ((s.audioUrl ?? '').trim().isNotEmpty || (s.pdfUrl ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text('المرفقات', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      if ((s.audioUrl ?? '').trim().isNotEmpty) Text('Audio: ${s.audioUrl}'),
                      if ((s.pdfUrl ?? '').trim().isNotEmpty) Text('PDF: ${s.pdfUrl}'),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('إغلاق'),
              ),
            ],
          ),
        );
      },
    );
  }
}
