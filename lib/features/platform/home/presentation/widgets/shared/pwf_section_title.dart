import 'package:flutter/material.dart';
import '../../theme/pwf_home_palette.dart';
import 'pwf_home_visual_contract.dart';

/// Unified title block for all homepage sections.
///
/// The typography, divider, spacing, and optional label belong to the sovereign
/// homepage visual contract so sections do not invent their own header chrome.
class PwfSectionTitle extends StatelessWidget {
  const PwfSectionTitle({
    super.key,
    required this.title,
    required this.subtitle,
    this.eyebrow,
    this.icon,
  });

  final String title;
  final String subtitle;
  final String? eyebrow;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final label = (eyebrow ?? '').trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (label.isNotEmpty) ...[
          PwfVisualChip(
            label: label,
            icon: icon,
            color: PwfHomePalette.primary,
          ),
          const SizedBox(height: 12),
        ],
        Text(
          title,
          textAlign: TextAlign.center,
          style: PwfHomeVisualContract.sectionTitleStyle(context),
        ),
        const SizedBox(height: 12),
        Container(
          width: 88,
          height: 4,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [PwfHomePalette.secondary, PwfHomePalette.royalRed],
            ),
            borderRadius: BorderRadius.all(Radius.circular(2)),
          ),
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: PwfHomeVisualContract.sectionSubtitleStyle(context),
          ),
        ),
      ],
    );
  }
}
