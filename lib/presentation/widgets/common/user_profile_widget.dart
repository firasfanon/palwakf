import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/greeting_utils.dart';
import '../../../app/routing/app_routes.dart';
import '../../providers/auth_provider.dart';

class UserProfileWidget extends ConsumerStatefulWidget {
  /// Should the greeting be shown? (Set to false for compact mode)
  final bool showGreeting;

  /// Custom greeting text (overrides time-based greeting)
  final String? customGreeting;

  const UserProfileWidget({
    super.key,
    this.showGreeting = true,
    this.customGreeting,
  });

  @override
  ConsumerState<UserProfileWidget> createState() => _UserProfileWidgetState();
}

class _UserProfileWidgetState extends ConsumerState<UserProfileWidget> {
  @override
  Widget build(BuildContext context) {
    // Get current user from auth provider
    final currentUser = ref.watch(currentUserProvider);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    // Determine display name
    final displayName = currentUser?.name ?? 'ضيف';
    final isGuest = !isAuthenticated;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Greeting Section
        if (widget.showGreeting) ...[
          _buildGreetingSection(),
          const SizedBox(width: 12),
        ],

        // User Avatar with Dropdown
        _buildUserAvatarMenu(
          displayName: displayName,
          isGuest: isGuest,
          currentUser: currentUser,
        ),
      ],
    );
  }

  /// Greeting section with time-based icon and text
  Widget _buildGreetingSection() {
    final greeting = widget.customGreeting ?? GreetingUtils.getGreeting();
    final greetingIcon = GreetingUtils.getGreetingIcon();
    final greetingColor = GreetingUtils.getGreetingColor();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: greetingColor.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: greetingColor.withValues(alpha:0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            greetingIcon,
            size: 18,
            color: greetingColor,
          ),
          const SizedBox(width: 6),
          Text(
            greeting,
            style: AppTextStyles.bodyMedium.copyWith(
              color: greetingColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// User avatar with popup menu
  Widget _buildUserAvatarMenu({
    required String displayName,
    required bool isGuest,
    required dynamic currentUser,
  }) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: _buildAvatarButton(displayName, isGuest),
      itemBuilder: (context) => _buildMenuItems(isGuest, currentUser),
      onSelected: (value) => _handleMenuSelection(value, isGuest),
    );
  }

  /// Avatar button UI
  Widget _buildAvatarButton(String displayName, bool isGuest) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha:0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar Circle
          CircleAvatar(
            radius: 16,
            backgroundColor: isGuest
                ? AppColors.goldenYellow
                : AppColors.islamicGreen,
            child: Text(
              displayName.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // User Name
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 100),
            child: Text(
              displayName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(width: 4),

          // Dropdown Arrow
          const Icon(
            Icons.arrow_drop_down,
            color: Colors.white,
            size: 20,
          ),
        ],
      ),
    );
  }

  /// Build dropdown menu items
  List<PopupMenuEntry<String>> _buildMenuItems(bool isGuest, dynamic currentUser) {
    if (isGuest) {
      // Guest menu - only sign in option
      return [
        PopupMenuItem<String>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.goldenYellow.withValues(alpha:0.2),
                    child: const Icon(
                      Icons.person_outline,
                      color: AppColors.goldenYellow,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ضيف',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        'غير مسجل',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24),
            ],
          ),
        ),

        const PopupMenuItem<String>(
          value: 'signin',
          child: Row(
            children: [
              Icon(Icons.login, size: 20),
              SizedBox(width: 12),
              Text('تسجيل الدخول'),
            ],
          ),
        ),
      ];
    } else {
      // Authenticated user menu
      return [
        PopupMenuItem<String>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.islamicGreen.withValues(alpha:0.2),
                    child: Text(
                      currentUser?.name?.substring(0, 1).toUpperCase() ?? 'A',
                      style: const TextStyle(
                        color: AppColors.islamicGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentUser?.name ?? 'مستخدم',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          currentUser?.email ?? '',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
            ],
          ),
        ),

        const PopupMenuItem<String>(
          value: 'profile',
          child: Row(
            children: [
              Icon(Icons.person, size: 20),
              SizedBox(width: 12),
              Text('الملف الشخصي'),
            ],
          ),
        ),

        const PopupMenuItem<String>(
          value: 'settings',
          child: Row(
            children: [
              Icon(Icons.settings, size: 20),
              SizedBox(width: 12),
              Text('الإعدادات'),
            ],
          ),
        ),

        const PopupMenuDivider(),

        const PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 20, color: AppColors.error),
              SizedBox(width: 12),
              Text('تسجيل الخروج', style: TextStyle(color: AppColors.error)),
            ],
          ),
        ),
      ];
    }
  }

  /// Handle menu item selection
  void _handleMenuSelection(String value, bool isGuest) {
    switch (value) {
      case 'signin':
        context.go(AppRoutes.adminLogin);
        break;

      case 'profile':
        context.go(AppRoutes.adminProfile);
        break;

      case 'settings':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الإعدادات - قريباً')),
        );
        break;

      case 'logout':
        _showLogoutDialog();
        break;
    }
  }

  /// Show logout confirmation dialog
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