import 'package:flutter/foundation.dart';

@immutable
class PwfVisualIdentityAdminBridge {
  const PwfVisualIdentityAdminBridge({
    required this.scope,
    required this.context,
    required this.overrides,
    required this.version,
  });

  final PwfVisualIdentityScope scope;
  final PwfVisualIdentityPreviewContext context;
  final Map<String, Object?> overrides;
  final String version;

  bool get hasOverrides => overrides.isNotEmpty;
}

enum PwfVisualIdentityScope { platform, unit, system, pageContext }

enum PwfVisualIdentityPreviewContext {
  platformHome,
  unitPages,
  systemPages,
  adminInternal,
  publicService,
  restricted,
  maintenance,
}
