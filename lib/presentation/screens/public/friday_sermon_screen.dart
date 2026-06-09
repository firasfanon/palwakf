import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_utils.dart' as app_date;
import '../../../data/models/friday_sermon.dart';
import '../../providers/friday_sermons_provider.dart';
import '../../widgets/web/web_public_page.dart';

class FridaySermonScreen extends ConsumerStatefulWidget {
  const FridaySermonScreen({super.key});

  @override
  ConsumerState<FridaySermonScreen> createState() => _FridaySermonScreenState();
}

class _FridaySermonScreenState extends ConsumerState<FridaySermonScreen> {
  String _query = '';
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(publicFridaySermonsProvider);

    if (kIsWeb) {
      return WebPublicPage(
        title: 'خطبة الجمعة',
        subtitle: 'نصوص وملخصات خطبة الجمعة والملفات المرفقة',
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: async.when(
            data: (items) => _buildRichContent(context, items, isWeb: true),
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e, _) => _buildError(e),
          ),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('خطبة الجمعة')),
        body: async.when(
          data: (items) => _buildRichContent(context, items, isWeb: false),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _buildError(e),
        ),
      ),
    );
  }

  Widget _buildRichContent(
    BuildContext context,
    List<FridaySermon> items, {
    required bool isWeb,
  }) {
    final filtered = _applySearch(items);
    final latest = filtered.isEmpty
        ? null
        : (filtered.toList()
                ..sort((a, b) => b.sermonDate.compareTo(a.sermonDate)))
              .first;
    final withPdf = filtered
        .where((item) => (item.pdfUrl ?? '').trim().isNotEmpty)
        .length;
    final withAudio = filtered
        .where((item) => (item.audioUrl ?? '').trim().isNotEmpty)
        .length;
    final width = MediaQuery.of(context).size.width;
    final gridColumns = isWeb
        ? (width >= 1400
              ? 3
              : width >= 920
              ? 2
              : 1)
        : 1;

    final body = ListView(
      padding: EdgeInsets.all(isWeb ? 0 : 16),
      children: [
        _buildSearchBox(),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: isWeb
              ? (width >= 1280
                    ? 4
                    : width >= 900
                    ? 2
                    : 1)
              : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: isWeb ? 2.2 : 2.0,
          children: [
            _StatCard(
              label: 'إجمالي الخُطب',
              value: filtered.length.toString(),
              icon: Icons.menu_book_outlined,
              color: const Color(0xFF0B3A70),
            ),
            _StatCard(
              label: 'أحدث تاريخ',
              value: latest == null
                  ? '—'
                  : app_date.AppDateUtils.formatArabicDate(latest.sermonDate),
              icon: Icons.calendar_today_outlined,
              color: const Color(0xFF2E7D32),
            ),
            _StatCard(
              label: 'بملف PDF',
              value: withPdf.toString(),
              icon: Icons.picture_as_pdf_outlined,
              color: const Color(0xFFB22222),
            ),
            _StatCard(
              label: 'بملف صوتي',
              value: withAudio.toString(),
              icon: Icons.audiotrack_outlined,
              color: const Color(0xFF7C3AED),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (latest != null) ...[
          _LatestSermonHero(
            sermon: latest,
            onOpen: () => _showDetails(context, latest),
          ),
          const SizedBox(height: 16),
        ],
        if (filtered.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.menu_book, size: 52, color: Colors.grey),
                const SizedBox(height: 12),
                const Text(
                  'لا توجد نتائج',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  _query.trim().isEmpty
                      ? 'لا توجد خُطب منشورة حاليًا.'
                      : 'جرّب تغيير كلمات البحث.',
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => ref.invalidate(publicFridaySermonsProvider),
                  icon: const Icon(Icons.refresh),
                  label: const Text('تحديث'),
                ),
              ],
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: gridColumns,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: isWeb ? 1.12 : 1.02,
            ),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final sermon = filtered[index];
              return _SermonPreviewCard(
                sermon: sermon,
                onOpen: () => _showDetails(context, sermon),
              );
            },
          ),
      ],
    );

    if (isWeb) return body;
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(publicFridaySermonsProvider),
      child: body,
    );
  }

  Widget _buildSearchBox() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _query = v),
        textDirection: TextDirection.rtl,
        decoration: InputDecoration(
          hintText: 'بحث في الخُطب (العنوان/الخطيب/المسجد)...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _query.trim().isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                  icon: const Icon(Icons.close),
                ),
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
      return t.contains(lower) ||
          sp.contains(lower) ||
          m.contains(lower) ||
          sum.contains(lower);
    }).toList();
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
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InfoChip(
                          label: date,
                          icon: Icons.calendar_today_outlined,
                        ),
                        if ((s.speakerName ?? '').trim().isNotEmpty)
                          _InfoChip(
                            label: s.speakerName!,
                            icon: Icons.record_voice_over_outlined,
                          ),
                        if ((s.mosqueName ?? '').trim().isNotEmpty)
                          _InfoChip(
                            label: s.mosqueName!,
                            icon: Icons.mosque_outlined,
                          ),
                        if ((s.pdfUrl ?? '').trim().isNotEmpty)
                          const _InfoChip(
                            label: 'ملف PDF مرفق',
                            icon: Icons.picture_as_pdf_outlined,
                            color: Color(0xFFB22222),
                          ),
                        if ((s.audioUrl ?? '').trim().isNotEmpty)
                          const _InfoChip(
                            label: 'ملف صوتي مرفق',
                            icon: Icons.audiotrack_outlined,
                            color: Color(0xFF7C3AED),
                          ),
                      ],
                    ),
                    if ((s.summaryAr ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'الملخص',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      _TextPanel(text: s.summaryAr!),
                    ],
                    if ((s.contentAr ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'نص الخطبة',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      _TextPanel(text: s.contentAr!),
                    ],
                    if ((s.audioUrl ?? '').trim().isNotEmpty ||
                        (s.pdfUrl ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'المرفقات',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      if ((s.audioUrl ?? '').trim().isNotEmpty)
                        _TextPanel(text: s.audioUrl!),
                      if ((s.pdfUrl ?? '').trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _TextPanel(text: s.pdfUrl!),
                      ],
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

class _LatestSermonHero extends StatelessWidget {
  const _LatestSermonHero({required this.sermon, required this.onOpen});

  final FridaySermon sermon;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final date = app_date.AppDateUtils.formatArabicDate(sermon.sermonDate);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0B3A70), Color(0xFF1E4F8A)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _HeroLabel(text: 'أحدث خطبة منشورة'),
          const SizedBox(height: 12),
          Text(
            sermon.titleAr.isEmpty ? 'خطبة الجمعة' : sermon.titleAr,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HeroInfo(text: date, icon: Icons.calendar_today_outlined),
              if ((sermon.speakerName ?? '').trim().isNotEmpty)
                _HeroInfo(
                  text: sermon.speakerName!,
                  icon: Icons.record_voice_over_outlined,
                ),
              if ((sermon.mosqueName ?? '').trim().isNotEmpty)
                _HeroInfo(
                  text: sermon.mosqueName!,
                  icon: Icons.mosque_outlined,
                ),
            ],
          ),
          if ((sermon.summaryAr ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              sermon.summaryAr!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.92),
                height: 1.5,
              ),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton.tonalIcon(
            onPressed: onOpen,
            icon: const Icon(Icons.visibility_outlined),
            label: const Text('عرض الخطبة'),
          ),
        ],
      ),
    );
  }
}

