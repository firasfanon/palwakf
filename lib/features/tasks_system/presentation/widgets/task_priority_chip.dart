import 'package:flutter/material.dart';

import '../../domain/enums/task_priority_enum.dart';

class TaskPriorityChip extends StatelessWidget {
  final TasksTaskPriority priority;

  const TaskPriorityChip({super.key, required this.priority});

  Color _color() {
    switch (priority) {
      case TasksTaskPriority.low:
        return Colors.green;
      case TasksTaskPriority.medium:
        return Colors.blueGrey;
      case TasksTaskPriority.high:
        return Colors.orange;
      case TasksTaskPriority.urgent:
        return Colors.deepOrange;
      case TasksTaskPriority.critical:
        return const Color(0xFFB22222);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        priority.labelAr,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}
