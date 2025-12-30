import 'package:flutter/material.dart';
import 'package:waqf/core/constants/app_constants.dart';

class PageHeader extends StatelessWidget {
  final String previewMode;
  final bool hasUnsavedChanges;
  final ValueChanged<String> onPreviewModeChanged;
  final VoidCallback onSave;
  final VoidCallback onPreview;

  const PageHeader({
    super.key,
    required this.previewMode,
    required this.hasUnsavedChanges,
    required this.onPreviewModeChanged,
    required this.onSave,
    required this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إدارة الموقع المتقدمة',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppConstants.islamicGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'إدارة شاملة لجميع صفحات وخدمات ومحتويات الموقع',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppConstants.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _PreviewModeButton(
                icon: Icons.desktop_windows,
                mode: 'desktop',
                isActive: previewMode == 'desktop',
                onTap: () => onPreviewModeChanged('desktop'),
              ),
              const SizedBox(width: 8),
              _PreviewModeButton(
                icon: Icons.tablet_mac,
                mode: 'tablet',
                isActive: previewMode == 'tablet',
                onTap: () => onPreviewModeChanged('tablet'),
              ),
              const SizedBox(width: 8),
              _PreviewModeButton(
                icon: Icons.phone_android,
                mode: 'mobile',
                isActive: previewMode == 'mobile',
                onTap: () => onPreviewModeChanged('mobile'),
              ),
            ],
          ),
          const SizedBox(width: 16),
          OutlinedButton.icon(
            onPressed: onPreview,
            icon: const Icon(Icons.visibility),
            label: const Text('معاينة مباشرة'),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: hasUnsavedChanges ? onSave : null,
            icon: const Icon(Icons.save),
            label: const Text('حفظ التغييرات'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.islamicGreen,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewModeButton extends StatelessWidget {
  final IconData icon;
  final String mode;
  final bool isActive;
  final VoidCallback onTap;

  const _PreviewModeButton({
    required this.icon,
    required this.mode,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? AppConstants.islamicGreen : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isActive ? Colors.white : Colors.grey[600],
          size: 20,
        ),
      ),
    );
  }
}