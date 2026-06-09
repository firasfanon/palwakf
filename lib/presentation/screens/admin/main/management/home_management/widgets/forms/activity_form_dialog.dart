import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:waqf/data/models/activity.dart';
import 'package:waqf/presentation/providers/supabase_providers.dart';

import '../shared/shared_content_media_upload_helper.dart';
import '../shared/shared_content_publication_fields.dart';
import '../shared/shared_content_save_helper.dart';

class ActivityFormDialog extends ConsumerStatefulWidget {
  final String unitId;
  final String unitSlug;
  final Activity? existing;
  final String? titleOverride;
  final String? editTitleOverride;
  final ActivityType? initialType;

  const ActivityFormDialog({
    super.key,
    required this.unitId,
    required this.unitSlug,
    this.existing,
    this.titleOverride,
    this.editTitleOverride,
    this.initialType,
  });

  @override
  ConsumerState<ActivityFormDialog> createState() => _ActivityFormDialogState();
}

class _ActivityFormDialogState extends ConsumerState<ActivityFormDialog> {
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _location;
  late final TextEditingController _organizer;
  late final TextEditingController _governorate;
  late final TextEditingController _imageUrl;
  late final TextEditingController _attachmentUrl;
  late final TextEditingController _tags;

  late final TextEditingController _contactName;
  late final TextEditingController _contactPhone;
  late final TextEditingController _contactEmail;

  ActivityCategory _category = ActivityCategory.religious;
  ActivityType _type = ActivityType.lecture;
  ActivityStatus _status = ActivityStatus.upcoming;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _isFeatured = false;
  bool _isPinned = false;
  int _sortOrder = 0;
  DateTime? _publishAt;
  SharedContentPublicationMode _publicationMode =
      SharedContentPublicationMode.draft;

  bool _saving = false;
  bool _uploadingImage = false;
  bool _uploadingAttachment = false;

  @override
  void initState() {
    super.initState();
    final a = widget.existing;
    _title = TextEditingController(text: a?.title ?? '');
    _description = TextEditingController(text: a?.description ?? '');
    _location = TextEditingController(text: a?.location ?? '');
    _organizer = TextEditingController(text: a?.organizer ?? '');
    _governorate = TextEditingController(text: a?.governorate ?? '');
    _imageUrl = TextEditingController(text: a?.imageUrl ?? '');
    _attachmentUrl = TextEditingController(text: a?.attachmentUrl ?? '');
    _tags = TextEditingController(text: (a?.tags ?? const []).join(', '));

    _contactName = TextEditingController(text: a?.contact.name ?? '');
    _contactPhone = TextEditingController(text: a?.contact.phone ?? '');
    _contactEmail = TextEditingController(text: a?.contact.email ?? '');

    if (a != null) {
      _category = a.category;
      _type = a.type;
      _status = a.status;
      _startDate = a.startDate;
      _endDate = a.endDate;
      _isFeatured = a.isFeatured;
      _isPinned = a.isPinned;
      _sortOrder = a.sortOrder;
      _publishAt = a.publishAt;
      _publicationMode = _deriveMode(a);
    } else if (widget.initialType != null) {
      _type = widget.initialType!;
    }
  }

  SharedContentPublicationMode _deriveMode(Activity activity) {
    final now = DateTime.now();
    if (activity.publishAt != null && activity.publishAt!.isAfter(now)) {
      return SharedContentPublicationMode.scheduled;
    }
    if (activity.publishAt != null) {
      return SharedContentPublicationMode.published;
    }
    return SharedContentPublicationMode.draft;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _location.dispose();
    _organizer.dispose();
    _governorate.dispose();
    _imageUrl.dispose();
    _attachmentUrl.dispose();
    _tags.dispose();
    _contactName.dispose();
    _contactPhone.dispose();
    _contactEmail.dispose();
    super.dispose();
  }

