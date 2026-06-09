import 'package:flutter/material.dart';

import '../../domain/enums/task_status_enum.dart';

class TaskStatusChip extends StatelessWidget {
  final TasksTaskStatus status;

  const TaskStatusChip({super.key, required this.status});

  Color _color() {
    switch (status) {
      case TasksTaskStatus.completed:
      case TasksTaskStatus.closed:
        return Colors.green;
      case TasksTaskStatus.inProgress:
      case TasksTaskStatus.assigned:
        return Colors.blue;
      case TasksTaskStatus.overdue:
      case TasksTaskStatus.cancelled:
      case TasksTaskStatus.blocked:
        return Colors.red;
      case TasksTaskStatus.waitingExternal:
      case TasksTaskStatus.waitingInternal:
      case TasksTaskStatus.needsReview:
      case TasksTaskStatus.returned:
      case TasksTaskStatus.reopened:
        return Colors.orange;
      case TasksTaskStatus.newTask:
        return Colors.grey;
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
        status.labelAr,
        style: TextStyle(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}
