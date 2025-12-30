import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/web/web_public_page.dart';
import '../../widgets/common/app_filter_chip.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  String _selectedFilter = 'الكل';

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb;

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFilters(),
        const SizedBox(height: 16),
        if (isWeb)
          _buildProjectsListWeb()
        else
          Expanded(child: _buildProjectsListMobile()),
      ],
    );

    if (isWeb) {
      return WebPublicPage(
        title: 'المشاريع',
        subtitle: 'المشاريع والمبادرات التابعة للوزارة',
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            child: body,
          ),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: const CustomAppBar(title: 'المشاريع'),
        body: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          child: body,
        ),
      ),
    );
  }

  Widget _buildFilters() {
    final filters = <String>['الكل', 'إنشائية', 'صيانة', 'تعليم', 'إغاثة'];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: filters.map<Widget>((f) {
        return AppFilterChip(
          label: f,
          isSelected: _selectedFilter == f,
          onSelected: () => setState(() => _selectedFilter = f),
        );
      }).toList(),
    );
  }

  Widget _buildProjectsListWeb() {
    final filtered = _getFilteredProjects();

    if (filtered.isEmpty) {
      return const Center(child: Text('لا توجد مشاريع مطابقة للفلتر.'));
    }

    return Column(
      children: [
        for (final p in filtered) _buildProjectCard(p),
      ],
    );
  }

  Widget _buildProjectsListMobile() {
    final filtered = _getFilteredProjects();

    if (filtered.isEmpty) {
      return const Center(child: Text('لا توجد مشاريع مطابقة للفلتر.'));
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) => _buildProjectCard(filtered[index]),
    );
  }

  List<Map<String, dynamic>> _getFilteredProjects() {
    final projects = [
      {
        'title': 'مشروع ترميم مسجد تاريخي',
        'category': 'صيانة',
        'description': 'أعمال صيانة وترميم للمحافظة على الطابع التاريخي.',
        'image': null,
      },
      {
        'title': 'تطوير خدمات الوقف',
        'category': 'تعليم',
        'description': 'إطلاق برامج تدريبية وتطويرية لخدمة الوقف.',
        'image': null,
      },
      {
        'title': 'مشروع دعم الأسر المحتاجة',
        'category': 'إغاثة',
        'description': 'برامج دعم اجتماعي بالتعاون مع مؤسسات الشراكة.',
        'image': null,
      },
    ];

    return _selectedFilter == 'الكل'
        ? projects
        : projects.where((p) => p['category'] == _selectedFilter).toList();
  }

  Widget _buildProjectCard(Map<String, dynamic> project) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(project['title']?.toString() ?? '',
                style: AppTextStyles.titleLarge.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(project['description']?.toString() ?? ''),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.category, size: 18, color: Colors.grey),
                const SizedBox(width: 6),
                Text(project['category']?.toString() ?? ''),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
