import 'package:flutter/material.dart';

class PwfAdminOperationalContextBar extends StatelessWidget {
  final String location;
  final bool compact;

  const PwfAdminOperationalContextBar({
    super.key,
    required this.location,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
