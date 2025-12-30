// lib/presentation/screens/admin/activities/web_activities_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqf/core/constants/app_constants.dart';
import 'package:waqf/core/utils/date_utils.dart';
import 'package:waqf/data/models/activity.dart';
import 'package:waqf/presentation/widgets/admin/admin_layout.dart';


class WebActivitiesManagementScreen extends ConsumerWidget {
  const WebActivitiesManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const AdminLayout(
      currentRoute: '/admin/activities',
      child: ActivitiesContent(),
    );
  }
}

class ActivitiesContent extends ConsumerStatefulWidget {
  const ActivitiesContent({super.key});

  @override
  ConsumerState<ActivitiesContent> createState() => _ActivitiesContentState();
}

class _ActivitiesContentState extends ConsumerState<ActivitiesContent> {
  String _searchQuery = '';
  ActivityStatus? _selectedStatus;
  ActivityCategory? _selectedCategory;
  String? _selectedGovernorate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsCards(),
                  const SizedBox(height: 24),
                  _buildFilters(),
                  const SizedBox(height: 24),
                  _buildActivitiesTable(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            const Text(
              'إدارة الأنشطة والفعاليات',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppConstants.islamicGreen,
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _showAddActivityDialog,
              icon: const Icon(Icons.add),
              label: const Text('نشاط جديد'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.islamicGreen,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    final activities = _getSampleActivities();
    final totalActivities = activities.length;
    final upcoming = activities.where((a) => a.status == ActivityStatus.upcoming).length;
    final ongoing = activities.where((a) => a.status == ActivityStatus.ongoing).length;
    final completed = activities.where((a) => a.status == ActivityStatus.completed).length;

    return Row(
      children: [
        _buildStatCard('إجمالي الأنشطة', totalActivities.toString(), AppConstants.islamicGreen, Icons.event),
        const SizedBox(width: 16),
        _buildStatCard('القادمة', upcoming.toString(), AppColors.info, Icons.upcoming),
        const SizedBox(width: 16),
        _buildStatCard('الجارية', ongoing.toString(), AppColors.success, Icons.play_circle),
        const SizedBox(width: 16),
        _buildStatCard('المكتملة', completed.toString(), Colors.grey, Icons.check_circle),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey[200]!),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'بحث في الأنشطة...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<ActivityStatus>(
                initialValue: _selectedStatus,
                decoration: InputDecoration(
                  labelText: 'الحالة',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('الكل')),
                  ...ActivityStatus.values.map(
                        (s) => DropdownMenuItem(value: s, child: Text(s.displayName)),
                  ),
                ],
                onChanged: (value) => setState(() => _selectedStatus = value),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<ActivityCategory>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'الفئة',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('الكل')),
                  ...ActivityCategory.values.map(
                        (c) => DropdownMenuItem(value: c, child: Text(c.displayName)),
                  ),
                ],
                onChanged: (value) => setState(() => _selectedCategory = value),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _selectedGovernorate,
                decoration: InputDecoration(
                  labelText: 'المحافظة',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('الكل')),
                  ...AppConstants.governorates.map(
                        (g) => DropdownMenuItem(value: g, child: Text(g)),
                  ),
                ],
                onChanged: (value) => setState(() => _selectedGovernorate = value),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitiesTable() {
    final activities = _getSampleActivities();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Expanded(flex: 3, child: _buildTableHeader('العنوان')),
                Expanded(flex: 2, child: _buildTableHeader('النوع')),
                Expanded(flex: 2, child: _buildTableHeader('الفئة')),
                Expanded(flex: 2, child: _buildTableHeader('التاريخ')),
                Expanded(flex: 2, child: _buildTableHeader('المحافظة')),
                Expanded(flex: 1, child: _buildTableHeader('المشاركون')),
                Expanded(flex: 2, child: _buildTableHeader('الحالة')),
                const SizedBox(width: 50, child: Text('')),
              ],
            ),
          ),
          ...activities.map((activity) => _buildTableRow(activity)),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );
  }

  Widget _buildTableRow(Activity activity) {
    return InkWell(
      onTap: () => _showActivityDetails(activity),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                activity.title,
                style: const TextStyle(fontWeight: FontWeight.w500),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(flex: 2, child: Text(activity.type.displayName)),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getCategoryColor(activity.category).withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  activity.category.displayName,
                  style: TextStyle(
                    color: _getCategoryColor(activity.category),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                AppDateUtils.formatArabicDate(activity.startDate),
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            Expanded(flex: 2, child: Text(activity.governorate)),
            Expanded(
              flex: 1,
              child: Text(
                activity.maxParticipants > 0
                    ? '${activity.currentParticipants}/${activity.maxParticipants}'
                    : '-',
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(activity.status).withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  activity.status.displayName,
                  style: TextStyle(
                    color: _getStatusColor(activity.status),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(
              width: 50,
              child: PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'view', child: Text('عرض')),
                  const PopupMenuItem(value: 'edit', child: Text('تعديل')),
                  const PopupMenuItem(value: 'participants', child: Text('المشاركون')),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('حذف', style: TextStyle(color: Colors.red)),
                  ),
                ],
                onSelected: (value) => _handleActivityAction(value, activity),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(ActivityCategory category) {
    switch (category) {
      case ActivityCategory.religious:
        return AppColors.islamicGreen;
      case ActivityCategory.educational:
        return AppColors.info;
      case ActivityCategory.cultural:
        return AppColors.goldenYellow;
      case ActivityCategory.social:
        return AppColors.success;
      case ActivityCategory.family:
        return Colors.pink;
      case ActivityCategory.training:
        return Colors.purple;
      case ActivityCategory.community:
        return AppColors.sageGreen;
    }
  }

  Color _getStatusColor(ActivityStatus status) {
    switch (status) {
      case ActivityStatus.upcoming:
        return AppColors.info;
      case ActivityStatus.ongoing:
        return AppColors.success;
      case ActivityStatus.completed:
        return Colors.grey;
      case ActivityStatus.cancelled:
        return AppColors.error;
      case ActivityStatus.postponed:
        return AppColors.warning;
    }
  }

  void _handleActivityAction(String action, Activity activity) {
    switch (action) {
      case 'view':
        _showActivityDetails(activity);
      case 'edit':
        _showEditActivityDialog(activity);
      case 'participants':
        _showParticipantsDialog(activity);
      case 'delete':
        _showDeleteActivityDialog(activity);
    }
  }

  void _showActivityDetails(Activity activity) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700, maxHeight: 600),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _getCategoryColor(activity.category),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.event, color: Colors.white, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            activity.type.displayName,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(activity.description),
                      const SizedBox(height: 16),
                      _buildDetailRow('الفئة', activity.category.displayName),
                      _buildDetailRow('التاريخ', AppDateUtils.formatArabicDate(activity.startDate)),
                      _buildDetailRow('الموقع', activity.location),
                      _buildDetailRow('المنظم', activity.organizer),
                      _buildDetailRow('المحافظة', activity.governorate),
                      if (activity.maxParticipants > 0)
                        _buildDetailRow('المشاركون', '${activity.currentParticipants}/${activity.maxParticipants}'),
                      _buildDetailRow('الحالة', activity.status.displayName),
                      if (!activity.isFree && activity.price != null)
                        _buildDetailRow('الرسوم', '${activity.price} شيكل'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showAddActivityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة نشاط جديد'),
        content: const Text('سيتم إضافة نموذج إنشاء نشاط جديد هنا'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showEditActivityDialog(Activity activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل النشاط'),
        content: Text('سيتم إضافة نموذج تعديل ${activity.title}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showParticipantsDialog(Activity activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('المشاركون في ${activity.title}'),
        content: const Text('قائمة المشاركين'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  void _showDeleteActivityDialog(Activity activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف ${activity.title}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حذف النشاط')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  List<Activity> _getSampleActivities() {
    return [
      Activity(
        id: 1,
        title: 'دورة تحفيظ القرآن الكريم للأطفال',
        description: 'دورة مكثفة لتحفيظ القرآن الكريم للأطفال من سن 6-12 سنة',
        category: ActivityCategory.religious,
        type: ActivityType.course,
        startDate: DateTime.now().add(const Duration(days: 7)),
        endDate: DateTime.now().add(const Duration(days: 37)),
        location: 'مسجد النور - رام الله',
        organizer: 'جمعية القرآن الكريم',
        maxParticipants: 30,
        currentParticipants: 15,
        status: ActivityStatus.upcoming,
        contact: const ContactInfo(name: 'الأستاذ محمد أحمد', phone: '+970-59-1234567'),
        requiresRegistration: true,
        isFree: true,
        governorate: 'رام الله والبيرة',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Activity(
        id: 2,
        title: 'محاضرة: الوسطية في الإسلام',
        description: 'محاضرة علمية حول مفهوم الوسطية في الإسلام',
        category: ActivityCategory.educational,
        type: ActivityType.lecture,
        startDate: DateTime.now().add(const Duration(days: 3)),
        location: 'قاعة المؤتمرات',
        organizer: 'وزارة الأوقاف',
        maxParticipants: 200,
        currentParticipants: 85,
        status: ActivityStatus.upcoming,
        contact: const ContactInfo(name: 'د. أحمد محمود', phone: '+970-2-2406340'),
        requiresRegistration: false,
        isFree: true,
        governorate: 'رام الله والبيرة',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Activity(
        id: 3,
        title: 'مسابقة حفظ الحديث النبوي',
        description: 'مسابقة سنوية لحفظ الأحاديث النبوية',
        category: ActivityCategory.religious,
        type: ActivityType.competition,
        startDate: DateTime.now().subtract(const Duration(days: 2)),
        endDate: DateTime.now().add(const Duration(days: 5)),
        location: 'مسجد عمر بن الخطاب - نابلس',
        organizer: 'جمعية الحديث النبوي',
        maxParticipants: 50,
        currentParticipants: 42,
        status: ActivityStatus.ongoing,
        contact: const ContactInfo(name: 'الشيخ يوسف عبد الله', phone: '+970-59-7654321'),
        requiresRegistration: true,
        isFree: true,
        governorate: 'نابلس',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }
}