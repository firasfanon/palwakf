// lib/presentation/widgets/web/web_app_bar.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../app/routing/app_routes.dart';
import '../../providers/auth_provider.dart';

/// Web-only AppBar with dropdowns matching the ministry website design
class WebAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const WebAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Row(
          children: [
            _buildLogo(context),
            const SizedBox(width: 60),
            Expanded(child: _buildNavigation(context)),
            const SizedBox(width: 10),
            _buildLanguageSelector(context),
            const SizedBox(width: 10),
            _buildSearchButton(context),
            const SizedBox(width: 10),
            if (isAuthenticated && currentUser != null)
              _buildUserMenu(context, ref, currentUser)
            else
              _buildLoginButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return InkWell(
      onTap: () => context.go(AppRoutes.root),
      child: Row(
        children: [
          Image.asset(AppConstants.appLogo, height: 60, width: 60),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'وزارة الأوقاف و الشؤون الدينية',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppConstants.islamicGreen,
                ),
              ),
              Text(
                'Palestinian Ministry of Endowments',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppConstants.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavigation(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildNavButton(context, 'الرئيسية', AppRoutes.home),
        const SizedBox(width: 8),
        _buildNavDropdown(context, 'الوزارة', [
          NavMenuItem('كلمة الوزير', AppRoutes.minister),
          NavMenuItem('الرؤية والرسالة', AppRoutes.visionMission),
          NavMenuItem('الهيكل التنظيمي', AppRoutes.structure),
          NavMenuItem('وزراء سابقون', AppRoutes.formerMinisters),
        ]),
        const SizedBox(width: 8),
        _buildNavDropdown(context, 'الإعلام', [
          NavMenuItem('المركز الإعلامي', AppRoutes.mediaCenter),
          NavMenuItem('الأخبار', AppRoutes.news),
          NavMenuItem('الإعلانات', AppRoutes.announcements),
          NavMenuItem('الأنشطة', AppRoutes.activities),
          NavMenuItem('الفعاليات', AppRoutes.mediaCenter),
          NavMenuItem('الاجتماعيات', AppRoutes.socialServices),
          NavMenuItem('خُطب الجمعة', AppRoutes.fridaySermon),
          NavMenuItem('مرصد حماية المقدسات', AppRoutes.sanctitiesObservatory),
        ]),
        const SizedBox(width: 8),
        _buildNavDropdown(context, 'الخدمات', [
          NavMenuItem('دليل الخدمات', AppRoutes.services),
          NavMenuItem('الخدمات الإلكترونية', AppRoutes.eservices),
          NavMenuItem('الشكاوى والملاحظات', AppRoutes.complaints),
          NavMenuItem(
            'الأنظمة والقوانين والتعليمات',
            AppRoutes.legalReferences,
          ),
          NavMenuItem('المساجد', AppRoutes.mosques),
        ]),
        const SizedBox(width: 8),
        _buildNavDropdown(context, 'الأنظمة', [
          NavMenuItem(
            'مستكشف الوقف',
            '${AppRoutes.switchSystemBase}/mustakshif',
          ),
          NavMenuItem('نظام القضايا', '${AppRoutes.switchSystemBase}/cases'),
          NavMenuItem('نظام الأراضي', '${AppRoutes.switchSystemBase}/lands'),
          NavMenuItem(
            'البيانات الإدارية',
            '${AppRoutes.switchSystemBase}/admin-data',
          ),
        ]),
        const SizedBox(width: 8),
        _buildNavButton(context, 'للتواصل', AppRoutes.contact),
      ],
    );
  }

  Widget _buildNavButton(BuildContext context, String label, String route) {
    final isActive = _isCurrentRoute(context, route);

    return TextButton(
      onPressed: () => context.go(route),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        foregroundColor: isActive
            ? AppConstants.islamicGreen
            : AppConstants.textPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavDropdown(
    BuildContext context,
    String label,
    List<NavMenuItem> items,
  ) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      elevation: 8,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppConstants.textPrimary,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                size: 20,
                color: Colors.grey[600],
              ),
            ],
          ),
        ),
      ),
      itemBuilder: (context) => items
          .map(
            (item) => PopupMenuItem<String>(
              value: item.route,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Text(
                    item.label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
      onSelected: (route) => context.go(route),
    );
  }

  Widget _buildSearchButton(BuildContext context) {
    final isSearchActive = _isCurrentRoute(context, AppRoutes.search);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(
          Icons.search,
          color: isSearchActive ? AppConstants.islamicGreen : Colors.grey[600],
        ),
        onPressed: () => context.go(AppRoutes.search),
        tooltip: 'البحث في الموقع',
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.language, size: 24, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Icon(Icons.arrow_drop_down, size: 18, color: Colors.grey[600]),
          ],
        ),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'ar',
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Text('🇵🇸', style: TextStyle(fontSize: 20)),
              SizedBox(width: 12),
              Text('العربية', style: TextStyle(fontSize: 15)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'en',
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Text('🇬🇧', style: TextStyle(fontSize: 20)),
              SizedBox(width: 12),
              Text('English', style: TextStyle(fontSize: 15)),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        // TODO: Implement language change
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('تم تغيير اللغة إلى: $value')));
      },
    );
  }

  Widget _buildUserMenu(BuildContext context, WidgetRef ref, dynamic user) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 60),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(4, 8, 8, 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: AppConstants.islamicGreen,
              child: Text(
                user.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            /*
            Text(
              user.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),

            */

            // const SizedBox(width: 8),
            Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey[600]),
          ],
        ),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'dashboard',
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.dashboard, size: 20),
              SizedBox(width: 12),
              Text('لوحة التحكم'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'profile',
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.settings, size: 20),
              SizedBox(width: 12),
              Text('الإعدادات'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'logout',
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.logout, size: 20, color: AppConstants.error),
              SizedBox(width: 12),
              Text('تسجيل الخروج', style: TextStyle(color: AppConstants.error)),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        switch (value) {
          case 'dashboard':
            context.go(AppRoutes.adminDashboard);
            break;
          case 'profile':
            context.go(AppRoutes.adminProfile);
            break;
          case 'settings':
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('الإعدادات')));
            break;
          case 'logout':
            Future.microtask(() async {
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) context.go(AppRoutes.root);
            });
            break;
        }
      },
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    final isLoginActive = _isCurrentRoute(context, AppRoutes.adminLogin);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(
          Icons.login,
          color: isLoginActive
              ? AppConstants.islamicGreen
              : AppConstants.textPrimary,
        ),
        onPressed: () => context.go(AppRoutes.adminLogin),
        tooltip: 'تسجيل الدخول',
      ),
    );
  }

  bool _isCurrentRoute(BuildContext context, String route) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    return currentRoute == route;
  }
}

class NavMenuItem {
  final String label;
  final String route;

  NavMenuItem(this.label, this.route);
}