  List<String> _parseTags(String raw) {
    return raw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);
  }

  Future<DateTime?> _pickDateTime(DateTime initial) async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: initial,
    );
    if (date == null) return null;
    if (!mounted) return null;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null) return DateTime(date.year, date.month, date.day);
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _pickPublishAt() async {
    final picked = await _pickDateTime(_publishAt ?? DateTime.now());
    if (picked == null || !mounted) return;
    setState(() => _publishAt = picked);
  }

  Future<void> _uploadImage() async {
    setState(() => _uploadingImage = true);
    final url = await SharedContentMediaUploadHelper.pickAndUpload(
      context: context,
      familyKey: 'activities',
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
      familyKey: 'activities',
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
    final description = _description.text.trim();

    if (title.isEmpty || description.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال العنوان والوصف')),
      );
      return;
    }

    if (_publicationMode == SharedContentPublicationMode.scheduled &&
        _publishAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدد موعد النشر قبل حفظ النشاط/الفعالية المجدولة.'),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final supabase = ref.read(supabaseServiceProvider).client;
      final now = DateTime.now();
      final effectivePublishAt = switch (_publicationMode) {
        SharedContentPublicationMode.published =>
          _publishAt ?? widget.existing?.publishAt ?? now,
        SharedContentPublicationMode.scheduled => _publishAt,
        _ => _publishAt,
      };

      final existingInfo =
          widget.existing?.registrationInfo ?? const <String, dynamic>{};
      final publishingInfo = <String, dynamic>{
        ...((existingInfo['publishing'] as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{}),
        'mode': _publicationMode.name,
        'is_featured': _isFeatured,
        'is_pinned': _isPinned,
        'publish_at': effectivePublishAt?.toIso8601String(),
        'sort_order': _sortOrder,
      };
      final mediaInfo = <String, dynamic>{
        ...((existingInfo['media'] as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{}),
        'cover_image_url': _imageUrl.text.trim().isEmpty
            ? null
            : _imageUrl.text.trim(),
        'attachment_url': _attachmentUrl.text.trim().isEmpty
            ? null
            : _attachmentUrl.text.trim(),
      };

      final basePayload = <String, dynamic>{
        'unit_id': widget.unitId,
        'title': title,
        'description': description,
        'category': _category.name,
        'type': _type.name,
        'status': _status.name,
        'start_date': _startDate.toIso8601String(),
        'end_date': _endDate?.toIso8601String(),
        'location': _location.text.trim(),
        'organizer': _organizer.text.trim(),
        'governorate': _governorate.text.trim(),
        'image_url': _imageUrl.text.trim().isEmpty
            ? null
            : _imageUrl.text.trim(),
        'tags': _parseTags(_tags.text),
        'contact': {
          'name': _contactName.text.trim().isEmpty
              ? '—'
              : _contactName.text.trim(),
          'phone': _contactPhone.text.trim().isEmpty
              ? '—'
              : _contactPhone.text.trim(),
          'email': _contactEmail.text.trim().isEmpty
              ? null
              : _contactEmail.text.trim(),
          'whatsapp': null,
        },
        'max_participants': 0,
        'current_participants': 0,
        'requires_registration': false,
        'is_free': true,
        'price': null,
        'registration_url': null,
        'registration_deadline': null,
        'registration_info': {
          ...existingInfo,
          'publishing': publishingInfo,
          'media': mediaInfo,
        },
        'requirements': <String>[],
        'updated_at': now.toIso8601String(),
      };
      if (widget.existing == null) {
        basePayload['created_at'] = now.toIso8601String();
      }

      final optionalPayload = <String, dynamic>{
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
        table: 'activities',
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
    final titleText = isEdit
        ? (widget.editTitleOverride ?? 'تعديل نشاط')
        : (widget.titleOverride ?? 'إضافة نشاط');
    return AlertDialog(
      title: Text(titleText),
      content: SizedBox(
        width: 780,
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
                controller: _description,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'الوصف'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<ActivityCategory>(
                      value: _category,
                      items: ActivityCategory.values
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(e.displayName),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (v) =>
                          setState(() => _category = v ?? _category),
                      decoration: const InputDecoration(labelText: 'التصنيف'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<ActivityType>(
                      value: _type,
                      items: ActivityType.values
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(e.displayName),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (v) => setState(() => _type = v ?? _type),
                      decoration: const InputDecoration(labelText: 'النوع'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<ActivityStatus>(
                      value: _status,
                      items: ActivityStatus.values
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(e.displayName),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (v) => setState(() => _status = v ?? _status),
                      decoration: const InputDecoration(
                        labelText: 'الحالة التشغيلية',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final dt = await _pickDateTime(_startDate);
                        if (dt == null || !mounted) return;
                        setState(() => _startDate = dt);
                      },
                      icon: const Icon(Icons.event),
                      label: Text(
                        'بدء: ${_startDate.toLocal().toString().substring(0, 16)}',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final dt = await _pickDateTime(_endDate ?? _startDate);
                        if (dt == null || !mounted) return;
                        setState(() => _endDate = dt);
                      },
                      icon: const Icon(Icons.event_available),
                      label: Text(
                        _endDate == null
                            ? 'نهاية (اختياري)'
                            : 'نهاية: ${_endDate!.toLocal().toString().substring(0, 16)}',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _location,
                      decoration: const InputDecoration(labelText: 'المكان'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _organizer,
                      decoration: const InputDecoration(labelText: 'المنظم'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _governorate,
                      decoration: const InputDecoration(labelText: 'المحافظة'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _tags,
                      decoration: const InputDecoration(
                        labelText: 'وسوم (فصل بفواصل)',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SharedContentUploadField(
                controller: _imageUrl,
                label: 'صورة النشاط / الفعالية',
                hintText: 'رابط صورة أو ارفع ملفًا',
                buttonLabel: 'رفع صورة',
                busy: _uploadingImage,
                onUpload: _uploadImage,
              ),
              const SizedBox(height: 10),
              SharedContentUploadField(
                controller: _attachmentUrl,
                label: 'مرفق النشاط / الفعالية',
                hintText: 'PDF / DOC / ZIP ...',
                buttonLabel: 'رفع مرفق',
                busy: _uploadingAttachment,
                onUpload: _uploadAttachment,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _contactName,
                      decoration: const InputDecoration(
                        labelText: 'اسم جهة الاتصال',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _contactPhone,
                      decoration: const InputDecoration(labelText: 'هاتف'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _contactEmail,
                      decoration: const InputDecoration(
                        labelText: 'بريد (اختياري)',
                      ),
                    ),
                  ),
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
