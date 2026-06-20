import 'dart:async';

import 'package:flutter/foundation.dart';

/// A simple Listenable that triggers GoRouter refresh on stream events.
///
/// [onEvent] lets the authority layer discard a session-bound cache before
/// route guards make their next decision.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(
    Stream<dynamic> stream, {
    VoidCallback? onEvent,
  }) {
    _subscription = stream.asBroadcastStream().listen((_) {
      onEvent?.call();
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
