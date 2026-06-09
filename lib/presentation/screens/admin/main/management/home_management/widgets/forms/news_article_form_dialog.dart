import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:waqf/data/models/news_article.dart';
import 'package:waqf/presentation/providers/supabase_providers.dart';

import '../shared/shared_content_media_upload_helper.dart';
import '../shared/shared_content_publication_fields.dart';
import '../shared/shared_content_save_helper.dart';

class NewsArticleFormDialog extends ConsumerStatefulWidget {
  final String unitId;
  final String unitSlug;
  final NewsArticle? existing;

  const NewsArticleFormDialog({
    super.key,
    required this.unitId,
    required this.unitSlug,
    this.existing,
  });

  @override
  ConsumerState<NewsArticleFormDialog> createState() =>
      _NewsArticleFormDialogState();
}

class _NewsArticleFormDialogState extends ConsumerState<NewsArticleFormDialog> {
  late final TextEditingController _title;
  late final TextEditingController _excerpt;
  late final TextEditingController _content;
  late final TextEditingController _imageUrl;
  late final TextEditingController _attachmentUrl;
  late final TextEditingController _author;
  late final TextEditingController _tags;

  NewsCategory _category = NewsCategory.general;
  PublishStatus _status = PublishStatus.draft;
  bool _isFeatured = false;
  bool _isPinned = false;
  int _sortOrder = 0;
  DateTime? _publishAt;

  bool _saving = false;
  bool _uploadingImage = false;
  bool _uploadingAttachment = false;

  @override
  void initState() {
    super.initState();
    final a = widget.existing;
    _title = TextEditingController(text: a?.title ?? '');
    _excerpt = TextEditingController(text: a?.excerpt ?? '');
    _content = TextEditingController(text: a?.content ?? '');
    _imageUrl = TextEditingController(text: a?.imageUrl ?? '');
    _attachmentUrl = TextEditingController(text: a?.attachmentUrl ?? '');
    _author = TextEditingController(text: a?.author ?? '');
    _tags = TextEditingController(text: (a?.tags ?? const []).join(', '));

    if (a != null) {
      _category = a.category;
      _status = a.status;
      _isFeatured = a.isFeatured;
      _isPinned = a.isPinned;
      _sortOrder = a.sortOrder;
      _publishAt = a.publishedAt;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _excerpt.dispose();
    _content.dispose();
    _imageUrl.dispose();
    _attachmentUrl.dispose();
    _author.dispose();
    _tags.dispose();
    super.dispose();
  }

  List<String> _parseTags(String raw) {
    return raw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);
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

  Future<void> _uploadCoverImage() async {
    setState(() => _uploadingImage = true);
    final url = await SharedContentMediaUploadHelper.pickAndUpload(
      context: context,
      familyKey: 'news',
      folder: 'images',
      unitScopeKey: widget.unitSlug,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp'],
    );
    if (!mounted) return;
    if (url != null) {
      setState(() => _imageUrl.text = url);
    }
    setState(() => _uploadingImage = false);
  }

  Future<void> _uploadAttachment() async {
    setState(() => _uploadingAttachment = true);
    final url = await SharedContentMediaUploadHelper.pickAndUpload(
      context: context,
      familyKey: 'news',
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
    if (url != null) {
      setState(() => _attachmentUrl.text = url);
    }
    setState(() => _uploadingAttachment = false);
  }

  Future<void> _save() async {
    final title = _title.text.trim();
    final excerpt = _excerpt.text.trim();
    final content = _content.text.trim();

    if (title.isEmpty || content.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال العنوان والمحتوى')),
      );
      return;
    }

    if (_status == PublishStatus.scheduled && _publishAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدد موعد النشر للحالة المجدولة.')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final supabase = ref.read(supabaseServiceProvider).client;
      final now = DateTime.now();
      final publishedAt = switch (_status) {
        PublishStatus.published =>
          _publishAt ?? widget.existing?.publishedAt ?? now,
        PublishStatus.scheduled => _publishAt,
        _ => null,
      };

      final basePayload = <String, dynamic>{
        'unit_id': widget.unitId,
        'title': title,
        'excerpt': excerpt,
        'content': content,
        'image_url': _imageUrl.text.trim().isEmpty
            ? null
            : _imageUrl.text.trim(),
        'author': _author.text.trim().isEmpty ? null : _author.text.trim(),
        'category': _category.name,
        'status': _status.name,
        'tags': _parseTags(_tags.text),
        'is_featured': _isFeatured,
        'published_at': publishedAt?.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      final optionalPayload = <String, dynamic>{
        'attachment_url': _attachmentUrl.text.trim().isEmpty
            ? null
            : _attachmentUrl.text.trim(),
        'is_pinned': _isPinned,
        'sort_order': _sortOrder,
      };

      if (widget.existing == null) {
        basePayload['created_at'] = now.toIso8601String();
      }

      await SharedContentSaveHelper.saveWithOptionalColumns(
        supabase: supabase,
        table: 'news_articles',
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
      title: Text(isEdit ? 'تعديل خبر' : 'إضافة خبر'),
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
                controller: _excerpt,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'ملخص (اختياري)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _content,
                maxLines: 8,
                decoration: const InputDecoration(labelText: 'المحتوى'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<NewsCategory>(
                      value: _category,
                      items: NewsCategory.values
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
                    child: DropdownButtonFormField<PublishStatus>(
                      value: _status,
                      items: PublishStatus.values
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(e.displayName),
                            ),
                          )
                          .toList(growable: false),
                      onChanged: (v) => setState(() => _status = v ?? _status),
                      decoration: const InputDecoration(
                        labelText: 'حالة الخبر',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SharedContentUploadField(
                controller: _imageUrl,
                label: 'صورة الغلاف',
                hintText: 'رابط صورة أو ارفع ملفًا',
                buttonLabel: 'رفع صورة',
                busy: _uploadingImage,
                onUpload: _uploadCoverImage,
              ),
              const SizedBox(height: 10),
              SharedContentUploadField(
                controller: _attachmentUrl,
                label: 'مرفق الخبر (اختياري)',
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
                      controller: _author,
                      decoration: const InputDecoration(
                        labelText: 'الكاتب (اختياري)',
                      ),
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
              const SizedBox(height: 12),
              SharedContentPublicationFields(
                mode: switch (_status) {
                  PublishStatus.published =>
                    SharedContentPublicationMode.published,
                  PublishStatus.scheduled =>
                    SharedContentPublicationMode.scheduled,
                  PublishStatus.archived =>
                    SharedContentPublicationMode.archived,
                  _ => SharedContentPublicationMode.draft,
                },
                onModeChanged: (value) {
                  setState(() {
                    _status = switch (value) {
                      SharedContentPublicationMode.published =>
                        PublishStatus.published,
                      SharedContentPublicationMode.scheduled =>
                        PublishStatus.scheduled,
                      SharedContentPublicationMode.archived =>
                        PublishStatus.archived,
                      SharedContentPublicationMode.draft => PublishStatus.draft,
                    };
                  });
                },
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
                modeLabel: 'وضع النشر',
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
