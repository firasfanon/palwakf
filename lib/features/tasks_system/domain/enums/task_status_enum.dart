enum TasksTaskStatus {
  newTask,
  assigned,
  inProgress,
  waitingExternal,
  waitingInternal,
  needsReview,
  completed,
  closed,
  cancelled,
  overdue,
  returned,
  reopened,
  blocked,
}

extension TasksTaskStatusX on TasksTaskStatus {
  String get dbValue => switch (this) {
    TasksTaskStatus.newTask => 'new',
    TasksTaskStatus.assigned => 'assigned',
    TasksTaskStatus.inProgress => 'in_progress',
    TasksTaskStatus.waitingExternal => 'waiting_external',
    TasksTaskStatus.waitingInternal => 'waiting_internal',
    TasksTaskStatus.needsReview => 'needs_review',
    TasksTaskStatus.completed => 'completed',
    TasksTaskStatus.closed => 'closed',
    TasksTaskStatus.cancelled => 'cancelled',
    TasksTaskStatus.overdue => 'overdue',
    TasksTaskStatus.returned => 'returned',
    TasksTaskStatus.reopened => 'reopened',
    TasksTaskStatus.blocked => 'blocked',
  };

  String get labelAr => switch (this) {
    TasksTaskStatus.newTask => 'جديدة',
    TasksTaskStatus.assigned => 'مسندة',
    TasksTaskStatus.inProgress => 'قيد التنفيذ',
    TasksTaskStatus.waitingExternal => 'بانتظار جهة خارجية',
    TasksTaskStatus.waitingInternal => 'بانتظار جهة داخلية',
    TasksTaskStatus.needsReview => 'تحتاج مراجعة',
    TasksTaskStatus.completed => 'مكتملة',
    TasksTaskStatus.closed => 'مغلقة',
    TasksTaskStatus.cancelled => 'ملغاة',
    TasksTaskStatus.overdue => 'متأخرة',
    TasksTaskStatus.returned => 'معادة',
    TasksTaskStatus.reopened => 'أعيد فتحها',
    TasksTaskStatus.blocked => 'متعطلة',
  };

  static TasksTaskStatus fromDb(dynamic value) {
    switch ('$value') {
      case 'assigned':
        return TasksTaskStatus.assigned;
      case 'in_progress':
        return TasksTaskStatus.inProgress;
      case 'waiting_external':
        return TasksTaskStatus.waitingExternal;
      case 'waiting_internal':
        return TasksTaskStatus.waitingInternal;
      case 'needs_review':
        return TasksTaskStatus.needsReview;
      case 'completed':
        return TasksTaskStatus.completed;
      case 'closed':
        return TasksTaskStatus.closed;
      case 'cancelled':
        return TasksTaskStatus.cancelled;
      case 'overdue':
        return TasksTaskStatus.overdue;
      case 'returned':
        return TasksTaskStatus.returned;
      case 'reopened':
        return TasksTaskStatus.reopened;
      case 'blocked':
        return TasksTaskStatus.blocked;
      default:
        return TasksTaskStatus.newTask;
    }
  }
}
