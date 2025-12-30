import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.islamicGreen,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: AppTextStyles.labelSmall.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.labelSmall,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article_outlined),
            activeIcon: Icon(Icons.article),
            label: 'الأخبار',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.miscellaneous_services_outlined),
            activeIcon: Icon(Icons.miscellaneous_services),
            label: 'الخدمات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mosque_outlined),
            activeIcon: Icon(Icons.mosque),
            label: 'المساجد',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            activeIcon: Icon(Icons.info),
            label: 'عن الوزارة',
          ),
        ],
      ),
    );
  }
}

// Floating Action Button for quick actions
class QuickActionFAB extends StatelessWidget {
  const QuickActionFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showQuickActions(context),
      backgroundColor: AppColors.islamicGreen,
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusL),
        ),
      ),
      builder: (context) => const QuickActionsBottomSheet(),
    );
  }
}

class QuickActionsBottomSheet extends StatelessWidget {
  const QuickActionsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingL),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'إجراءات سريعة',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 24),

          // Quick action buttons grid
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildQuickActionItem(
                icon: Icons.search,
                label: 'بحث',
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to search
                },
              ),
              _buildQuickActionItem(
                icon: Icons.phone,
                label: 'اتصل بنا',
                onTap: () {
                  Navigator.pop(context);
                  // Make phone call
                },
              ),
              _buildQuickActionItem(
                icon: Icons.location_on,
                label: 'المواقع',
                onTap: () {
                  Navigator.pop(context);
                  // Show locations
                },
              ),
              _buildQuickActionItem(
                icon: Icons.schedule,
                label: 'أوقات الصلاة',
                onTap: () {
                  Navigator.pop(context);
                  // Show prayer times
                },
              ),
              _buildQuickActionItem(
                icon: Icons.event,
                label: 'الفعاليات',
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to activities
                },
              ),
              _buildQuickActionItem(
                icon: Icons.share,
                label: 'مشاركة',
                onTap: () {
                  Navigator.pop(context);
                  // Share app
                },
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.islamicGreen.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            child: Icon(
              icon,
              color: AppColors.islamicGreen,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}