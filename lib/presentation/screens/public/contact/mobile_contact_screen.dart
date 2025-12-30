import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../widgets/common/custom_app_bar.dart';

class MobileContactScreen extends StatefulWidget {
  const MobileContactScreen({super.key});

  @override
  State<MobileContactScreen> createState() => _MobileContactScreenState();
}

class _MobileContactScreenState extends State<MobileContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

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
      appBar: const CustomAppBar(title: 'اتصل بنا'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.paddingXL),
              decoration: const BoxDecoration(
                gradient: AppColors.islamicGradient,
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.contact_phone,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'نحن هنا لخدمتكم',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'يسعدنا تواصلكم معنا',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.white.withValues(alpha:0.9),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Contact Information Cards
                  _buildContactCard(
                    icon: Icons.location_on,
                    title: 'العنوان',
                    content: AppConstants.address,
                    onTap: _openLocation,
                  ),

                  _buildContactCard(
                    icon: Icons.phone,
                    title: 'الهاتف',
                    content: AppConstants.phoneNumber,
                    onTap: () => _makePhoneCall(AppConstants.phoneNumber),
                  ),

                  _buildContactCard(
                    icon: Icons.email,
                    title: 'البريد الإلكتروني',
                    content: AppConstants.email,
                    onTap: () => _sendEmail(AppConstants.email),
                  ),

                  _buildContactCard(
                    icon: Icons.language,
                    title: 'الموقع الإلكتروني',
                    content: AppConstants.website,
                    onTap: () => _openUrl(AppConstants.website),
                  ),

                  const SizedBox(height: 32),

                  // Contact Form
                  Text(
                    'أرسل لنا رسالة',
                    style: AppTextStyles.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'الاسم',
                            hintText: 'أدخل اسمك',
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'الرجاء إدخال الاسم';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'البريد الإلكتروني',
                            hintText: 'example@email.com',
                            prefixIcon: Icon(Icons.email),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'الرجاء إدخال البريد الإلكتروني';
                            }
                            if (!AppConstants.emailRegex.hasMatch(value!)) {
                              return 'البريد الإلكتروني غير صحيح';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'رقم الهاتف',
                            hintText: '+970-XX-XXXXXXX',
                            prefixIcon: Icon(Icons.phone),
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _subjectController,
                          decoration: const InputDecoration(
                            labelText: 'الموضوع',
                            hintText: 'موضوع الرسالة',
                            prefixIcon: Icon(Icons.subject),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'الرجاء إدخال الموضوع';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _messageController,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            labelText: 'الرسالة',
                            hintText: 'اكتب رسالتك هنا...',
                            prefixIcon: Icon(Icons.message),
                            alignLabelWithHint: true,
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'الرجاء إدخال الرسالة';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submitForm,
                            child: const Text('إرسال الرسالة'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Social Media
                  Text(
                    'تابعنا على وسائل التواصل الاجتماعي',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSocialButton(
                        icon: Icons.facebook,
                        label: 'Facebook',
                        color: const Color(0xFF1877F2),
                        onTap: () => _openUrl(AppConstants.facebookUrl),
                      ),
                      _buildSocialButton(
                        icon: Icons.send,
                        label: 'Twitter',
                        color: const Color(0xFF1DA1F2),
                        onTap: () => _openUrl(AppConstants.twitterUrl),
                      ),
                      _buildSocialButton(
                        icon: Icons.play_arrow,
                        label: 'YouTube',
                        color: const Color(0xFFFF0000),
                        onTap: () => _openUrl(AppConstants.youtubeUrl),
                      ),
                      _buildSocialButton(
                        icon: Icons.camera_alt,
                        label: 'Instagram',
                        color: const Color(0xFFE4405F),
                        onTap: () => _openUrl(AppConstants.instagramUrl),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String content,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.islamicGreen.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  icon,
                  color: AppColors.islamicGreen,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      content,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إرسال رسالتك بنجاح'),
          backgroundColor: AppColors.success,
        ),
      );

      // Clear form
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

  Future<void> _sendEmail(String email) async {
    final url = Uri.parse('mailto:$email');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _openUrl(String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _openLocation() {
    final url = Uri.parse(
      'https://maps.google.com/?q=${AppConstants.defaultLatitude},${AppConstants.defaultLongitude}',
    );
    launchUrl(url, mode: LaunchMode.externalApplication);
  }
}