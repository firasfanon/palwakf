import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqf/presentation/providers/footer_settings_provider.dart';
import 'package:waqf/presentation/screens/admin/main/management/home_management/widgets/common/section_header.dart';
import 'package:waqf/presentation/screens/admin/main/management/home_management/widgets/common/settings_text_field.dart';

class FooterSettingsSection extends ConsumerStatefulWidget {
  const FooterSettingsSection({super.key});

  @override
  ConsumerState<FooterSettingsSection> createState() =>
      _FooterSettingsSectionState();
}

class _FooterSettingsSectionState extends ConsumerState<FooterSettingsSection> {
  final _logoController = TextEditingController();
  final _ministryNameController = TextEditingController();
  final _ministrySubtitleController = TextEditingController();
  final _ministryDescriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _faxController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _workingDaysController = TextEditingController();
  final _workingHoursController = TextEditingController();
  final _facebookController = TextEditingController();
  final _twitterController = TextEditingController();
  final _instagramController = TextEditingController();
  final _youtubeController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _copyrightController = TextEditingController();
  final _developerCreditController = TextEditingController();

  bool _showPartners = true;
  bool _showDeveloperCredit = true;
  bool _showPhone = true;
  bool _showEmail = true;
  bool _showAddress = true;
  bool _showWorkingHours = true;
  bool _hydrated = false;

  @override
  void dispose() {
    _logoController.dispose();
    _ministryNameController.dispose();
    _ministrySubtitleController.dispose();
    _ministryDescriptionController.dispose();
    _phoneController.dispose();
    _faxController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _workingDaysController.dispose();
    _workingHoursController.dispose();
    _facebookController.dispose();
    _twitterController.dispose();
    _instagramController.dispose();
    _youtubeController.dispose();
    _linkedinController.dispose();
    _copyrightController.dispose();
    _developerCreditController.dispose();
    super.dispose();
  }

  void _hydrateIfNeeded(FooterSettingsState state) {
    if (_hydrated || state.settings == null) return;
    final s = state.settings!;
    _logoController.text = s.ministryLogoUrl ?? '';
    _ministryNameController.text = s.ministryName;
    _ministrySubtitleController.text = s.ministrySubtitle;
    _ministryDescriptionController.text = s.ministryDescription ?? '';
    _phoneController.text = s.contactPhone ?? '';
    _faxController.text = s.contactFax ?? '';
    _emailController.text = s.contactEmail ?? '';
    _addressController.text = s.contactAddress ?? '';
    _workingDaysController.text = s.workingDays;
    _workingHoursController.text = s.workingHours;
    _facebookController.text = s.facebookUrl ?? '';
    _twitterController.text = s.twitterUrl ?? '';
    _instagramController.text = s.instagramUrl ?? '';
    _youtubeController.text = s.youtubeUrl ?? '';
    _linkedinController.text = s.linkedinUrl ?? '';
    _copyrightController.text = s.copyrightText;
    _developerCreditController.text = s.developerCredit;
    _showPartners = s.showPartners;
    _showDeveloperCredit = s.showDeveloperCredit;
    _showPhone = s.showPhone;
    _showEmail = s.showEmail;
    _showAddress = s.showAddress;
    _showWorkingHours = s.showWorkingHours;
    _hydrated = true;
  }

