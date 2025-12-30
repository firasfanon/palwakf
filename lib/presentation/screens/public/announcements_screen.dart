import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/text_normalize.dart';
import '../../../data/models/announcement.dart';
import '../../providers/unit_announcements_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/app_filter_chip.dart';
import '../../widgets/web/web_public_page.dart';

class AnnouncementsScreen extends ConsumerStatefulWidget {
  final String unitSlug;

  const AnnouncementsScreen({
    super.key,
    required this.unitSlug,
  });

  @override
  ConsumerState<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends ConsumerState<AnnouncementsScreen> {
  Priority? _selectedPriority;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final asyncAnnouncements = ref.watch(announcementsForUnitProvider(widget.unitSlug));

    if (kIsWeb) {
      return WebPublicPage(
        title: 'الإعلانات الرسمية',
        subtitle: 'إعلانات الوزارة والتعاميم والقرارات',
        headerExtras: (_) => _buildFiltersSection(isWeb: true),
        child: asyncAnnouncements.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('تعذّر تحميل الإعلانات')),
          data: (rows) {
            final items = _applyFilters(rows);
            return Directionality(
              textDirection: TextDirection.rtl,
              child: _buildAnnouncementsListWeb(items),
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'الإعلانات الرسمية',
        showSearchButton: true,
      ),
      body: Column(
        children: [
          _buildFiltersSection(isWeb: false),
          Expanded(
            child: asyncAnnouncements.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => const Center(child: Text('تعذّر تحميل الإعلانات')),
              data: (rows) {
                final items = _applyFilters(rows);
                return _buildAnnouncementsListMobile(items);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection({required bool isWeb}) {
    final onDark = isWeb;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          SizedBox(
            width: 620,
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: 'ابحث في الإعلانات...',
                filled: true,
                fillColor: onDark ? Colors.white.withValues(alpha: 0.12) : Colors.grey[100],
                prefixIcon: Icon(Icons.search, color: onDark ? Colors.white : Colors.grey[700]),
                hintStyle: TextStyle(color: onDark ? Colors.white70 : Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: onDark ? Colors.white : Colors.black87),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [

            AppFilterChip(
                label: 'الكل',
                isSelected: _selectedPriority == null,
                onSelected: () => setState(() => _selectedPriority = null),
                onDarkBackground: onDark,
              ),
              AppFilterChip(
                label: 'طارئ',
                isSelected: _selectedPriority == Priority.critical,
                onSelected: () => setState(() => _selectedPriority = Priority.critical),
                onDarkBackground: onDark,
              ),
              AppFilterChip(
                label: 'عاجل',
                isSelected: _selectedPriority == Priority.urgent,
                onSelected: () => setState(() => _selectedPriority = Priority.urgent),
                onDarkBackground: onDark,
              ),
              AppFilterChip(
                label: 'عالي',
                isSelected: _selectedPriority == Priority.high,
                onSelected: () => setState(() => _selectedPriority = Priority.high),
                onDarkBackground: onDark,
              ),
              AppFilterChip(
                label: 'متوسط',
                isSelected: _selectedPriority == Priority.medium,
                onSelected: () => setState(() => _selectedPriority = Priority.medium),
                onDarkBackground: onDark,
              ),
              AppFilterChip(
                label: 'منخفض',
                isSelected: _selectedPriority == Priority.low,
                onSelected: () => setState(() => _selectedPriority = Priority.low),
                onDarkBackground: onDark,
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  List<Announcement> _applyFilters(List<Announcement> items) {
    var announcements = List<Announcement>.from(items);

    if (_selectedPriority != null) {
      announcements = announcements.where((a) => a.priority == _selectedPriority).toList();
    }

    final q = _searchQuery.trim();
    if (q.isNotEmpty) {
      final lower = q.toLowerCase();
      announcements = announcements.where((a) {
        final t = normalizeRichText(a.title).toLowerCase();
        final c = normalizeRichText(a.content).toLowerCase();
        return t.contains(lower) || c.contains(lower);
      }).toList();
    }

    // Put high priority first when equal dates
    announcements.sort((a, b) {
      final da = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final db = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final dateComp = db.compareTo(da);
      if (dateComp != 0) return dateComp;
      return b.priority.index.compareTo(a.priority.index);
    });

    return announcements;
  }

  Widget _buildAnnouncementsListWeb(List<Announcement> announcements) {
    if (announcements.isEmpty) return _buildEmptyState();

    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingL),
      child: Wrap(
        spacing: 20,
        runSpacing: 20,
        children: announcements.map((a) => SizedBox(width: 520, child: _announcementCard(a, isWeb: true))).toList(),
      ),
    );
  }

  Widget _buildAnnouncementsListMobile(List<Announcement> announcements) {
    if (announcements.isEmpty) return _buildEmptyState();

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(announcementsForUnitProvider(widget.unitSlug));
      },
      child: AnimationLimiter(
        child: ListView.builder(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          itemCount: announcements.length,
          itemBuilder: (context, index) {
            final item = announcements[index];
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 250),
              child: SlideAnimation(
                verticalOffset: 30.0,
                child: FadeInAnimation(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _announcementCard(item, isWeb: false),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _announcementCard(Announcement item, {required bool isWeb}) {
    final priorityColor = _getPriorityColor(item.priority);
    final validUntil = item.validUntil;

    return Card(
      elevation: isWeb ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        side: BorderSide(color: priorityColor.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                  child: Text(
                    _getPriorityText(item.priority),
                    style: TextStyle(
                      color: priorityColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                if (item.createdAt != null)
                  Text(
                    AppDateUtils.formatDate(item.createdAt!),
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              normalizeRichText(item.title),
              style: TextStyle(
                fontSize: isWeb ? 18 : 16,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              normalizeRichText(item.content),
              maxLines: isWeb ? 4 : 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[700], height: 1.5),
            ),
            if (validUntil != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    'ساري حتى: ${AppDateUtils.formatDate(validUntil)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.campaign_outlined, size: 72, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'لا توجد إعلانات مطابقة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              'جرّب تغيير الفلترة أو البحث.',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.critical:
      case Priority.urgent:
        return const Color(0xFFB22222); // Royal red
      case Priority.high:
        return const Color(0xFFD4AF37); // Gold
      case Priority.medium:
        return const Color(0xFF1E6FB9); // Blue
      case Priority.low:
        return Colors.grey;
    }
  }

  String _getPriorityText(Priority priority) {
    return priority.displayName;
  }
}
