import 'package:flutter/material.dart';

class ForbiddenScreen extends StatelessWidget {
  const ForbiddenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 56),
              const SizedBox(height: 12),
              const Text(
                'لا تملك صلاحية للوصول إلى هذه الصفحة',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'إذا كنت ترى أن هذا خطأ، تواصل مع إدارة المنصة.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black.withValues(alpha: 140)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
