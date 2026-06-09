import 'package:flutter/material.dart';
import 'package:waqf/features/platform/access/presentation/pages/pwf_access_denied_page.dart';

/// Legacy route adapter kept for compatibility.
///
/// The platform-owned implementation is [PwfAccessDeniedPage]. Systems should
/// not create their own Forbidden screens.
class ForbiddenScreen extends StatelessWidget {
  const ForbiddenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PwfAccessDeniedPage();
  }
}