  void _pushChanges() {
    final current = ref.read(footerSettingsProvider).settings;
    if (current == null) return;

    ref.read(footerSettingsProvider.notifier).updateSettings(
      current.copyWith(
        ministryLogoUrl: _logoController.text.isEmpty
            ? null
            : _logoController.text,
        ministryName: _ministryNameController.text,
        ministrySubtitle: _ministrySubtitleController.text,
        ministryDescription: _ministryDescriptionController.text.isEmpty
            ? null
            : _ministryDescriptionController.text,
        contactPhone:
        _phoneController.text.isEmpty ? null : _phoneController.text,
        contactFax:
        _faxController.text.isEmpty ? null : _faxController.text,
        contactEmail:
        _emailController.text.isEmpty ? null : _emailController.text,
        contactAddress: _addressController.text.isEmpty
            ? null
            : _addressController.text,
        workingDays: _workingDaysController.text,
        workingHours: _workingHoursController.text,
        facebookUrl: _facebookController.text.isEmpty
            ? null
            : _facebookController.text,
        twitterUrl: _twitterController.text.isEmpty
            ? null
            : _twitterController.text,
        instagramUrl: _instagramController.text.isEmpty
            ? null
            : _instagramController.text,
        youtubeUrl: _youtubeController.text.isEmpty
            ? null
            : _youtubeController.text,
        linkedinUrl: _linkedinController.text.isEmpty
            ? null
            : _linkedinController.text,
        copyrightText: _copyrightController.text,
        developerCredit: _developerCreditController.text,
        showPartners: _showPartners,
        showDeveloperCredit: _showDeveloperCredit,
        showPhone: _showPhone,
        showEmail: _showEmail,
        showAddress: _showAddress,
        showWorkingHours: _showWorkingHours,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(footerSettingsProvider);
    _hydrateIfNeeded(state);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Text(
          'خطأ: ${state.error}',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildMinistryInfoSection(),
          const SizedBox(height: 24),
          _buildContactInfoSection(),
          const SizedBox(height: 24),
          _buildSocialMediaSection(),
          const SizedBox(height: 24),
          _buildCopyrightSection(),
        ],
      ),
    );
  }

