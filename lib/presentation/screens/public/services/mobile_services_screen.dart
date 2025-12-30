import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../app/routing/app_routes.dart';
import '../../../widgets/common/custom_app_bar.dart';

class MobileServicesScreen extends StatefulWidget {
  const MobileServicesScreen({super.key});

  @override
  State<MobileServicesScreen> createState() => _MobileServicesScreenState();
}

class _MobileServicesScreenState extends State<MobileServicesScreen> {
  String _searchQuery = '';
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'خدمات الوزارة',
        showSearchButton: true,
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingM),
            color: Colors.grey[50],
            child: Column(
              children: [
                // Search Bar
                TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    hintText: 'البحث في الخدمات...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),

                const SizedBox(height: 12),

                // Category Filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryChip('الكل', null),
                      ...AppConstants.serviceCategories.map((category) {
                        return _buildCategoryChip(category, category);
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Services Grid
          Expanded(
            child: _buildServicesGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, String? category) {
    final isSelected = _selectedCategory == category;

    return Container(
      margin: const EdgeInsets.only(left: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? category : null;
          });
        },
        selectedColor: AppConstants.islamicGreen.withValues(alpha:0.2),
        checkmarkColor: AppConstants.islamicGreen,
        side: BorderSide(
          color: isSelected ? AppConstants.islamicGreen : Colors.grey[300]!,
        ),
      ),
    );
  }

  Widget _buildServicesGrid() {
    final services = _getFilteredServices();

    if (services.isEmpty) {
      return _buildEmptyState();
    }

    return AnimationLimiter(
      child: GridView.builder(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
        ),
        itemCount: services.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 300),
            columnCount: 2,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: _buildServiceCard(services[index]),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildServiceCard(ServiceItem service) {
    return GestureDetector(
      onTap: () => _handleServiceTap(service),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: service.color.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                service.icon,
                size: 30,
                color: service.color,
              ),
            ),

            const SizedBox(height: 12),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                service.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 6),

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                service.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 8),

            // Status
            if (service.isAvailable)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppConstants.success.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'متاح',
                  style: TextStyle(
                    color: AppConstants.success,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppConstants.warning.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'قريباً',
                  style: TextStyle(
                    color: AppConstants.warning,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.miscellaneous_services,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد خدمات',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'لم يتم العثور على خدمات تطابق البحث',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  List<ServiceItem> _getFilteredServices() {
    final services = [
      ServiceItem(
        title: 'تراخيص الخطابة',
        description: 'طلب ترخيص للخطابة في المساجد',
        category: 'خدمات المساجد',
        icon: Icons.mic,
        color: AppConstants.islamicGreen,
        isAvailable: true,
        type: ServiceType.form,
      ),
      ServiceItem(
        title: 'تسجيل مسجد جديد',
        description: 'تسجيل وترخيص مسجد جديد',
        category: 'خدمات المساجد',
        icon: Icons.mosque,
        color: AppConstants.goldenYellow,
        isAvailable: true,
        type: ServiceType.form,
      ),
      ServiceItem(
        title: 'طلب دعم مالي',
        description: 'طلب دعم مالي للمساجد والمراكز',
        category: 'الأوقاف الإسلامية',
        icon: Icons.attach_money,
        color: AppConstants.success,
        isAvailable: true,
        type: ServiceType.form,
      ),
      ServiceItem(
        title: 'شهادة حسن سيرة وسلوك',
        description: 'استخراج شهادة حسن سيرة وسلوك',
        category: 'الشؤون الدينية',
        icon: Icons.verified_user,
        color: AppConstants.info,
        isAvailable: true,
        type: ServiceType.form,
      ),
      ServiceItem(
        title: 'التسجيل في دورات تدريبية',
        description: 'التسجيل في الدورات التدريبية للأئمة',
        category: 'التعليم الديني',
        icon: Icons.school,
        color: Colors.purple,
        isAvailable: true,
        type: ServiceType.registration,
      ),
      ServiceItem(
        title: 'حجز موعد مع الوزير',
        description: 'حجز موعد لمقابلة معالي الوزير',
        category: 'خدمات إدارية',
        icon: Icons.event,
        color: AppConstants.sageGreen,
        isAvailable: true,
        type: ServiceType.appointment,
      ),
      ServiceItem(
        title: 'تصاريح الحج والعمرة',
        description: 'استخراج تصاريح الحج والعمرة',
        category: 'الحج والعمرة',
        icon: Icons.flight,
        color: Colors.orange,
        isAvailable: false,
        type: ServiceType.form,
      ),
      ServiceItem(
        title: 'استشارات دينية',
        description: 'طلب استشارة دينية من المختصين',
        category: 'الفتاوى والإرشاد',
        icon: Icons.help,
        color: Colors.teal,
        isAvailable: true,
        type: ServiceType.consultation,
      ),
    ];

    return services.where((service) {
      final matchesSearch = _searchQuery.isEmpty ||
          service.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          service.description.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesCategory = _selectedCategory == null ||
          service.category == _selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  void _handleServiceTap(ServiceItem service) {
    if (!service.isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('هذه الخدمة غير متاحة حالياً'),
          backgroundColor: AppConstants.warning,
        ),
      );
      return;
    }

    switch (service.type) {
      case ServiceType.form:
        context.go(AppRoutes.eservices);
        break;
      case ServiceType.registration:
        _showRegistrationDialog(service);
        break;
      case ServiceType.appointment:
        _showAppointmentDialog(service);
        break;
      case ServiceType.consultation:
        _showConsultationDialog(service);
        break;
      case ServiceType.external:
        _launchExternalService(service);
        break;
    }
  }

  void _showRegistrationDialog(ServiceItem service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(service.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(service.description),
            const SizedBox(height: 16),
            const Text('للتسجيل في هذه الخدمة، يرجى زيارة أقرب مكتب أوقاف أو الاتصال بالرقم التالي:'),
            const SizedBox(height: 8),
            const SelectableText(
              '+970-2-2406340',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _makePhoneCall('+970-2-2406340');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.islamicGreen,
            ),
            child: const Text('اتصال'),
          ),
        ],
      ),
    );
  }

  void _showAppointmentDialog(ServiceItem service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(service.title),
        content: const Text('لحجز موعد، يرجى الاتصال بسكرتارية الوزير على الرقم التالي خلال ساعات العمل الرسمية.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _makePhoneCall('+970-2-2406340');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.islamicGreen,
            ),
            child: const Text('اتصال'),
          ),
        ],
      ),
    );
  }

  void _showConsultationDialog(ServiceItem service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(service.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(service.description),
            const SizedBox(height: 16),
            const Text('يمكنك طلب الاستشارة عبر:'),
            const SizedBox(height: 8),
            const Text('• الهاتف: +970-2-2406340'),
            const Text('• البريد الإلكتروني: fatwa@awqaf.ps'),
            const Text('• زيارة مكتب الإفتاء في الوزارة'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _sendEmail('fatwa@awqaf.ps');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.islamicGreen,
            ),
            child: const Text('إرسال بريد'),
          ),
        ],
      ),
    );
  }

  void _launchExternalService(ServiceItem service) async {
    // Launch external URL
    const url = 'https://www.awqaf.ps';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _makePhoneCall(String phoneNumber) async {
    final url = 'tel:$phoneNumber';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _sendEmail(String email) async {
    final url = 'mailto:$email';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
}

// EServices Screen
class EServicesScreen extends StatefulWidget {
  const EServicesScreen({super.key});

  @override
  State<EServicesScreen> createState() => _EServicesScreenState();
}

class _EServicesScreenState extends State<EServicesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'الخدمات الإلكترونية',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingL),
              decoration: BoxDecoration(
                gradient: AppConstants.islamicGradient,
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.computer,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'الخدمات الإلكترونية',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'احصل على الخدمات الحكومية بطريقة سهلة وسريعة',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha:0.9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Forms Section
            Text(
              'النماذج الإلكترونية',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppConstants.islamicGreen,
              ),
            ),
            const SizedBox(height: 16),

            _buildFormsList(),

            const SizedBox(height: 24),

            // Help Section
            Container(
              padding: const EdgeInsets.all(AppConstants.paddingL),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                border: Border.all(color: Colors.blue.withValues(alpha:0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.help_outline,
                        color: Colors.blue[700],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'تحتاج مساعدة؟',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('للحصول على المساعدة في استخدام الخدمات الإلكترونية:'),
                  const SizedBox(height: 8),
                  const Text('• اتصل بالدعم الفني: +970-2-2406340'),
                  const Text('• أرسل بريد إلكتروني: support@awqaf.ps'),
                  const Text('• زر مركز خدمة المواطنين'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormsList() {
    final forms = [
      EServiceForm(
        title: 'طلب ترخيص خطابة',
        description: 'نموذج لطلب ترخيص للخطابة في المساجد',
        icon: Icons.mic,
        estimatedTime: '10 دقائق',
        requiredDocuments: ['هوية شخصية', 'شهادة جامعية', 'صورة شخصية'],
      ),
      EServiceForm(
        title: 'تسجيل مسجد جديد',
        description: 'نموذج لتسجيل وترخيص مسجد جديد',
        icon: Icons.mosque,
        estimatedTime: '15 دقيقة',
        requiredDocuments: ['وثيقة ملكية الأرض', 'مخططات البناء', 'موافقة البلدية'],
      ),
      EServiceForm(
        title: 'طلب دعم مالي',
        description: 'نموذج لطلب دعم مالي للمساجد والمراكز الدينية',
        icon: Icons.attach_money,
        estimatedTime: '20 دقيقة',
        requiredDocuments: ['بيان مالي', 'تقرير المشروع', 'تزكيات'],
      ),
    ];

    return Column(
      children: forms.map((form) => _buildFormCard(form)).toList(),
    );
  }

  Widget _buildFormCard(EServiceForm form) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppConstants.paddingM),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppConstants.islamicGreen.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(
            form.icon,
            color: AppConstants.islamicGreen,
          ),
        ),
        title: Text(
          form.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(form.description),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  form.estimatedTime,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () => _openForm(form),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.islamicGreen,
            minimumSize: const Size(80, 36),
          ),
          child: const Text(
            'ابدأ',
            style: TextStyle(fontSize: 12),
          ),
        ),
      ),
    );
  }

  void _openForm(EServiceForm form) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(form.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(form.description),
            const SizedBox(height: 16),
            const Text(
              'المستندات المطلوبة:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...form.requiredDocuments.map((doc) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, size: 16, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(child: Text(doc)),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'سيتم توجيهك إلى النموذج الإلكتروني. تأكد من توفر جميع المستندات المطلوبة قبل البدء.',
                style: TextStyle(fontSize: 13),
              ),
            ),
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
              // Open form - in real app, this would navigate to actual form
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('فتح نموذج: ${form.title}'),
                  backgroundColor: AppConstants.islamicGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.islamicGreen,
            ),
            child: const Text('متابعة'),
          ),
        ],
      ),
    );
  }
}

// Data Models
class ServiceItem {
  final String title;
  final String description;
  final String category;
  final IconData icon;
  final Color color;
  final bool isAvailable;
  final ServiceType type;

  ServiceItem({
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    required this.color,
    required this.isAvailable,
    required this.type,
  });
}

class EServiceForm {
  final String title;
  final String description;
  final IconData icon;
  final String estimatedTime;
  final List<String> requiredDocuments;

  EServiceForm({
    required this.title,
    required this.description,
    required this.icon,
    required this.estimatedTime,
    required this.requiredDocuments,
  });
}

enum ServiceType {
  form,
  registration,
  appointment,
  consultation,
  external,
}