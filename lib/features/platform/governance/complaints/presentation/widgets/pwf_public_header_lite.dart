import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PwfPublicHeaderLite extends StatelessWidget {
  final String unitSlug;
  final String title;
  final String homeLabel;

  const PwfPublicHeaderLite({
    super.key,
    required this.unitSlug,
    required this.title,
    required this.homeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      color: Colors.white,
      shadowColor: const Color(0x22000000),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // Brand
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF0D3C61),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.note_alt_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0D3C61),
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () {
                final slug = unitSlug.trim().isEmpty ? 'home' : unitSlug.trim();
                context.go('/$slug');
              },
              icon: const Icon(Icons.home_rounded, size: 18),
              label: Text(homeLabel),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF0D3C61),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
