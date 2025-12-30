// lib/presentation/screens/public/contact_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../widgets/web/web_app_bar.dart';

class WebContactScreen extends StatefulWidget {
  const WebContactScreen({super.key});

  @override
  State<WebContactScreen> createState() => _WebContactScreenState();
}

class _WebContactScreenState extends State<WebContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  String _activeTab = 'contact';
  String _selectedDepartment = 'general';
  String _selectedPriority = 'normal';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const WebAppBar(),
      backgroundColor: AppColors.surfaceVariant,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeroSection(),
            const SizedBox(height: 32),
            _buildQuickStats(),
            const SizedBox(height: 32),
            _buildNavigationTabs(),
            _buildTabContentContainer(),
            const SizedBox(height: 32),
            _buildContactSummary(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        gradient: AppConstants.islamicGradient,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.phone,
              size: 48,
              color: AppConstants.islamicGreen,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'اتصل بنا',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'نحن هنا لخدمتكم والإجابة على استفساراتكم في أي وقت',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withValues(alpha:0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final stats = [
      {'label': 'أقسام الخدمة', 'value': '6', 'icon': Icons.business, 'color': AppConstants.islamicGreen},
      {'label': 'ساعات الخدمة', 'value': '7 ساعات', 'icon': Icons.access_time, 'color': AppColors.goldenYellow},
      {'label': 'المكاتب الفرعية', 'value': '3', 'icon': Icons.location_on, 'color': AppColors.sageGreen},
      {'label': 'وسائل التواصل', 'value': '6', 'icon': Icons.public, 'color': Colors.blue},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: stats.map((stat) {
          return Expanded(
            child: Container(
              margin: const EdgeInsets.only(left: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stat['label'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            stat['value'] as String,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: stat['color'] as Color,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        stat['icon'] as IconData,
                        size: 32,
                        color: (stat['color'] as Color).withValues(alpha:0.3),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNavigationTabs() {
    final tabs = [
      {'id': 'contact', 'name': 'نموذج التواصل', 'icon': Icons.message},
      {'id': 'departments', 'name': 'الأقسام', 'icon': Icons.business},
      {'id': 'locations', 'name': 'المواقع', 'icon': Icons.location_on},
      {'id': 'social', 'name': 'وسائل التواصل', 'icon': Icons.public},
      {'id': 'emergency', 'name': 'الطوارئ', 'icon': Icons.warning},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!),
          ),
        ),
        child: Row(
          children: tabs.map((tab) {
            final isActive = _activeTab == tab['id'];
            return Expanded(
              child: InkWell(
                onTap: () => setState(() => _activeTab = tab['id'] as String),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isActive ? AppConstants.islamicGreen : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        tab['icon'] as IconData,
                        size: 18,
                        color: isActive ? AppConstants.islamicGreen : Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        tab['name'] as String,
                        style: TextStyle(
                          fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                          color: isActive ? AppConstants.islamicGreen : Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTabContentContainer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _buildTabContent(),
    );
  }

  Widget _buildTabContent() {
    switch (_activeTab) {
      case 'contact':
        return _buildContactForm();
      case 'departments':
        return _buildDepartments();
      case 'locations':
        return _buildLocations();
      case 'social':
        return _buildSocialMedia();
      case 'emergency':
        return _buildEmergency();
      default:
        return _buildContactForm();
    }
  }

  Widget _buildContactForm() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'إرسال رسالة',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'الاسم الكامل *',
                              hintText: 'أدخل اسمك الكامل',
                            ),
                            validator: (value) =>
                            value?.isEmpty ?? true ? 'الرجاء إدخال الاسم' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'البريد الإلكتروني *',
                              hintText: 'example@email.com',
                            ),
                            validator: (value) {
                              if (value?.isEmpty ?? true) return 'الرجاء إدخال البريد';
                              if (!AppConstants.emailRegex.hasMatch(value!)) {
                                return 'بريد غير صحيح';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _phoneController,
                            decoration: const InputDecoration(
                              labelText: 'رقم الهاتف',
                              hintText: '+970 59 123 4567',
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedDepartment,
                            decoration: const InputDecoration(
                              labelText: 'القسم المختص',
                            ),
                            items: _getDepartments()
                                .map((dept) => DropdownMenuItem<String>(
                              value: dept['id'] as String,
                              child: Text(dept['name'] as String),
                            ))
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _selectedDepartment = value!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _subjectController,
                            decoration: const InputDecoration(
                              labelText: 'موضوع الرسالة *',
                              hintText: 'موضوع الرسالة',
                            ),
                            validator: (value) =>
                            value?.isEmpty ?? true ? 'الرجاء إدخال الموضوع' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedPriority,
                            decoration: const InputDecoration(
                              labelText: 'الأولوية',
                            ),
                            items: const [
                              DropdownMenuItem(value: 'low', child: Text('منخفضة')),
                              DropdownMenuItem(value: 'normal', child: Text('عادية')),
                              DropdownMenuItem(value: 'high', child: Text('عالية')),
                              DropdownMenuItem(value: 'urgent', child: Text('عاجلة')),
                            ],
                            onChanged: (value) =>
                                setState(() => _selectedPriority = value!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _messageController,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        labelText: 'نص الرسالة *',
                        hintText: 'اكتب رسالتك هنا...',
                        alignLabelWithHint: true,
                      ),
                      validator: (value) =>
                      value?.isEmpty ?? true ? 'الرجاء إدخال الرسالة' : null,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!, width: 2),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[50],
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.upload_file, size: 32, color: Colors.grey[400]),
                          const SizedBox(height: 12),
                          Text(
                            'اسحب الملفات هنا أو انقر للاختيار',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'يدعم: PDF, DOC, JPG, PNG (حد أقصى 10MB)',
                            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _submitForm,
                        icon: const Icon(Icons.send),
                        label: const Text('إرسال الرسالة'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 32),
        Expanded(
          child: Column(
            children: [
              _buildDepartmentInfo(),
              const SizedBox(height: 24),
              _buildQuickContact(),
              const SizedBox(height: 24),
              _buildFAQ(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDepartmentInfo() {
    final dept = _getDepartments().firstWhere(
          (d) => d['id'] == _selectedDepartment,
    );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.goldenYellow.withValues(alpha:0.1),
            AppColors.goldenYellow.withValues(alpha:0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'معلومات القسم المختار',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.goldenYellow, AppColors.goldenYellow.withValues(alpha:0.7)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(dept['icon'] as IconData, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dept['name'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      dept['description'] as String,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.phone, dept['phone'] as String),
          _buildInfoRow(Icons.email, dept['email'] as String),
          _buildInfoRow(Icons.business, dept['office'] as String),
          _buildInfoRow(Icons.person, dept['manager'] as String),
          _buildInfoRow(Icons.access_time, dept['hours'] as String),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.goldenYellow),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickContact() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.sageGreen.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'تواصل سريع',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildQuickContactButton('اتصال مباشر', Icons.phone, Colors.green),
          const SizedBox(height: 8),
          _buildQuickContactButton('واتساب', Icons.message, Colors.green),
          const SizedBox(height: 8),
          _buildQuickContactButton('حجز موعد', Icons.calendar_today, Colors.blue),
        ],
      ),
    );
  }

  Widget _buildQuickContactButton(String label, IconData icon, Color color) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Text(label),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQ() {
    final questions = [
      'كيف يمكنني حجز موعد مع الوزير؟',
      'ما هي أوقات استقبال المواطنين؟',
      'كيف أحصل على فتوى شرعية؟',
      'ما هي خدمات إدارة المساجد؟',
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الأسئلة الشائعة',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...questions.map((q) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.help_outline, size: 16, color: Colors.blue),
                const SizedBox(width: 12),
                Expanded(child: Text(q, style: const TextStyle(fontSize: 13))),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildDepartments() {
    final departments = _getDepartments();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'أقسام الوزارة',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            childAspectRatio: 1.3,
          ),
          itemCount: departments.length,
          itemBuilder: (context, index) {
            final dept = departments[index];
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppConstants.islamicGreen.withValues(alpha:0.05),
                    AppConstants.islamicGreen.withValues(alpha:0.02),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: AppConstants.islamicGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(dept['icon'] as IconData, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dept['name'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              dept['description'] as String,
                              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(Icons.phone, dept['phone'] as String),
                  _buildInfoRow(Icons.email, dept['email'] as String),
                  _buildInfoRow(Icons.business, dept['office'] as String),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedDepartment = dept['id'] as String;
                          _activeTab = 'contact';
                        });
                      },
                      icon: const Icon(Icons.message, size: 16),
                      label: const Text('تواصل مع القسم'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLocations() {
    final locations = [
      {
        'name': 'المقر الرئيسي',
        'address': 'شارع الإرسال، رام الله، فلسطين',
        'phone': '+970 2 298 2500',
        'email': 'info@awqaf.gov.ps',
        'hours': 'الأحد - الخميس: 8:00 ص - 3:00 م',
      },
      {
        'name': 'مكتب غزة',
        'address': 'شارع عمر المختار، غزة، فلسطين',
        'phone': '+970 8 282 3456',
        'email': 'gaza@awqaf.gov.ps',
        'hours': 'الأحد - الخميس: 8:00 ص - 3:00 م',
      },
      {
        'name': 'مكتب نابلس',
        'address': 'البلدة القديمة، نابلس، فلسطين',
        'phone': '+970 9 238 7890',
        'email': 'nablus@awqaf.gov.ps',
        'hours': 'الأحد - الخميس: 8:00 ص - 3:00 م',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'مواقع المكاتب',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        ...locations.map((location) => Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppConstants.islamicGreen.withValues(alpha:0.05),
                AppConstants.islamicGreen.withValues(alpha:0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location['name'] as String,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(Icons.location_on, location['address'] as String),
                    _buildInfoRow(Icons.phone, location['phone'] as String),
                    _buildInfoRow(Icons.email, location['email'] as String),
                    _buildInfoRow(Icons.access_time, location['hours'] as String),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.navigation, size: 16),
                      label: const Text('عرض على الخريطة'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildSocialMedia() {
    final social = [
      {'name': 'فيسبوك', 'icon': Icons.facebook, 'followers': '125K', 'color': Colors.blue},
      {'name': 'تويتر', 'icon': Icons.link, 'followers': '89K', 'color': Colors.lightBlue},
      {'name': 'إنستغرام', 'icon': Icons.camera_alt, 'followers': '67K', 'color': Colors.pink},
      {'name': 'يوتيوب', 'icon': Icons.play_arrow, 'followers': '45K', 'color': Colors.red},
      {'name': 'واتساب', 'icon': Icons.message, 'followers': 'متاح', 'color': Colors.green},
      {'name': 'لينكد إن', 'icon': Icons.business, 'followers': '23K', 'color': Colors.blueAccent},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'وسائل التواصل الاجتماعي',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            childAspectRatio: 1.5,
          ),
          itemCount: social.length,
          itemBuilder: (context, index) {
            final platform = social[index];
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppConstants.islamicGreen.withValues(alpha:0.05),
                    AppConstants.islamicGreen.withValues(alpha:0.02),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha:0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(
                      platform['icon'] as IconData,
                      size: 32,
                      color: platform['color'] as Color,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    platform['name'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${platform['followers']} متابع',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: const Text('زيارة'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEmergency() {
    final emergencyContacts = [
      {
        'title': 'الطوارئ العامة',
        'phone': '+970 59 123 4567',
        'description': 'متاح 24/7 للحالات العاجلة',
        'icon': Icons.warning,
        'color': Colors.red,
      },
      {
        'title': 'الدعم الفني',
        'phone': '+970 59 234 5678',
        'description': 'دعم تقني للخدمات الإلكترونية',
        'icon': Icons.settings,
        'color': Colors.blue,
      },
      {
        'title': 'خدمة العملاء',
        'phone': '+970 59 345 6789',
        'description': 'استفسارات ومساعدة عامة',
        'icon': Icons.headphones,
        'color': Colors.green,
      },
    ];

    return Column(
      children: [
        const Text(
          'أرقام الطوارئ',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        Row(
          children: emergencyContacts.map((contact) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border(
                    right: BorderSide(color: contact['color'] as Color, width: 4),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: (contact['color'] as Color).withValues(alpha:0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            contact['icon'] as IconData,
                            color: contact['color'] as Color,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                contact['title'] as String,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                contact['description'] as String,
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      contact['phone'] as String,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: contact['color'] as Color,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _makePhoneCall(contact['phone'] as String),
                        icon: const Icon(Icons.phone),
                        label: const Text('اتصال فوري'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: contact['color'] as Color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppConstants.islamicGreen.withValues(alpha:0.05),
                AppConstants.islamicGreen.withValues(alpha:0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(Icons.warning_amber, size: 64, color: Colors.red[700]),
              const SizedBox(height: 16),
              const Text(
                'تنبيه مهم',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'أرقام الطوارئ مخصصة للحالات العاجلة فقط. للاستفسارات العادية يرجى استخدام القنوات الاعتيادية للتواصل.',
                style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactSummary() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.islamicGreen.withValues(alpha:0.05),
            AppConstants.islamicGreen.withValues(alpha:0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Text(
            'ملخص معلومات التواصل',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: AppConstants.islamicGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.phone, color: Colors.white, size: 32),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'الهاتف الرئيسي',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '+970 2 298 2500',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.islamicGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'متاح خلال ساعات العمل',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.goldenYellow, AppColors.goldenYellow.withValues(alpha:0.7)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.email, color: Colors.white, size: 32),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'البريد الإلكتروني',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'info@awqaf.gov.ps',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.goldenYellow,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'للمراسلات الرسمية',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.sageGreen, AppColors.sageGreen.withValues(alpha:0.7)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.location_on, color: Colors.white, size: 32),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'العنوان',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'شارع الإرسال، رام الله',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.sageGreen,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'المقر الرئيسي',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getDepartments() {
    return [
      {
        'id': 'general',
        'name': 'الاستعلامات العامة',
        'icon': Icons.info,
        'phone': '+970 2 298 2500',
        'email': 'info@awqaf.gov.ps',
        'manager': 'الأستاذ محمد أحمد',
        'office': 'الطابق الأول - مكتب 101',
        'hours': 'الأحد - الخميس: 8:00 ص - 3:00 م',
        'description': 'للاستفسارات العامة',
      },
      {
        'id': 'mosques',
        'name': 'إدارة المساجد',
        'icon': Icons.mosque,
        'phone': '+970 2 298 2534',
        'email': 'mosques@awqaf.gov.ps',
        'manager': 'الأستاذ أحمد محمد',
        'office': 'الطابق الثاني - مكتب 201',
        'hours': 'الأحد - الخميس: 8:00 ص - 3:00 م',
        'description': 'خدمات المساجد',
      },
      {
        'id': 'religious',
        'name': 'الشؤون الدينية',
        'icon': Icons.menu_book,
        'phone': '+970 2 298 2535',
        'email': 'fatwa@awqaf.gov.ps',
        'manager': 'الشيخ محمد علي',
        'office': 'الطابق الثاني - مكتب 205',
        'hours': 'الأحد - الخميس: 8:00 ص - 3:00 م',
        'description': 'الفتاوى والإرشاد',
      },
      {
        'id': 'education',
        'name': 'التعليم الديني',
        'icon': Icons.school,
        'phone': '+970 2 298 2536',
        'email': 'education@awqaf.gov.ps',
        'manager': 'الدكتور نور الدين',
        'office': 'الطابق الثالث - مكتب 301',
        'hours': 'الأحد - الخميس: 8:00 ص - 3:00 م',
        'description': 'برامج التعليم',
      },
      {
        'id': 'social',
        'name': 'الخدمات الاجتماعية',
        'icon': Icons.favorite,
        'phone': '+970 2 298 2539',
        'email': 'social@awqaf.gov.ps',
        'manager': 'الأستاذة فاطمة خالد',
        'office': 'الطابق الأول - مكتب 105',
        'hours': 'الأحد - الخميس: 8:00 ص - 3:00 م',
        'description': 'المساعدات والدعم',
      },
      {
        'id': 'media',
        'name': 'الإعلام والعلاقات',
        'icon': Icons.campaign,
        'phone': '+970 2 298 2540',
        'email': 'media@awqaf.gov.ps',
        'manager': 'الأستاذ سامر محمود',
        'office': 'الطابق الثالث - مكتب 305',
        'hours': 'الأحد - الخميس: 8:00 ص - 3:00 م',
        'description': 'الإعلام والتواصل',
      },
    ];
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إرسال رسالتك بنجاح'),
          backgroundColor: AppColors.success,
        ),
      );
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _subjectController.clear();
      _messageController.clear();
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}