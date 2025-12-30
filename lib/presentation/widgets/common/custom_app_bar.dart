import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../app/routing/app_routes.dart';
import 'user_profile_widget.dart'; // ← ADD THIS

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.showSearchButton = false,
    this.showNotificationButton = false,
    this.showUserProfile = true, // ← ADD THIS
    this.showGreeting = true, // ← ADD THIS
    this.actions,
    this.backgroundColor,
    this.elevation,
    this.centerTitle = true,
    this.bottom,
    this.leading,
    this.automaticallyImplyLeading = true,
  });

  final String title;
  final bool showBackButton;
  final bool showSearchButton;
  final bool showNotificationButton;
  final bool showUserProfile; // ← ADD THIS
  final bool showGreeting; // ← ADD THIS
  final List<Widget>? actions;
  final Color? backgroundColor;
  final double? elevation;
  final bool centerTitle;
  final PreferredSizeWidget? bottom;
  final Widget? leading;
  final bool automaticallyImplyLeading;

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
      backgroundColor: backgroundColor ?? AppColors.islamicGreen,
      elevation: elevation ?? 2,
      centerTitle: centerTitle,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: leading ?? (showBackButton ? _buildBackButton(context) : null),
      actions: _buildActions(context),
      bottom: bottom,
      iconTheme: const IconThemeData(color: Colors.white),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  Widget? _buildBackButton(BuildContext context) {
    if (!showBackButton) return null;

    return IconButton(
      icon: const Icon(Icons.arrow_back_ios),
      onPressed: () {
        // ✅ Safe back for web + router-based navigation.
        // If there is no back stack, go to /home to avoid blank/red screens.
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(AppRoutes.home);
        }
      },
      tooltip: 'رجوع',
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    final actionsList = <Widget>[];

    // Add search button
    if (showSearchButton) {
      actionsList.add(
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => context.go(AppRoutes.search),
          tooltip: 'بحث',
        ),
      );
    }

    // Add notification button
    if (showNotificationButton) {
      actionsList.add(
        IconButton(
          icon: Stack(
            children: [
              const Icon(Icons.notifications_outlined),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 12,
                    minHeight: 12,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          onPressed: () => _showNotifications(context),
          tooltip: 'الإشعارات',
        ),
      );
    }

    // ✨ ADD USER PROFILE WIDGET
    if (showUserProfile) {
      actionsList.add(
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: UserProfileWidget(
            showGreeting: showGreeting,
          ),
        ),
      );
    }

    // Add custom actions
    if (actions != null) {
      actionsList.addAll(actions!);
    }

    return actionsList;
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusL),
        ),
      ),
      builder: (context) => const NotificationBottomSheet(),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom?.preferredSize.height ?? 0),
  );
}

// Keep NotificationBottomSheet as before...
class NotificationBottomSheet extends StatelessWidget {
  const NotificationBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Text(
            'الإشعارات',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildNotificationItem(
            title: 'إعلان جديد',
            message: 'تم نشر إعلان مهم حول مواعيد صلاة الجمعة',
            time: 'منذ ساعة',
            isRead: false,
          ),
          _buildNotificationItem(
            title: 'خبر جديد',
            message: 'افتتاح مسجد جديد في مدينة رام الله',
            time: 'منذ ساعتين',
            isRead: true,
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('عرض جميع الإشعارات'),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildNotificationItem({
    required String title,
    required String message,
    required String time,
    required bool isRead,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: isRead
            ? Colors.grey[50]
            : AppColors.islamicGreen.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(
          color: isRead
              ? Colors.grey[200]!
              : AppColors.islamicGreen.withValues(alpha:0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.islamicGreen.withValues(alpha:0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications,
              color: AppColors.islamicGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: AppTextStyles.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}