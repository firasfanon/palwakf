/// Minimal presentation-safe actor context.
///
/// The platform can later hydrate this from currentUserProvider,
/// accessProfileProvider, access cache, and route unitSlug. The object is kept
/// payload-minimal and suitable for UAT evidence strips.
class PwfActorContext {
  const PwfActorContext({
    this.userId,
    this.email,
    this.roleLabel,
    this.unitLabel,
    this.routeScope,
    this.reasonCode,
    this.fromPath,
  });

  final String? userId;
  final String? email;
  final String? roleLabel;
  final String? unitLabel;
  final String? routeScope;
  final String? reasonCode;
  final String? fromPath;
}
