import 'pwf_access_reason.dart';

/// Small immutable decision object used by platform route guards and systems.
class PwfAccessDecision {
  const PwfAccessDecision.allow({this.reason = PwfAccessReason.unknown})
      : allowed = true;

  const PwfAccessDecision.deny(this.reason) : allowed = false;

  final bool allowed;
  final PwfAccessReason reason;
}
