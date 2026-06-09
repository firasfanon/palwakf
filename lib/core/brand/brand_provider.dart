import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../enums/enums.dart';
import 'brand_registry.dart';
import 'brand_spec.dart';

/// Active brand used for theming and accents.
final brandProvider = Provider<BrandSpec>((ref) {
  return BrandRegistry.platform;
});

/// Utility provider to obtain a system brand.
final systemBrandProvider = Provider.family<BrandSpec, SystemKey>((ref, key) {
  return BrandRegistry.of(key);
});
