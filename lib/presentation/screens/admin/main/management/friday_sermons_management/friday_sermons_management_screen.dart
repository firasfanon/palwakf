import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../core/access/access_provider.dart';
import '../../../../../../core/enums/enums.dart';
import '../../../../../providers/friday_sermons_provider.dart';
import '../../../../../../data/models/friday_sermon.dart';

class FridaySermonsManagementScreen extends ConsumerWidget {
  const FridaySermonsManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(accessProfileProvider);
    final sermonsAsync = ref.watch(adminFridaySermonsProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة خُطب الجمعة'),
          actions: [
            IconButton(
              tooltip: 'تحديث',
              onPressed: () {
                ref.invalidate(adminFridaySermonsProvider);
              },
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: profileAsync.when(
            data: (profile) {
              final canManage =
                  (profile?.isSuperuser == true) || (profile?.can(SystemKey.platformAdmin, Permission.manageSite) ?? false);
              if (!canManage) {
                return const Center(
                  child: Text(
                    'غير مصرح لك بإدارة خُطب الجمعة.\nتحتاج صلاحية manageSite على platformAdmin.',
                    textAlign: TextAlign.center,
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await showDialog(
                          context: context,
                          builder: (_) => const _UpsertSermonDialog(),
                        );
                        ref.invalidate(adminFridaySermonsProvider);
                        ref.invalidate(publicFridaySermonsProvider);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('خطبة جديدة'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: sermonsAsync.when(
                      data: (items) {
                        if (items.isEmpty) {
                          return const Center(child: Text('لا توجد بيانات بعد.'));
                        }

                        return SingleChildScrollView(
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('التاريخ')),
                              DataColumn(label: Text('العنوان')),
                              DataColumn(label: Text('الخطيب')),
                              DataColumn(label: Text('منشور')),
                              DataColumn(label: Text('إجراء')),
                            ],
                            rows: items.map((s) {
                              final dateStr = '${s.sermonDate.year.toString().padLeft(4, '0')}-${s.sermonDate.month.toString().padLeft(2, '0')}-${s.sermonDate.day.toString().padLeft(2, '0')}';

                              return DataRow(
                                cells: [
                                  DataCell(Text(dateStr)),
                                  DataCell(Text(s.titleAr, maxLines: 2, overflow: TextOverflow.ellipsis)),
                                  DataCell(Text(s.speakerName ?? '—')),
                                  DataCell(
                                    Switch(
                                      value: s.isPublished,
                                      onChanged: (v) async {
                                        await ref.read(fridaySermonsRepositoryProvider).update(
                                              s.id,
                                              {'is_published': v},
                                            );
                                        ref.invalidate(adminFridaySermonsProvider);
                                        ref.invalidate(publicFridaySermonsProvider);
                                      },
                                    ),
                                  ),
                                  DataCell(
                                    Row(
                                      children: [
                                        IconButton(
                                          tooltip: 'تعديل',
                                          icon: const Icon(Icons.edit),
                                          onPressed: () async {
                                            await showDialog(
                                              context: context,
                                              builder: (_) => _UpsertSermonDialog(existing: s),
                                            );
                                            ref.invalidate(adminFridaySermonsProvider);
                                            ref.invalidate(publicFridaySermonsProvider);
                                          },
                                        ),
                                        IconButton(
                                          tooltip: 'حذف',
                                          icon: const Icon(Icons.delete_outline),
                                          onPressed: () async {
                                            final ok = await showDialog<bool>(
                                              context: context,
                                              builder: (_) => Directionality(
                                                textDirection: TextDirection.rtl,
                                                child: AlertDialog(
                                                  title: const Text('تأكيد الحذف'),
                                                  content: const Text('هل تريد حذف هذه الخطبة؟'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.of(context).pop(false),
                                                      child: const Text('إلغاء'),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () => Navigator.of(context).pop(true),
                                                      child: const Text('حذف'),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );

                                            if (ok == true) {
                                              await ref.read(fridaySermonsRepositoryProvider).delete(s.id);
                                              ref.invalidate(adminFridaySermonsProvider);
                                              ref.invalidate(publicFridaySermonsProvider);
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text(e.toString())),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(e.toString())),
          ),
        ),
      ),
    );
  }
}

class _UpsertSermonDialog extends ConsumerStatefulWidget {
  final FridaySermon? existing;
  const _UpsertSermonDialog({this.existing});

  @override
  ConsumerState<_UpsertSermonDialog> createState() => _UpsertSermonDialogState();
}

class _UpsertSermonDialogState extends ConsumerState<_UpsertSermonDialog> {
  late final TextEditingController _titleAr;
  late final TextEditingController _speaker;
  late final TextEditingController _mosque;
  late final TextEditingController _summary;
  late final TextEditingController _content;
  late final TextEditingController _audioUrl;
  late final TextEditingController _pdfUrl;

  DateTime _date = DateTime.now();
  bool _published = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleAr = TextEditingController(text: e?.titleAr ?? '');
    _speaker = TextEditingController(text: e?.speakerName ?? '');
    _mosque = TextEditingController(text: e?.mosqueName ?? '');
    _summary = TextEditingController(text: e?.summaryAr ?? '');
    _content = TextEditingController(text: e?.contentAr ?? '');
    _audioUrl = TextEditingController(text: e?.audioUrl ?? '');
    _pdfUrl = TextEditingController(text: e?.pdfUrl ?? '');
    _date = e?.sermonDate ?? DateTime.now();
    _published = e?.isPublished ?? true;
  }

  @override
  void dispose() {
    _titleAr.dispose();
    _speaker.dispose();
    _mosque.dispose();
    _summary.dispose();
    _content.dispose();
    _audioUrl.dispose();
    _pdfUrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        title: Text(isEdit ? 'تعديل خطبة' : 'خطبة جديدة'),
        content: SizedBox(
          width: 720,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleAr,
                  decoration: const InputDecoration(labelText: 'العنوان (عربي)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _speaker,
                        decoration: const InputDecoration(labelText: 'الخطيب', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _mosque,
                        decoration: const InputDecoration(labelText: 'المسجد', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _date,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() => _date = picked);
                          }
                        },
                        icon: const Icon(Icons.date_range),
                        label: Text('التاريخ: ${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SwitchListTile(
                        value: _published,
                        onChanged: (v) => setState(() => _published = v),
                        title: const Text('منشور'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _summary,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'ملخص (عربي)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _content,
                  maxLines: 8,
                  decoration: const InputDecoration(labelText: 'نص الخطبة (عربي)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _audioUrl,
                        decoration: const InputDecoration(labelText: 'رابط الصوت (اختياري)', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _pdfUrl,
                        decoration: const InputDecoration(labelText: 'رابط PDF (اختياري)', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final title = _titleAr.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('العنوان مطلوب')));
      return;
    }

    setState(() => _saving = true);
    try {
      final repo = ref.read(fridaySermonsRepositoryProvider);

      if (widget.existing == null) {
        final sermon = FridaySermon(
          id: '',
          titleAr: title,
          sermonDate: _date,
          speakerName: _speaker.text.trim().isEmpty ? null : _speaker.text.trim(),
          mosqueName: _mosque.text.trim().isEmpty ? null : _mosque.text.trim(),
          summaryAr: _summary.text.trim().isEmpty ? null : _summary.text.trim(),
          contentAr: _content.text.trim().isEmpty ? null : _content.text.trim(),
          audioUrl: _audioUrl.text.trim().isEmpty ? null : _audioUrl.text.trim(),
          pdfUrl: _pdfUrl.text.trim().isEmpty ? null : _pdfUrl.text.trim(),
          isPublished: _published,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await repo.create(sermon);
      } else {
        await repo.update(widget.existing!.id, {
          'title_ar': title,
          'sermon_date': _date.toIso8601String().substring(0, 10),
          'speaker_name': _speaker.text.trim().isEmpty ? null : _speaker.text.trim(),
          'mosque_name': _mosque.text.trim().isEmpty ? null : _mosque.text.trim(),
          'summary_ar': _summary.text.trim().isEmpty ? null : _summary.text.trim(),
          'content_ar': _content.text.trim().isEmpty ? null : _content.text.trim(),
          'audio_url': _audioUrl.text.trim().isEmpty ? null : _audioUrl.text.trim(),
          'pdf_url': _pdfUrl.text.trim().isEmpty ? null : _pdfUrl.text.trim(),
          'is_published': _published,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        }..removeWhere((k, v) => v == null));
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
