import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/pwf_complaint.dart';

import '../../l10n/pwf_complaints_strings.dart';
import '../../providers/pwf_complaints_providers.dart';
import '../../utils/pwf_datetime_format.dart';
import '../pwf_section_card.dart';
import '../pwf_status_badge.dart';

class PwfComplaintsSuggestionsTab extends ConsumerWidget {
  const PwfComplaintsSuggestionsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = PwfComplaintsStrings.of(context);
    final async = ref.watch(pwfSuggestionsProvider);

    return SingleChildScrollView(
      child: PwfSectionCard(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lightbulb_outline_rounded,
                  color: Color(0xFF0D3C61),
                ),
                const SizedBox(width: 8),
                Text(
                  s.t('complaints.suggestions.title'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0D3C61),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            async.when(
              data: (items) {
                if (items.isEmpty) {
                  return _EmptyState(text: s.t('complaints.suggestions.empty'));
                }
                return Column(
                  children: [
                    for (final c in items) _SuggestionCard(complaint: c),
                  ],
                );
              },
              error: (e, _) => _EmptyState(text: e.toString()),
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String text;
  const _EmptyState({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            size: 42,
            color: Colors.black.withValues(alpha: 50),
          ),
          const SizedBox(height: 10),
          Text(text, style: const TextStyle(color: Color(0xFF666666))),
        ],
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final PwfComplaint complaint;
  const _SuggestionCard({required this.complaint});

  @override
  Widget build(BuildContext context) {
    final c = complaint;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: const Border(
          right: BorderSide(color: Color(0xFF0D3C61), width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PwfStatusBadge(status: c.status),
          const SizedBox(height: 10),
          Text(
            c.subject,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFF0D3C61),
            ),
          ),
          const SizedBox(height: 8),
          Text(c.description, style: const TextStyle(color: Color(0xFF666666))),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _Meta(
                icon: Icons.calendar_month_rounded,
                text: PwfDateTimeFormat.formatShortDate(context, c.createdAt),
              ),
              _Meta(icon: Icons.tag_rounded, text: c.referenceCode),
            ],
          ),
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Meta({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF0D3C61)),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: const Color(0xFF666666).withValues(alpha: 220),
          ),
        ),
      ],
    );
  }
}
