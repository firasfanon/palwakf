import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:waqf/app/routing/app_routes.dart';
import 'package:waqf/app/routing/unit_routes.dart';

/// Single entry point for "Chat" from the public website.
///
/// - If the visitor is not signed in -> open the public chatbot (/home/chat).
/// - If the visitor is signed in -> open the internal assistant (/admin/assistant).
///
/// This keeps the UX consistent across header buttons, cards, and quick actions.
class ChatEntryService {
  static bool get isSignedIn =>
      Supabase.instance.client.auth.currentUser != null;

  /// Header label: guest -> "اسألنا", signed-in staff -> "المساعد".
  static String get headerLabel => isSignedIn ? 'المساعد' : 'اسألنا';

  static void open(BuildContext context) {
    if (isSignedIn) {
      context.go(AppRoutes.adminAssistant);
      return;
    }
    context.go(UnitRoutes.chat('home'));
  }
}
