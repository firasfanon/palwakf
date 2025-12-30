// lib/presentation/screens/admin/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqf/core/constants/app_constants.dart';
import 'package:waqf/presentation/providers/auth_provider.dart';
import 'package:waqf/presentation/widgets/common/admin_app_bar.dart';


class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _departmentController;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _nameController = TextEditingController(text: user?.name ?? '');
    _departmentController = TextEditingController(text: user?.department ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final authState = ref.watch(authStateProvider);

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('لم يتم العثور على بيانات المستخدم'),
        ),
      );
    }

    return Scaffold(
      appBar: const AdminAppBar(
        title: 'الملف الشخصي',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(user),

            const SizedBox(height: 32),

            // Profile Form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingL),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'المعلومات الشخصية',
                            style: AppTextStyles.titleLarge.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(_isEditing ? Icons.close : Icons.edit),
                            onPressed: () {
                              setState(() {
                                _isEditing = !_isEditing;
                                if (!_isEditing) {
                                  // Reset form
                                  _nameController.text = user.name;
                                  _departmentController.text = user.department ?? '';
                                }
                              });
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Email (Read-only)
                      _buildInfoField(
                        label: 'البريد الإلكتروني',
                        value: user.email,
                        icon: Icons.email,
                        isEditable: false,
                      ),

                      const SizedBox(height: 16),

                      // Name
                      _isEditing
                          ? TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'الاسم',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'يرجى إدخال الاسم';
                          }
                          return null;
                        },
                      )
                          : _buildInfoField(
                        label: 'الاسم',
                        value: user.name,
                        icon: Icons.person,
                        isEditable: false,
                      ),

                      const SizedBox(height: 16),

                      // Department
                      _isEditing
                          ? TextFormField(
                        controller: _departmentController,
                        decoration: const InputDecoration(
                          labelText: 'القسم',
                          prefixIcon: Icon(Icons.business),
                        ),
                      )
                          : _buildInfoField(
                        label: 'القسم',
                        value: user.department ?? 'غير محدد',
                        icon: Icons.business,
                        isEditable: false,
                      ),

                      const SizedBox(height: 16),

                      // Role (Read-only)
                      _buildInfoField(
                        label: 'الدور',
                        value: user.roleEnum.displayName,
                        icon: Icons.badge,
                        isEditable: false,
                      ),

                      const SizedBox(height: 16),

                      // Status (Read-only)
                      _buildInfoField(
                        label: 'الحالة',
                        value: user.isActive ? 'نشط' : 'غير نشط',
                        icon: Icons.check_circle,
                        isEditable: false,
                        valueColor: user.isActive ? AppColors.success : AppColors.error,
                      ),

                      if (_isEditing) ...[
                        const SizedBox(height: 24),

                        // Save Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: authState.isLoading ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.islamicGreen,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: authState.isLoading
                                ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                                : const Text('حفظ التغييرات'),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Change Password Card
            Card(
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.lock, color: AppColors.info),
                ),
                title: const Text('تغيير كلمة المرور'),
                subtitle: const Text('تحديث كلمة المرور الخاصة بك'),
                trailing: const Icon(Icons.chevron_right),
                onTap: _showChangePasswordDialog,
              ),
            ),

            const SizedBox(height: 16),

            // Logout Card
            Card(
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.logout, color: AppColors.error),
                ),
                title: const Text(
                  'تسجيل الخروج',
                  style: TextStyle(color: AppColors.error),
                ),
                subtitle: const Text('الخروج من حسابك'),
                trailing: const Icon(Icons.chevron_right, color: AppColors.error),
                onTap: _showLogoutDialog,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(user) {
    return Container(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        decoration: BoxDecoration(
          gradient: AppColors.islamicGradient,
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        child: Column(
          children: [
          // Avatar
          Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
          ),
          child: Center(
            child: Text(
              user.name.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: AppColors.islamicGreen,
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Name
        Text(
          user.name,
          style: AppTextStyles.headlineSmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 4),

        // Email
        Text(
          user.email,
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white.withValues(alpha:0.9),
          ),
        ),

        const SizedBox(height: 8),

        // Role Badge
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.goldenYellow,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
                user.roleEnum.displayName,
                style: const TextStyle(color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
            ),
        ),
          ],
        ),
    );
  }

  Widget _buildInfoField({
    required String label,
    required String value,
    required IconData icon,
    required bool isEditable,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: valueColor ?? Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserProvider);
    if (user == null) return;

    try {
      await ref.read(authStateProvider.notifier).updateProfile(
        name: _nameController.text.trim(),
        department: _departmentController.text.trim(),
      );

      setState(() {
        _isEditing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث الملف الشخصي بنجاح'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تغيير كلمة المرور'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور الحالية',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'يرجى إدخال كلمة المرور الحالية';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور الجديدة',
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'يرجى إدخال كلمة المرور الجديدة';
                  }
                  if (value!.length < 6) {
                    return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'تأكيد كلمة المرور',
                  prefixIcon: Icon(Icons.lock),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'يرجى تأكيد كلمة المرور';
                  }
                  if (value != newPasswordController.text) {
                    return 'كلمة المرور غير متطابقة';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              try {
                // Note: You'll need to add updatePassword to AuthRepository
                await ref.read(authStateProvider.notifier).updatePassword(
                  newPasswordController.text,
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم تغيير كلمة المرور بنجاح'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString().replaceAll('Exception: ', '')),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.islamicGreen,
            ),
            child: const Text('تغيير'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(),
                ),
              );

              // Logout
              await ref.read(authStateProvider.notifier).logout();

              // Navigation handled by auth state listener
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}