  Widget _buildMinistryInfoSection() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.teal.withValues(alpha:0.05),
            Colors.teal.withValues(alpha:0.02)
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.teal.withValues(alpha:0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            icon: Icons.info,
            title: 'معلومات الوزارة',
            color: Colors.teal,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: SettingsTextField(
                  label: 'رابط الشعار',
                  controller: _logoController,
                  hint: 'https://example.com/logo.png',
                  labelColor: Colors.teal,
                  onChanged: (_) => _pushChanges(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SettingsTextField(
                  label: 'اسم الوزارة',
                  controller: _ministryNameController,
                  hint: 'وزارة الأوقاف',
                  labelColor: Colors.teal,
                  onChanged: (_) => _pushChanges(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SettingsTextField(
            label: 'العنوان الفرعي',
            controller: _ministrySubtitleController,
            hint: 'دولة فلسطين',
            labelColor: Colors.teal,
            onChanged: (_) => _pushChanges(),
          ),
          const SizedBox(height: 20),
          SettingsTextField(
            label: 'وصف الوزارة',
            controller: _ministryDescriptionController,
            hint: 'وصف مختصر للوزارة وأهدافها',
            maxLines: 3,
            labelColor: Colors.teal,
            onChanged: (_) => _pushChanges(),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoSection() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withValues(alpha:0.05),
            Colors.orange.withValues(alpha:0.02)
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withValues(alpha:0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            icon: Icons.phone,
            title: 'معلومات التواصل',
            color: Colors.orange,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    SettingsTextField(
                      label: 'رقم الهاتف',
                      controller: _phoneController,
                      hint: '02-2411937/8/9',
                      labelColor: Colors.orange,
                      onChanged: (_) => _pushChanges(),
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      title: const Text('عرض رقم الهاتف'),
                      value: _showPhone,
                      onChanged: (v) {
                        setState(() => _showPhone = v ?? true);
                        _pushChanges();
                      },
                      activeColor: Colors.orange,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SettingsTextField(
                  label: 'رقم الفاكس',
                  controller: _faxController,
                  hint: '02-2411934',
                  labelColor: Colors.orange,
                  onChanged: (_) => _pushChanges(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    SettingsTextField(
                      label: 'البريد الإلكتروني',
                      controller: _emailController,
                      hint: 'info@awqaf.ps',
                      labelColor: Colors.orange,
                      onChanged: (_) => _pushChanges(),
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      title: const Text('عرض البريد الإلكتروني'),
                      value: _showEmail,
                      onChanged: (v) {
                        setState(() => _showEmail = v ?? true);
                        _pushChanges();
                      },
                      activeColor: Colors.orange,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    SettingsTextField(
                      label: 'العنوان',
                      controller: _addressController,
                      hint: 'القدس - مدينة البيرة',
                      maxLines: 2,
                      labelColor: Colors.orange,
                      onChanged: (_) => _pushChanges(),
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      title: const Text('عرض العنوان'),
                      value: _showAddress,
                      onChanged: (v) {
                        setState(() => _showAddress = v ?? true);
                        _pushChanges();
                      },
                      activeColor: Colors.orange,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SettingsTextField(
                  label: 'أيام العمل',
                  controller: _workingDaysController,
                  hint: 'من الأحد إلى الخميس',
                  labelColor: Colors.orange,
                  onChanged: (_) => _pushChanges(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: [
                    SettingsTextField(
                      label: 'ساعات العمل',
                      controller: _workingHoursController,
                      hint: '8:00 صباحاً - 3:00 مساءً',
                      labelColor: Colors.orange,
                      onChanged: (_) => _pushChanges(),
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      title: const Text('عرض ساعات العمل'),
                      value: _showWorkingHours,
                      onChanged: (v) {
                        setState(() => _showWorkingHours = v ?? true);
                        _pushChanges();
                      },
                      activeColor: Colors.orange,
                      contentPadding: EdgeInsets.zero,
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

  Widget _buildSocialMediaSection() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withValues(alpha:0.05),
            Colors.purple.withValues(alpha:0.02)
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.withValues(alpha:0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            icon: Icons.share,
            title: 'وسائل التواصل الاجتماعي',
            color: Colors.purple,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: SettingsTextField(
                  label: 'فيسبوك',
                  controller: _facebookController,
                  hint: 'https://facebook.com/awqaf.ps',
                  labelColor: Colors.purple,
                  onChanged: (_) => _pushChanges(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SettingsTextField(
                  label: 'تويتر',
                  controller: _twitterController,
                  hint: 'https://twitter.com/awqaf_ps',
                  labelColor: Colors.purple,
                  onChanged: (_) => _pushChanges(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: SettingsTextField(
                  label: 'إنستغرام',
                  controller: _instagramController,
                  hint: 'https://instagram.com/awqaf.ps',
                  labelColor: Colors.purple,
                  onChanged: (_) => _pushChanges(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SettingsTextField(
                  label: 'يوتيوب',
                  controller: _youtubeController,
                  hint: 'https://youtube.com/awqafps',
                  labelColor: Colors.purple,
                  onChanged: (_) => _pushChanges(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SettingsTextField(
            label: 'لينكد إن',
            controller: _linkedinController,
            hint: 'https://linkedin.com/company/awqaf-ps',
            labelColor: Colors.purple,
            onChanged: (_) => _pushChanges(),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyrightSection() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey.withValues(alpha:0.05),
            Colors.grey.withValues(alpha:0.02)
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha:0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.copyright,
            title: 'حقوق النشر والاعتمادات',
            color: Colors.grey[700]!,
          ),
          const SizedBox(height: 24),
          SettingsTextField(
            label: 'نص حقوق النشر',
            controller: _copyrightController,
            hint:
            '© 2024 وزارة الأوقاف والشؤون الدينية - دولة فلسطين. جميع الحقوق محفوظة.',
            maxLines: 2,
            labelColor: Colors.grey[700],
            onChanged: (_) => _pushChanges(),
          ),
          const SizedBox(height: 20),
          SettingsTextField(
            label: 'نص المطور',
            controller: _developerCreditController,
            hint: 'تم التطوير بواسطة فريق تقنية المعلومات',
            labelColor: Colors.grey[700],
            onChanged: (_) => _pushChanges(),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  title: const Text('عرض معلومات المطور'),
                  value: _showDeveloperCredit,
                  onChanged: (v) {
                    setState(() => _showDeveloperCredit = v ?? true);
                    _pushChanges();
                  },
                  activeColor: Colors.grey[700],
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: CheckboxListTile(
                  title: const Text('عرض قسم الشركاء'),
                  value: _showPartners,
                  onChanged: (v) {
                    setState(() => _showPartners = v ?? true);
                    _pushChanges();
                  },
                  activeColor: Colors.grey[700],
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}