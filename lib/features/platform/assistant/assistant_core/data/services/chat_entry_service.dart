import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:waqf/app/routing/app_routes.dart';
import 'package:waqf/app/routing/unit_routes.dart';
import 'chat_route_context_service.dart';

class ChatEntryService {
  const ChatEntryService._();

  static bool get isSignedIn =>
      Supabase.instance.client.auth.currentUser != null;

  static String headerLabel(BuildContext context) =>
      isSignedIn ? 'المساعد' : 'اسألنا';

  static void open(BuildContext context, {String fallbackUnitSlug = 'home'}) {
    final state = GoRouterState.of(context);
    final routeContext = ChatRouteContextService.resolve(
      state.uri.toString(),
      fallbackUnitSlug: fallbackUnitSlug,
    );

    if (isSignedIn) {
      final uri = Uri(
        path: AppRoutes.adminAssistant,
        queryParameters: <String, String>{
          'from': routeContext.route,
          'system': routeContext.systemKey,
          'unit': routeContext.unitSlug,
          'pageAr': routeContext.pageLabelAr,
          'pageEn': routeContext.pageLabelEn,
        },
      );
      context.go(uri.toString());
      return;
    }

    final slug = routeContext.unitSlug.trim().isEmpty
        ? fallbackUnitSlug
        : routeContext.unitSlug;
    context.go(UnitRoutes.chat(slug));
  }
}