class _HeroLabel extends StatelessWidget {
  const _HeroLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _HeroInfo extends StatelessWidget {
  const _HeroInfo({required this.text, required this.icon});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SermonPreviewCard extends StatelessWidget {
  const _SermonPreviewCard({required this.sermon, required this.onOpen});

  final FridaySermon sermon;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final date = app_date.AppDateUtils.formatArabicDate(sermon.sermonDate);
    final summary = (sermon.summaryAr ?? '').trim().isNotEmpty
        ? sermon.summaryAr!
        : ((sermon.contentAr ?? '').trim().isNotEmpty
              ? sermon.contentAr!
              : 'لا يوجد ملخص مختصر لهذه الخطبة بعد.');

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  sermon.titleAr.isEmpty ? 'خطبة الجمعة' : sermon.titleAr,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFF0B3A70).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.menu_book_outlined,
                  color: Color(0xFF0B3A70),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(label: date, icon: Icons.calendar_today_outlined),
              if ((sermon.speakerName ?? '').trim().isNotEmpty)
                _InfoChip(
                  label: sermon.speakerName!,
                  icon: Icons.record_voice_over_outlined,
                ),
              if ((sermon.mosqueName ?? '').trim().isNotEmpty)
                _InfoChip(
                  label: sermon.mosqueName!,
                  icon: Icons.mosque_outlined,
                ),
              if ((sermon.pdfUrl ?? '').trim().isNotEmpty)
                const _InfoChip(
                  label: 'PDF',
                  icon: Icons.picture_as_pdf_outlined,
                  color: Color(0xFFB22222),
                ),
              if ((sermon.audioUrl ?? '').trim().isNotEmpty)
                const _InfoChip(
                  label: 'صوت',
                  icon: Icons.audiotrack_outlined,
                  color: Color(0xFF7C3AED),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: Text(
              summary,
              maxLines: 6,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.55,
                color: const Color(0xFF374151),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.tonalIcon(
              onPressed: onOpen,
              icon: const Icon(Icons.visibility_outlined),
              label: const Text('تفاصيل الخطبة'),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.icon,
    this.color = const Color(0xFF0B3A70),
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _TextPanel extends StatelessWidget {
  const _TextPanel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: SelectableText(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
