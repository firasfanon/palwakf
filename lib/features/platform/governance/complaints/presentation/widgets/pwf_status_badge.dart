import 'package:flutter/material.dart';

import '../../data/models/pwf_complaint.dart';
import '../l10n/pwf_complaints_strings.dart';

class PwfStatusBadge extends StatelessWidget {
  final PwfComplaintStatus status;
  const PwfStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final s = PwfComplaintsStrings.of(context);

    Color bg;
    Color fg;

    switch (status) {
      case PwfComplaintStatus.pending:
        bg = const Color(0xFFFFC107).withValues(alpha: 35);
        fg = const Color(0xFFB8860B);
        break;
      case PwfComplaintStatus.processing:
        bg = const Color(0xFF007BFF).withValues(alpha: 30);
        fg = const Color(0xFF0D3C61);
        break;
      case PwfComplaintStatus.resolved:
        bg = const Color(0xFF2A6E3F).withValues(alpha: 30);
        fg = const Color(0xFF2A6E3F);
        break;
      case PwfComplaintStatus.rejected:
        bg = const Color(0xFFB22222).withValues(alpha: 28);
        fg = const Color(0xFFB22222);
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Text(
        s.t('complaints.status.${status.name}'),
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: fg),
      ),
    );
  }
}
