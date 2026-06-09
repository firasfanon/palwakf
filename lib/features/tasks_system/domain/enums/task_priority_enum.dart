enum TasksTaskPriority { low, medium, high, urgent, critical }

extension TasksTaskPriorityX on TasksTaskPriority {
  String get dbValue => switch (this) {
    TasksTaskPriority.low => 'low',
    TasksTaskPriority.medium => 'medium',
    TasksTaskPriority.high => 'high',
    TasksTaskPriority.urgent => 'urgent',
    TasksTaskPriority.critical => 'critical',
  };

  String get labelAr => switch (this) {
    TasksTaskPriority.low => 'منخفضة',
    TasksTaskPriority.medium => 'متوسطة',
    TasksTaskPriority.high => 'عالية',
    TasksTaskPriority.urgent => 'عاجلة',
    TasksTaskPriority.critical => 'حرجة',
  };

  static TasksTaskPriority fromDb(dynamic value) {
    switch ('$value') {
      case 'low':
        return TasksTaskPriority.low;
      case 'high':
        return TasksTaskPriority.high;
      case 'urgent':
        return TasksTaskPriority.urgent;
      case 'critical':
        return TasksTaskPriority.critical;
      default:
        return TasksTaskPriority.medium;
    }
  }
}
