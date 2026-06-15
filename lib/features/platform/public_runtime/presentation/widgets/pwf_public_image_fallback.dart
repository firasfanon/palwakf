import 'package:flutter/material.dart';

/// Console-safe image renderer for public runtime surfaces.
///
/// Public pages previously depended on external demo images such as
/// `images.unsplash.com`. When those remote URLs return 404/403, Chrome emits
/// red console errors even though the Flutter errorBuilder can still paint a
/// placeholder. This widget prevents those requests for known unsafe demo hosts
/// and renders a local asset/gradient fallback instead.
class PwfPublicImage extends StatelessWidget {
  const PwfPublicImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.fallbackAsset = _defaultFallbackAsset,
    this.fallbackColor = const Color(0xFF0B2E57),
  });

  static const String _defaultFallbackAsset = 'assets/images/hero_banner.png';

  final String? imageUrl;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final String fallbackAsset;
  final Color fallbackColor;

  @override
  Widget build(BuildContext context) {
    final value = (imageUrl ?? '').trim();
    if (_shouldUseLocalFallback(value)) {
      return _LocalFallbackImage(
        assetPath: fallbackAsset,
        fit: fit,
        alignment: alignment,
        fallbackColor: fallbackColor,
      );
    }

    if (value.startsWith('assets/')) {
      return _LocalFallbackImage(
        assetPath: value,
        fit: fit,
        alignment: alignment,
        fallbackColor: fallbackColor,
      );
    }

    return SizedBox.expand(
      child: Image.network(
        value,
        width: double.infinity,
        height: double.infinity,
        fit: fit,
        alignment: alignment,
        errorBuilder: (_, __, ___) => _LocalFallbackImage(
          assetPath: fallbackAsset,
          fit: fit,
          alignment: alignment,
          fallbackColor: fallbackColor,
        ),
      ),
    );
  }

  static bool _shouldUseLocalFallback(String value) {
    if (value.isEmpty) return true;
    if (value.startsWith('assets/')) return false;

    final uri = Uri.tryParse(value);
    final host = uri?.host.toLowerCase() ?? '';
    if (host.isEmpty) return true;

    // Known public-demo image hosts that generated red Console errors in UAT.
    return host == 'images.unsplash.com' ||
        host.endsWith('.unsplash.com') ||
        host == 'source.unsplash.com' ||
        host == 'via.placeholder.com' ||
        host == 'placeholder.com' ||
        host.endsWith('.placeholder.com');
  }
}

class _LocalFallbackImage extends StatelessWidget {
  const _LocalFallbackImage({
    required this.assetPath,
    required this.fit,
    required this.alignment,
    required this.fallbackColor,
  });

  final String assetPath;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final Color fallbackColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Image.asset(
        assetPath,
        width: double.infinity,
        height: double.infinity,
        fit: fit,
        alignment: alignment,
        errorBuilder: (_, __, ___) => DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                fallbackColor,
                fallbackColor.withValues(alpha: 0.82),
                const Color(0xFF0A1E3A),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
