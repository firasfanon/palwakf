import 'package:flutter/material.dart';

class PwfPublicSafeError {
  const PwfPublicSafeError._();

  static String messageFor(Object? error) {
    if (error == null) return 'حدث خطأ غير معروف.';
    final message = error.toString().trim();
    if (message.isEmpty || message == 'null') return 'حدث خطأ غير معروف.';
    if (message.length > 200) return '${message.substring(0, 200)}…';
    return message;
  }
}

class PwfPublicSafeErrorPanel extends StatelessWidget {
  final String title;
  final Object? error;
  final VoidCallback? onRetry;

  const PwfPublicSafeErrorPanel({
    super.key,
    required this.title,
    this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
