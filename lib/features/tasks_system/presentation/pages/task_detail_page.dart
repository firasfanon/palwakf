import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routing/app_routes.dart';
import '../../../../core/access/access_provider.dart';
import '../../../../core/enums/enums.dart';
import '../../application/task_detail_notifier.dart';
import '../../domain/enums/task_status_enum.dart';
import '../../domain/enums/task_type_enum.dart';
import '../widgets/task_priority_chip.dart';
import '../widgets/task_reference_summary_card.dart';
import '../widgets/task_status_chip.dart';

class TaskDetailPage extends ConsumerWidget {
  final String taskId;
  final bool adminScope;

  const TaskDetailPage({
    super.key,
    required this.taskId,
    this.adminScope = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(taskDetailProvider(taskId));
    final notifier = ref.read(taskDetailProvider(taskId).notifier);
    final profile = ref.watch(accessProfileProvider).valueOrNull;
    final canWriteTasks = profile?.canWriteSystem(SystemKey.tasks) ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل المتابعة'),
        actions: [
          IconButton(
            onPressed: notifier.load,
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث',
          ),
          if (canWriteTasks)
            FilledButton.icon(
              onPressed: () => context.push(
                adminScope
                    ? AppRoutes.adminTaskEdit(taskId)
                    : AppRoutes.taskEdit(taskId),
              ),
              icon: const Icon(Icons.edit),
              label: const Text('تعديل'),
            ),
          TextButton.icon(
            onPressed: notifier.watchCurrentTask,
            icon: const Icon(Icons.visibility_outlined),
            label: const Text('مراقبة'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.task == null
          ? const Center(child: Text('تعذر العثور على المتابعة المطلوبة'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.task!.title,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if ((state.task!.description ?? '').isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(state.task!.description!),
                        ],
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            TaskStatusChip(status: state.task!.status),
                            TaskPriorityChip(priority: state.task!.priority),
                            Chip(label: Text(state.task!.taskType.labelAr)),
                            if (state.task!.dueAt != null)
                              Chip(
                                label: Text(
                                  'الاستحقاق: ${state.task!.dueAt!.toLocal().toString().split(' ').first}',
                                ),
                              ),
                            if (state.task!.unitId != null)
                              Chip(
                                label: Text('unit_id: ${state.task!.unitId}'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'الروابط المرجعية',
                  child: state.links.isEmpty
                      ? const Text('لا توجد روابط مرجعية')
                      : Column(
                          children: state.links
                              .map(
                                (link) => TaskReferenceSummaryCard(link: link),
                              )
                              .toList(),
                        ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'الإسنادات',
                  child: state.assignments.isEmpty
                      ? const Text('لا توجد إسنادات مسجلة حتى الآن')
                      : Column(
                          children: state.assignments
                              .map(
                                (assignment) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(
                                    Icons.assignment_ind_outlined,
                                  ),
                                  title: Text(
                                    assignment.assignedToRole ??
                                        assignment.assignedToUserId ??
                                        'إسناد',
                                  ),
                                  subtitle: Text(
                                    [
                                      if ((assignment.assignedToUserId ?? '')
                                          .isNotEmpty)
                                        'المستخدم: ${assignment.assignedToUserId}',
                                      if (assignment.assignedAt != null)
                                        assignment.assignedAt!
                                            .toLocal()
                                            .toString()
                                            .split('.')
                                            .first,
                                      assignment.isActive ? 'نشط' : 'منتهي',
                                    ].join(' • '),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'المراقبون',
                  child: state.watchers.isEmpty
                      ? const Text('لا يوجد مراقبون للمهمة بعد')
                      : Column(
                          children: state.watchers
                              .map(
                                (watcher) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(
                                    Icons.remove_red_eye_outlined,
                                  ),
                                  title: Text(watcher.userId),
                                  subtitle: Text(
                                    '${watcher.watchType} • ${watcher.createdAt?.toLocal().toString().split('.').first ?? ''}',
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                ),
                const SizedBox(height: 16),
                if (canWriteTasks) ...[
                  _ActionInputCard(
                    title: 'إضافة تعليق',
                    hint: 'أدخل تعليقًا داخليًا أو تحديثًا سريعًا',
                    actionLabel: 'حفظ التعليق',
                    onSubmit: notifier.addComment,
                  ),
                  const SizedBox(height: 16),
                ],
                _SectionCard(
                  title: 'التعليقات',
                  child: state.comments.isEmpty
                      ? const Text('لا توجد تعليقات حتى الآن')
                      : Column(
                          children: state.comments
                              .map(
                                (comment) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(Icons.comment_outlined),
                                  title: Text(comment.commentText),
                                  subtitle: Text(
                                    '${comment.commentType} • ${comment.createdAt?.toLocal().toString().split('.').first ?? ''}',
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                ),
                const SizedBox(height: 16),
                if (canWriteTasks) ...[
                  _FollowupInputCard(notifier: notifier),
                  const SizedBox(height: 16),
                ],
                _SectionCard(
                  title: 'سجل المتابعة',
                  child: state.followups.isEmpty
                      ? const Text('لا توجد إدخالات متابعة')
                      : Column(
                          children: state.followups
                              .map(
                                (followup) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(Icons.timeline_outlined),
                                  title: Text(followup.followupText),
                                  subtitle: Text(
                                    [
                                      followup.followupDate
                                          .toLocal()
                                          .toString()
                                          .split('.')
                                          .first,
                                      if ((followup.followupResult ?? '')
                                          .isNotEmpty)
                                        'النتيجة: ${followup.followupResult}',
                                      if ((followup.nextAction ?? '')
                                          .isNotEmpty)
                                        'الإجراء القادم: ${followup.nextAction}',
                                    ].join(' • '),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'سجل الحالة',
                  child: state.history.isEmpty
                      ? const Text('لا يوجد سجل حالات بعد')
                      : Column(
                          children: state.history
                              .map(
                                (item) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(Icons.history),
                                  title: Text(
                                    '${item.oldStatus.labelAr} ← ${item.newStatus.labelAr}',
                                  ),
                                  subtitle: Text(
                                    [
                                      if ((item.reason ?? '').isNotEmpty)
                                        item.reason!,
                                      if (item.changedAt != null)
                                        item.changedAt!
                                            .toLocal()
                                            .toString()
                                            .split('.')
                                            .first,
                                    ].join(' • '),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'الأحداث التشغيلية',
                  child: state.events.isEmpty
                      ? const Text('لا توجد أحداث تشغيلية مسجلة')
                      : Column(
                          children: state.events
                              .map(
                                (event) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(Icons.bolt_outlined),
                                  title: Text(event.eventType),
                                  subtitle: Text(
                                    [
                                      if ((event.actionType ?? '').isNotEmpty)
                                        event.actionType!,
                                      if ((event.notes ?? '').isNotEmpty)
                                        event.notes!,
                                      if (event.createdAt != null)
                                        event.createdAt!
                                            .toLocal()
                                            .toString()
                                            .split('.')
                                            .first,
                                    ].join(' • '),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'الإشعارات الداخلية',
                  child: state.notifications.isEmpty
                      ? const Text('لا توجد إشعارات داخلية محفوظة')
                      : Column(
                          children: state.notifications
                              .map(
                                (notification) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Icon(
                                    notification.isRead
                                        ? Icons.mark_email_read_outlined
                                        : Icons.notifications_active_outlined,
                                  ),
                                  title: Text(notification.title),
                                  subtitle: Text(
                                    [
                                      if ((notification.body ?? '').isNotEmpty)
                                        notification.body!,
                                      notification.isRead
                                          ? 'مقروء'
                                          : 'غير مقروء',
                                      if (notification.createdAt != null)
                                        notification.createdAt!
                                            .toLocal()
                                            .toString()
                                            .split('.')
                                            .first,
                                    ].join(' • '),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'المرفقات',
                  child: state.attachments.isEmpty
                      ? const Text('لا توجد مرفقات حتى الآن')
                      : Column(
                          children: state.attachments
                              .map(
                                (attachment) => ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(Icons.attach_file),
                                  title: Text(attachment.fileName),
                                  subtitle: Text(
                                    '${attachment.fileType} • ${attachment.fileUrl}',
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                ),
              ],
            ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _ActionInputCard extends StatefulWidget {
  final String title;
  final String hint;
  final String actionLabel;
  final Future<void> Function(String text) onSubmit;

  const _ActionInputCard({
    required this.title,
    required this.hint,
    required this.actionLabel,
    required this.onSubmit,
  });

  @override
  State<_ActionInputCard> createState() => _ActionInputCardState();
}

class _ActionInputCardState extends State<_ActionInputCard> {
  final _controller = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: widget.hint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: _saving
                    ? null
                    : () async {
                        setState(() => _saving = true);
                        await widget.onSubmit(_controller.text);
                        if (mounted) {
                          _controller.clear();
                          setState(() => _saving = false);
                        }
                      },
                icon: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(widget.actionLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FollowupInputCard extends StatefulWidget {
  final TaskDetailNotifier notifier;

  const _FollowupInputCard({required this.notifier});

  @override
  State<_FollowupInputCard> createState() => _FollowupInputCardState();
}

class _FollowupInputCardState extends State<_FollowupInputCard> {
  final _textController = TextEditingController();
  final _resultController = TextEditingController();
  final _nextActionController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _textController.dispose();
    _resultController.dispose();
    _nextActionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إضافة متابعة',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _textController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'وصف ما تم',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _resultController,
              decoration: const InputDecoration(
                labelText: 'النتيجة',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nextActionController,
              decoration: const InputDecoration(
                labelText: 'الإجراء القادم',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _saving
                  ? null
                  : () async {
                      setState(() => _saving = true);
                      await widget.notifier.addFollowup(
                        text: _textController.text,
                        result: _resultController.text,
                        nextAction: _nextActionController.text,
                      );
                      if (mounted) {
                        _textController.clear();
                        _resultController.clear();
                        _nextActionController.clear();
                        setState(() => _saving = false);
                      }
                    },
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_task),
              label: const Text('حفظ المتابعة'),
            ),
          ],
        ),
      ),
    );
  }
}
