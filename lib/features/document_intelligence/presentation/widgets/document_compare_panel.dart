import 'package:flutter/material.dart';

class DocumentComparePanel extends StatelessWidget {
  const DocumentComparePanel({
    super.key,
    required this.originalLabel,
    required this.processedLabel,
  });

  final String originalLabel;
  final String processedLabel;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cards = <Widget>[
          Expanded(
            child: _CompareCard(title: 'الملف الأصلي', body: originalLabel),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _CompareCard(title: 'الناتج المعالج', body: processedLabel),
          ),
        ];

        if (constraints.maxWidth < 720) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CompareCard(title: 'الملف الأصلي', body: originalLabel),
              const SizedBox(height: 12),
              _CompareCard(title: 'الناتج المعالج', body: processedLabel),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: cards,
        );
      },
    );
  }
}

class _CompareCard extends StatelessWidget {
  const _CompareCard({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SelectableText(body),
          ],
        ),
      ),
    );
  }
}
