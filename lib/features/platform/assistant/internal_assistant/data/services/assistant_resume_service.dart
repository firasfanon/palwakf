import '../../../assistant_core/data/models/quick_action_item.dart';
import '../models/assistant_context.dart';

class AssistantResumeService {
  const AssistantResumeService();

  QuickActionItem? buildResumeAction(
    AssistantContext context, {
    required bool isArabic,
  }) {
    final label = context.lastActionLabel?.trim();
    if (label == null || label.isEmpty) return null;

    return QuickActionItem(
      id: 'resume-work',
      label: isArabic ? 'متابعة: $label' : 'Resume: $label',
      route: context.lastRoute,
      message: isArabic
          ? 'تابع من حيث توقفت: $label'
          : 'Resume where I stopped: $label',
    );
  }
}
