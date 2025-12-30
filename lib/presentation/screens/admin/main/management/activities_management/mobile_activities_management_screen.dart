import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:waqf/core/constants/app_constants.dart';
import 'package:waqf/core/utils/date_utils.dart';
import 'package:waqf/data/models/activity.dart';
import 'package:waqf/presentation/widgets/common/custom_app_bar.dart';
import 'package:waqf/presentation/widgets/common/search_bar_widget.dart';


class MobileActivitiesManagementScreen extends StatefulWidget {
  const MobileActivitiesManagementScreen({super.key});

  @override
  State<MobileActivitiesManagementScreen> createState() => _MobileActivitiesManagementScreenState();
}

class _MobileActivitiesManagementScreenState extends State<MobileActivitiesManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  ActivityCategory? _selectedCategory;
  String? _selectedGovernorate;

  final List<Activity> _activities = _getSampleActivities();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'الأنشطة والفعاليات',
        showSearchButton: true,
      ),
      body: Column(
        children: [
          // Search and Filters
          _buildSearchAndFilters(),

          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.islamicGreen,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.islamicGreen,
              tabs: const [
                Tab(text: 'القادمة'),
                Tab(text: 'الجارية'),
                Tab(text: 'المكتملة'),
              ],
            ),
          ),

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildActivitiesList(ActivityStatus.upcoming),
                _buildActivitiesList(ActivityStatus.ongoing),
                _buildActivitiesList(ActivityStatus.completed),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      color: Colors.grey[50],
      child: Column(
        children: [
          // Search Bar
          SearchBarWidget(
            hintText: 'البحث في الأنشطة...',
            onChanged: (value) => setState(() => _searchQuery = value),
          ),

          const SizedBox(height: 12),

          // Filters
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<ActivityCategory>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'الفئة',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: ActivityCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category.displayName),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedCategory = value),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedGovernorate,
                  decoration: const InputDecoration(
                    labelText: 'المحافظة',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: AppConstants.governorates.map((gov) {
                    return DropdownMenuItem(value: gov, child: Text(gov));
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedGovernorate = value),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesList(ActivityStatus status) {
    final filteredActivities = _getFilteredActivities(status);

    if (filteredActivities.isEmpty) {
      return _buildEmptyState(status);
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Refresh activities
        await Future.delayed(const Duration(seconds: 1));
      },
      child: AnimationLimiter(
        child: ListView.builder(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          itemCount: filteredActivities.length,
          itemBuilder: (context, index) {
            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 300),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: _buildActivityCard(filteredActivities[index]),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActivityCard(Activity activity) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
      child: InkWell(
        onTap: () => _showActivityDetails(activity),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status and category
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(activity.category).withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      activity.category.displayName,
                      style: TextStyle(
                        color: _getCategoryColor(activity.category),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(activity.status).withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      activity.status.displayName,
                      style: TextStyle(
                        color: _getStatusColor(activity.status),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  const Spacer(),

                  if (!activity.isFree)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${activity.price} ₪',
                        style: const TextStyle(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Title and Type
              Text(
                activity.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              Text(
                activity.type.displayName,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 8),

              // Description
              Text(
                activity.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Date and Location
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            AppDateUtils.formatArabicDate(activity.startDate),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            activity.location,
                            style: Theme.of(context).textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Participants and Registration
              Row(
                children: [
                  if (activity.maxParticipants > 0) ...[
                    const Icon(Icons.group, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${activity.currentParticipants}/${activity.maxParticipants}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),

                    const SizedBox(width: 16),
                  ],

                  Text(
                    'المنظم: ${activity.organizer}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),

                  const Spacer(),

                  if (activity.requiresRegistration &&
                      activity.status == ActivityStatus.upcoming)
                    ElevatedButton(
                      onPressed: () => _registerForActivity(activity),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.islamicGreen,
                        minimumSize: const Size(80, 32),
                      ),
                      child: const Text('تسجيل', style: TextStyle(fontSize: 12)),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ActivityStatus status) {
    String message;
    switch (status) {
      case ActivityStatus.upcoming:
        message = 'لا توجد أنشطة قادمة';
        break;
      case ActivityStatus.ongoing:
        message = 'لا توجد أنشطة جارية';
        break;
      case ActivityStatus.completed:
        message = 'لا توجد أنشطة مكتملة';
        break;
      default:
        message = 'لا توجد أنشطة';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'لم يتم العثور على أنشطة تطابق البحث',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showActivityDetails(Activity activity) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ActivityDetailsBottomSheet(activity: activity),
    );
  }

  void _registerForActivity(Activity activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('التسجيل في ${activity.title}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('هل تريد التسجيل في هذا النشاط؟'),
            const SizedBox(height: 16),
            if (activity.requirements.isNotEmpty) ...[
              const Text('المتطلبات:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...activity.requirements.map((req) => Text('• $req')),
              const SizedBox(height: 16),
            ],
            if (!activity.isFree) ...[
              Text('الرسوم: ${activity.price} شيكل'),
              const SizedBox(height: 8),
            ],
            if (activity.registrationDeadline != null) ...[
              Text('آخر موعد للتسجيل: ${AppDateUtils.formatArabicDate(activity.registrationDeadline!)}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle registration
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم التسجيل في ${activity.title} بنجاح'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.islamicGreen,
            ),
            child: const Text('تسجيل'),
          ),
        ],
      ),
    );
  }

  List<Activity> _getFilteredActivities(ActivityStatus status) {
    return _activities.where((activity) {
      final matchesStatus = activity.status == status;

      final matchesSearch = _searchQuery.isEmpty ||
          activity.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          activity.description.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory = _selectedCategory == null ||
          activity.category == _selectedCategory;

      final matchesGovernorate = _selectedGovernorate == null ||
          activity.governorate == _selectedGovernorate;

      return matchesStatus && matchesSearch && matchesCategory && matchesGovernorate;
    }).toList();
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

  static List<Activity> _getSampleActivities() {
    return [
      Activity(
        id: 1,
        title: 'دورة تحفيظ القرآن الكريم للأطفال',
        description: 'دورة مكثفة لتحفيظ القرآن الكريم للأطفال من سن 6-12 سنة مع تعليم التجويد والتلاوة الصحيحة',
        category: ActivityCategory.religious,
        type: ActivityType.course,
        startDate: DateTime.now().add(const Duration(days: 7)),
        endDate: DateTime.now().add(const Duration(days: 37)),
        location: 'مسجد النور - رام الله',
        organizer: 'جمعية القرآن الكريم',
        maxParticipants: 30,
        currentParticipants: 15,
        status: ActivityStatus.upcoming,
        contact: const ContactInfo(
          name: 'الأستاذ محمد أحمد',
          phone: '+970-59-1234567',
          email: 'quran@example.com',
        ),
        requiresRegistration: true,
        isFree: true,
        governorate: 'رام الله والبيرة',
        requirements: ['عمر من 6-12 سنة', 'إحضار مصحف', 'موافقة ولي الأمر'],
        tags: ['قرآن', 'أطفال', 'تحفيظ'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),

      Activity(
        id: 2,
        title: 'محاضرة: الوسطية في الإسلام',
        description: 'محاضرة علمية حول مفهوم الوسطية في الإسلام ودورها في بناء المجتمع المسلم',
        category: ActivityCategory.educational,
        type: ActivityType.lecture,
        startDate: DateTime.now().add(const Duration(days: 3)),
        location: 'قاعة المؤتمرات - وزارة الأوقاف',
        organizer: 'وزارة الأوقاف والشؤون الدينية',
        maxParticipants: 200,
        currentParticipants: 85,
        status: ActivityStatus.upcoming,
        contact: const ContactInfo(
          name: 'د. أحمد محمود',
          phone: '+970-2-2406340',
          email: 'info@awqaf.ps',
        ),
        requiresRegistration: false,
        isFree: true,
        governorate: 'رام الله والبيرة',
        tags: ['محاضرة', 'وسطية', 'إسلام'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),

      Activity(
        id: 3,
        title: 'مسابقة حفظ الحديث النبوي الشريف',
        description: 'مسابقة سنوية لحفظ الأحاديث النبوية الشريفة للشباب والشابات',
        category: ActivityCategory.religious,
        type: ActivityType.competition,
        startDate: DateTime.now().subtract(const Duration(days: 2)),
        endDate: DateTime.now().add(const Duration(days: 5)),
        location: 'مسجد عمر بن الخطاب - نابلس',
        organizer: 'جمعية الحديث النبوي',
        maxParticipants: 50,
        currentParticipants: 42,
        status: ActivityStatus.ongoing,
        contact: const ContactInfo(
          name: 'الشيخ يوسف عبد الله',
          phone: '+970-59-7654321',
        ),
        requiresRegistration: true,
        isFree: true,
        governorate: 'نابلس',
        requirements: ['عمر من 16-30 سنة', 'حفظ 40 حديث على الأقل'],
        tags: ['مسابقة', 'حديث', 'شباب'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }
}

class ActivityDetailsBottomSheet extends StatelessWidget {
  final Activity activity;

  const ActivityDetailsBottomSheet({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppConstants.radiusL),
            ),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Title and Status
                  Text(
                    activity.title,
                    style: AppTextStyles.headlineSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.islamicGreen.withValues(alpha:0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          activity.type.displayName,
                          style: const TextStyle(
                            color: AppColors.islamicGreen,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha:0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          activity.status.displayName,
                          style: const TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Description
                  Text(
                    activity.description,
                    style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
                  ),

                  const SizedBox(height: 20),

                  // Details
                  _buildDetailRow('التاريخ', AppDateUtils.formatArabicDate(activity.startDate)),
                  _buildDetailRow('الموقع', activity.location),
                  _buildDetailRow('المنظم', activity.organizer),

                  if (activity.maxParticipants > 0)
                    _buildDetailRow('المشاركون', '${activity.currentParticipants}/${activity.maxParticipants}'),

                  if (!activity.isFree && activity.price != null)
                    _buildDetailRow('الرسوم', '${activity.price} شيكل'),

                  const SizedBox(height: 20),

                  // Contact
                  if (activity.contact.phone != null || activity.contact.email != null) ...[
                    Text(
                      'معلومات التواصل',
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (activity.contact.phone != null)
                      _buildContactRow(Icons.phone, activity.contact.phone!),

                    if (activity.contact.email != null)
                      _buildContactRow(Icons.email, activity.contact.email!),
                  ],

                  const SizedBox(height: 20),

                  // Action button
                  if (activity.requiresRegistration && activity.status == ActivityStatus.upcoming)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // Handle registration
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.islamicGreen,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('التسجيل في النشاط'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.islamicGreen),
          const SizedBox(width: 12),
          Text(value, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}