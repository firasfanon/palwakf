import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'go_router_config.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouterConfig.build(ref);
});
