import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:waqf/data/models/announcement.dart';
import 'package:waqf/presentation/providers/supabase_providers.dart';

import '../shared/shared_content_media_upload_helper.dart';
import '../shared/shared_content_publication_fields.dart';
import '../shared/shared_content_save_helper.dart';

class AnnouncementFormDialog extends ConsumerStatefulWidget {
  final String unitId;
  final String unitSlug;
  final Announcement? existing;

  const AnnouncementFormDialog({
    super.key,
    required this.unitId,
    required this.unitSlug,
    this.existing,
  });

  @override
  ConsumerState<AnnouncementFormDialog> createState() =>
      _AnnouncementFormDialogState();
}

class _AnnouncementFormDialogState
    extends ConsumerState<AnnouncementFormDialog> {
  late final TextEditingController _title;
  late final TextEditingController _content;
  late final TextEditingController _targetAudience;
  late final TextEditingController _imageUrl;
  late final TextEditingController _attachmentUrl;

  Priority _priority = Priority.medium;
  bool _isActive = true;
  DateTime? _validUntil;
  DateTime? _publishAt;
  bool _isFeatured = false;
  bool _isPinned = false;
  int _sortOrder = 0;
  SharedContentPublicationMode _publicationMode =
      SharedContentPublicationMode.published;

  bool _saving = false;
  bool _uploadingImage = false;
  bool _uploadingAttachment = false;

  @override
  void initState() {
    super.initState();
    final a = widget.existing;
    _title = TextEditingController(text: a?.title ?? '');
    _content = TextEditingController(text: a?.content ?? '');
    _targetAudience = TextEditingController(
      text: a?.targetAudience ?? 'public',
    );
    _imageUrl = TextEditingController(text: a?.imageUrl ?? '');
    _attachmentUrl = TextEditingController(text: a?.attachmentUrl ?? '');
    if (a != null) {
      _priority = a.priority;
      _isActive = a.isActive;
      _validUntil = a.validUntil;
      _publishAt = a.publishAt;
      _isFeatured = a.isFeatured;
      _isPinned = a.isPinned;
      _sortOrder = a.sortOrder;
      _publicationMode = _deriveMode(a);
    }
  }

  SharedContentPublicationMode _deriveMode(Announcement a) {
    final now = DateTime.now();
    if (a.publishAt != null && a.publishAt!.isAfter(now) && !a.isActive) {
      return SharedContentPublicationMode.scheduled;
    }
    if (a.isActive) return SharedContentPublicationMode.published;
    if (a.validUntil != null && a.validUntil!.isBefore(now)) {
      return SharedContentPublicationMode.archived;
    }
    return SharedContentPublicationMode.draft;
  }

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    _targetAudience.dispose();
    _imageUrl.dispose();
    _attachmentUrl.dispose();
    super.dispose();
  }

  Future<void> _pickValidUntil() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: _validUntil ?? DateTime.now(),
    );
    if (date == null || !mounted) return;
    setState(() {
      _validUntil = DateTime(date.year, date.month, date.day);
    });
  }

  Future<void> _pickPublishAt() async {
    final initial = _publishAt ?? DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: initial,
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (!mounted) return;
    setState(() {
      _publishAt = DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? 0,
        time?.minute ?? 0,
      );
    });
  }

  Future<void> _uploadImage() async {
    setState(() => _uploadingImage = true);
    final url = await SharedContentMediaUploadHelper.pickAndUpload(
      context: context,
      familyKey: 'announcements',
      folder: 'images',
      unitScopeKey: widget.unitSlug,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp'],
    );
    if (!mounted) return;
    if (url != null) setState(() => _imageUrl.text = url);
    setState(() => _uploadingImage = false);
  }

  Future<void> _uploadAttachment() async {
    setState(() => _uploadingAttachment = true);
    final url = await SharedContentMediaUploadHelper.pickAndUpload(
      context: context,
      familyKey: 'announcements',
      folder: 'attachments',
      unitScopeKey: widget.unitSlug,
      allowedExtensions: const [
        'pdf',
        'doc',
        'docx',
        'xls',
        'xlsx',
        'ppt',
        'pptx',
        'zip',
      ],
    );
    if (!mounted) return;
    if (url != null) setState(() => _attachmentUrl.text = url);
    setState(() => _uploadingAttachment = false);
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    final content = _content.text.trim();
    if (title.isEmpty || content.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال العنوان والمحتوى')),
      );
      return;
    }

    if (_publicationMode == SharedContentPublicationMode.scheduled &&
        _publishAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدد موعد النشر قبل حفظ الإعلان المجدول.'),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final supabase = ref.read(supabaseServiceProvider).client;
      final now = DateTime.now();
      _isActive = _publicationMode == SharedContentPublicationMode.published;
      final effectivePublishAt = switch (_publicationMode) {
        SharedContentPublicationMode.published =>
          _publishAt ?? widget.existing?.publishAt ?? now,
        SharedContentPublicationMode.scheduled => _publishAt,
        _ => _publishAt,
      };

      final basePayload = <String, dynamic>{
        'unit_id': widget.unitId,
        'title': title,
        'content': content,
        'priority': _priority.name,
        'valid_until': _validUntil?.toIso8601String(),
        'is_active': _isActive,
        'target_audience': _targetAudience.text.trim().isEmpty
            ? 'public'
            : _targetAudience.text.trim(),
        'updated_at': now.toIso8601String(),
      };
      if (widget.existing == null) {
        basePayload['created_at'] = now.toIso8601String();
      }

      final optionalPayload = <String, dynamic>{
        'image_url': _imageUrl.text.trim().isEmpty
            ? null
            : _imageUrl.text.trim(),
        'attachment_url': _attachmentUrl.text.trim().isEmpty
            ? null
            : _attachmentUrl.text.trim(),
        'is_featured': _isFeatured,
        'is_pinned': _isPinned,
        'publish_at': effectivePublishAt?.toIso8601String(),
        'sort_order': _sortOrder,
      };

      await SharedContentSaveHelper.saveWithOptionalColumns(
        supabase: supabase,
        table: 'announcements',
        basePayload: basePayload,
        optionalPayload: optionalPayload,
        existingId: widget.existing?.id,
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تعذر الحفظ: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return AlertDialog(
      title: Text(isEdit ? 'تعديل إعلان' : 'إضافة إعلان'),
      content: SizedBox(
        width: 760,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'العنوان'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _content,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'المحتوى'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<Priority>(
                      value: _priority,
                      decoration: const InputDecoration(labelText: 'الأولوية'),
                      items: Priority.values
                          .map(
                            (value) => DropdownMenuItem<Priority>(
                              value: value,
                              child: Text(value.displayName),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (value) =>
                          setState(() => _priority = value ?? _priority),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _targetAudience,
                      decoration: const InputDecoration(
                        labelText: 'الجمهور المستهدف',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SharedContentUploadField(
                controller: _imageUrl,
                label: 'صورة الإعلان',
                hintText: 'رابط صورة أو ارفع ملفًا',
                buttonLabel: 'رفع صورة',
                busy: _uploadingImage,
                onUpload: _uploadImage,
              ),
              const SizedBox(height: 10),
              SharedContentUploadField(
                controller: _attachmentUrl,
                label: 'مرفق الإعلان (اختياري)',
                hintText: 'PDF / DOC / ZIP ...',
                buttonLabel: 'رفع مرفق',
                busy: _uploadingAttachment,
                onUpload: _uploadAttachment,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickValidUntil,
                      icon: const Icon(Icons.event_busy_rounded),
                      label: Text(
                        _validUntil == null
                            ? 'تاريخ انتهاء (اختياري)'
                            : 'ينتهي: ${_validUntil!.toLocal().toString().substring(0, 10)}',
                      ),
                    ),
                  ),
                  if (_validUntil != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'مسح تاريخ الانتهاء',
                      onPressed: () => setState(() => _validUntil = null),
                      icon: const Icon(Icons.clear_rounded),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              SharedContentPublicationFields(
                mode: _publicationMode,
                onModeChanged: (value) =>
                    setState(() => _publicationMode = value),
                isFeatured: _isFeatured,
                onFeaturedChanged: (value) =>
                    setState(() => _isFeatured = value),
                isPinned: _isPinned,
                onPinnedChanged: (value) => setState(() => _isPinned = value),
                sortOrder: _sortOrder,
                onSortOrderChanged: (value) =>
                    setState(() => _sortOrder = value),
                publishAt: _publishAt,
                onPickPublishAt: _pickPublishAt,
                onClearPublishAt: () => setState(() => _publishAt = null),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('حفظ'),
        ),
      ],
    );
  }
}
