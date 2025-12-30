import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';

class AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final VoidCallback? onBackPressed;
  final PreferredSizeWidget? bottom;

  const AdminAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.actions,
    this.onBackPressed,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: AppTextStyles.titleLarge.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: AppColors.islamicGreen,
      foregroundColor: Colors.white,
      elevation: 2,
      centerTitle: true,
      leading: showBackButton
          ? IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
        tooltip: 'رجوع',
      )
          : null,
      actions: actions ?? _buildDefaultActions(context),
      bottom: bottom,
    );
  }

  List<Widget> _buildDefaultActions(BuildContext context) {
    return [
      // Notifications
      IconButton(
        icon: Stack(
          children: [
            const Icon(Icons.notifications_outlined),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: const Text(
                  '5',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
        onPressed: () {
          // TODO: Navigate to notifications
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('الإشعارات')),
          );
        },
        tooltip: 'الإشعارات',
      ),

      // Settings/Profile Menu
      PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert),
        tooltip: 'القائمة',
        onSelected: (value) => _handleMenuAction(context, value),
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'profile',
            child: Row(
              children: [
                Icon(Icons.person, size: 20),
                SizedBox(width: 12),
                Text('الملف الشخصي'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'settings',
            child: Row(
              children: [
                Icon(Icons.settings, size: 20),
                SizedBox(width: 12),
                Text('الإعدادات'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'help',
            child: Row(
              children: [
                Icon(Icons.help_outline, size: 20),
                SizedBox(width: 12),
                Text('المساعدة'),
              ],
            ),
          ),
          const PopupMenuDivider(),
          const PopupMenuItem(
            value: 'logout',
            child: Row(
              children: [
                Icon(Icons.logout, size: 20, color: AppColors.error),
                SizedBox(width: 12),
                Text('تسجيل الخروج', style: TextStyle(color: AppColors.error)),
              ],
            ),
          ),
        ],
      ),
    ];
  }

  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'profile':
        context.go('/admin/profile');
        break;

      case 'settings':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الإعدادات')),
        );
        // TODO: Navigate to settings
        break;
      case 'help':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('المساعدة')),
        );
        // TODO: Navigate to help
        break;
      case 'logout':
        _showLogoutDialog(context);
        break;
    }
  }

  void _showLogoutDialog(BuildContext context) {
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
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement logout logic
              context.go('/admin/login');
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

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom?.preferredSize.height ?? 0),
  );
}