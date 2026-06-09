import 'package:flutter/material.dart';

import '../../data/models/document_intelligence_models.dart';

class DocumentModeSelector extends StatelessWidget {
  const DocumentModeSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final DocumentJobMode value;
  final ValueChanged<DocumentJobMode?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<DocumentJobMode>(
      initialValue: value,
      decoration: const InputDecoration(
        labelText: 'نمط المعالجة',
        border: OutlineInputBorder(),
      ),
      items: DocumentJobMode.values
          .map(
            (mode) => DropdownMenuItem<DocumentJobMode>(
              value: mode,
              child: Text(mode.labelAr),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}
