import 'package:flutter/material.dart';

import '../../l10n/pwf_complaints_strings.dart';
import '../pwf_section_card.dart';

class PwfComplaintsFaqTab extends StatelessWidget {
  const PwfComplaintsFaqTab({super.key});

  @override
  Widget build(BuildContext context) {
    final s = PwfComplaintsStrings.of(context);

    final faqs = <MapEntry<String, String>>[
      const MapEntry('complaints.faq.q1', 'complaints.faq.a1'),
      const MapEntry('complaints.faq.q2', 'complaints.faq.a2'),
      const MapEntry('complaints.faq.q3', 'complaints.faq.a3'),
      const MapEntry('complaints.faq.q4', 'complaints.faq.a4'),
    ];

    return SingleChildScrollView(
      child: PwfSectionCard(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.help_outline_rounded,
                  color: Color(0xFF0D3C61),
                ),
                const SizedBox(width: 8),
                Text(
                  s.t('complaints.tab.faq'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0D3C61),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            for (final item in faqs)
              _FaqItem(question: s.t(item.key), answer: s.t(item.value)),
          ],
        ),
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.question_mark_rounded, color: Color(0xFFC19A50)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0D3C61),
                  ),
                ),
                const SizedBox(height: 8),
                Text(answer, style: const TextStyle(color: Color(0xFF666666))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
