import 'package:flutter/material.dart';

import '../../domain/enums/task_link_type_enum.dart';
import '../../domain/models/task_reference_link.dart';

class TaskReferenceSummaryCard extends StatelessWidget {
  final TaskReferenceLink link;

  const TaskReferenceSummaryCard({super.key, required this.link});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(link.linkType.labelAr.substring(0, 1)),
        ),
        title: Text(
          link.displayLabel?.isNotEmpty == true
              ? link.displayLabel!
              : link.referenceId,
        ),
        subtitle: Text('${link.linkType.labelAr} • ${link.referenceSystem}'),
        trailing: link.isPrimary
            ? const Icon(Icons.star, color: Colors.amber)
            : null,
      ),
    );
  }
}
