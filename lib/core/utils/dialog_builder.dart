import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Utility class for building common dialogs
/// Eliminates duplicated dialog code across the application
/// Follows DRY principle
class DialogBuilder {
  /// Show a confirmation dialog
  /// Returns true if confirmed, false if cancelled
  static Future<bool> showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'تأكيد',
    String cancelText = 'إلغاء',
    Color? confirmColor,
    IconData? icon,
    bool isDanger = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: isDanger ? AppConstants.error : AppConstants.islamicGreen,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDanger
                  ? AppConstants.error
                  : confirmColor ?? AppConstants.islamicGreen,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Show a delete confirmation dialog
  static Future<bool> showDeleteConfirmation({
    required BuildContext context,
    required String itemName,
    String? message,
  }) async {
    return await showConfirmationDialog(
      context: context,
      title: 'تأكيد الحذف',
      message: message ?? 'هل أنت متأكد من حذف "$itemName"؟\nلا يمكن التراجع عن هذا الإجراء.',
      confirmText: 'حذف',
      cancelText: 'إلغاء',
      icon: Icons.delete_forever,
      isDanger: true,
    );
  }

  /// Show an information dialog
  static Future<void> showInfoDialog({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'موافق',
    IconData? icon,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: AppConstants.info),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.islamicGreen,
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  /// Show a success dialog
  static Future<void> showSuccessDialog({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'موافق',
    VoidCallback? onClose,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: AppConstants.success),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onClose?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.success,
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  /// Show an error dialog
  static Future<void> showErrorDialog({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'موافق',
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error, color: AppConstants.error),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.error,
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  /// Show a warning dialog
  static Future<void> showWarningDialog({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'فهمت',
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning, color: AppConstants.warning),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.warning,
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  /// Show a loading dialog
  static void showLoadingDialog({
    required BuildContext context,
    String? message,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Expanded(
                child: Text(message ?? 'جاري التحميل...'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show a custom dialog with form content
  static Future<T?> showFormDialog<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    String confirmText = 'حفظ',
    String cancelText = 'إلغاء',
    required Future<T?> Function() onConfirm,
    IconData? icon,
  }) async {
    return await showDialog<T>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: AppConstants.islamicGreen),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: content,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () async {
              final result = await onConfirm();
              if (context.mounted) {
                Navigator.pop(context, result);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.islamicGreen,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// Show an action dialog with custom actions
  static Future<T?> showActionDialog<T>({
    required BuildContext context,
    required String title,
    required String message,
    required List<DialogAction<T>> actions,
    IconData? icon,
  }) async {
    return await showDialog<T>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: AppConstants.islamicGreen),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(message),
        actions: actions
            .map((action) => action.isPrimary
                ? ElevatedButton(
                    onPressed: () => Navigator.pop(context, action.value),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: action.color ?? AppConstants.islamicGreen,
                    ),
                    child: Text(action.label),
                  )
                : TextButton(
                    onPressed: () => Navigator.pop(context, action.value),
                    child: Text(action.label),
                  ))
            .toList(),
      ),
    );
  }

  /// Show a bottom sheet dialog
  static Future<T?> showBottomSheetDialog<T>({
    required BuildContext context,
    required Widget content,
    String? title,
    double? height,
    bool isDismissible = true,
  }) async {
    return await showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusL),
        ),
      ),
      builder: (context) => Container(
        height: height,
        padding: const EdgeInsets.all(AppConstants.paddingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null) ...[
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppConstants.paddingM),
              const Divider(),
              const SizedBox(height: AppConstants.paddingM),
            ],
            Expanded(child: content),
          ],
        ),
      ),
    );
  }
}

/// Dialog action model
class DialogAction<T> {
  final String label;
  final T value;
  final bool isPrimary;
  final Color? color;

  const DialogAction({
    required this.label,
    required this.value,
    this.isPrimary = false,
    this.color,
  });
}
