import 'package:flutter/material.dart';

import 'package:waqf/core/constants/app_constants.dart';
import 'package:waqf/data/models/media_gallery_item.dart';

import '../shared/shared_content_media_upload_helper.dart';
import '../shared/shared_content_publication_fields.dart';

class MediaGalleryItemFormDialog extends StatefulWidget {
  final MediaGalleryItem? item;
  final List<Map<String, dynamic>> units;
  final String initialUnitId;
  final MediaType initialType;
  final Future<void> Function(MediaGalleryFormResult) onSubmit;

  const MediaGalleryItemFormDialog({
    super.key,
    this.item,
    required this.units,
    required this.initialUnitId,
    required this.initialType,
    required this.onSubmit,
  });

  @override
  State<MediaGalleryItemFormDialog> createState() =>
      _MediaGalleryItemFormDialogState();
}

@immutable
class MediaGalleryFormResult {
  final String unitId;
  final MediaType type;
  final String title;
  final String description;
  final String mediaUrl;
  final String? thumbnailUrl;
  final String? externalUrl;
  final bool isActive;
  final int displayOrder;
  final bool isFeatured;
  final bool isPinned;
  final DateTime? publishAt;

  const MediaGalleryFormResult({
    required this.unitId,
    required this.type,
    required this.title,
    required this.description,
    required this.mediaUrl,
    required this.thumbnailUrl,
    required this.externalUrl,
    required this.isActive,
    required this.displayOrder,
    required this.isFeatured,
    required this.isPinned,
    required this.publishAt,
  });
}

class _MediaGalleryItemFormDialogState
    extends State<MediaGalleryItemFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late String _unitId;
  late MediaType _type;
  late TextEditingController _title;
  late TextEditingController _desc;
  late TextEditingController _mediaUrl;
  late TextEditingController _thumbUrl;
  late TextEditingController _externalUrl;
  late bool _isActive;
  late int _displayOrder;
  late bool _isFeatured;
  late bool _isPinned;
  late DateTime? _publishAt;
  late SharedContentPublicationMode _publicationMode;
  bool _submitting = false;

  bool _uploadingMedia = false;
  bool _uploadingThumb = false;

  @override
  void initState() {
    super.initState();
    final it = widget.item;
    _unitId = it?.unitId ?? widget.initialUnitId;
    _type = it?.mediaType ?? widget.initialType;
    _title = TextEditingController(text: it?.title ?? '');
    _desc = TextEditingController(text: it?.description ?? '');
    _mediaUrl = TextEditingController(text: it?.mediaUrl ?? '');
    _thumbUrl = TextEditingController(text: it?.thumbnailUrl ?? '');
    _externalUrl = TextEditingController(text: it?.externalUrl ?? '');
    _isActive = it?.isActive ?? true;
    _displayOrder = it?.displayOrder ?? 0;
    _isFeatured = it?.isFeatured ?? false;
    _isPinned = it?.isPinned ?? false;
    _publishAt = it?.publishAt;
    _publicationMode = _inferPublicationMode(
      isActive: _isActive,
      publishAt: _publishAt,
    );
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    _mediaUrl.dispose();
    _thumbUrl.dispose();
    _externalUrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.item != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820, maxHeight: 860),
        child: Container(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppConstants.royalRed,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _type == MediaType.photo
                              ? Icons.photo_library
                              : Icons.ondemand_video,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isEditing
                              ? 'تعديل عنصر في المعرض'
                              : 'إضافة عنصر جديد للمعرض',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.royalRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(child: _buildUnitDropdown()),
                      const SizedBox(width: 16),
                      Expanded(child: _buildTypeDropdown()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _title,
                    decoration: const InputDecoration(
                      labelText: 'العنوان',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'العنوان مطلوب'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _desc,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'الوصف',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.indigo.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.indigo.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _type == MediaType.photo
                                  ? Icons.add_photo_alternate_outlined
                                  : Icons.video_call_outlined,
                              color: Colors.indigo,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _type == MediaType.photo
                                  ? 'رفع الصورة أو لصق رابطها'
                                  : 'رفع الفيديو أو لصق رابطه',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _type == MediaType.photo
                              ? 'يمكنك رفع ملف صورة مباشرة إلى bucket المعرض، أو استخدام رابط خارجي جاهز.'
                              : 'يمكنك رفع ملف فيديو مباشر، أو استخدام رابط عام مثل YouTube/Vimeo في الرابط الخارجي.',
                          style: const TextStyle(
                            color: Color(0xFF4B5563),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SharedContentUploadField(
                    controller: _mediaUrl,
                    label: 'رابط الملف الأساسي',
                    hintText: _type == MediaType.photo
                        ? 'رابط صورة'
                        : 'رابط فيديو',
                    buttonLabel: _type == MediaType.photo
                        ? 'رفع صورة'
                        : 'رفع فيديو',
                    busy: _uploadingMedia,
                    onUpload: () => _pickAndUpload(isThumbnail: false),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SharedContentUploadField(
                          controller: _thumbUrl,
                          label: 'رابط صورة مصغّرة (اختياري)',
                          hintText: 'مفيد للفيديو أو للعرض الشبكي',
                          buttonLabel: 'رفع مصغّرة',
                          busy: _uploadingThumb,
                          onUpload: () => _pickAndUpload(isThumbnail: true),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _externalUrl,
                          decoration: const InputDecoration(
                            labelText: 'رابط خارجي (اختياري)',
                            hintText: 'YouTube / Vimeo / رابط عام',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildPreviewCard(),
                  const SizedBox(height: 16),
                  SharedContentPublicationFields(
                    mode: _publicationMode,
                    onModeChanged: (mode) {
                      setState(() {
                        _publicationMode = mode;
                        switch (mode) {
                          case SharedContentPublicationMode.draft:
                          case SharedContentPublicationMode.archived:
                            _isActive = false;
                            if (mode == SharedContentPublicationMode.draft) {
                              _publishAt = null;
                            }
                            break;
                          case SharedContentPublicationMode.published:
                            _isActive = true;
                            _publishAt = null;
                            break;
                          case SharedContentPublicationMode.scheduled:
                            _isActive = true;
                            _publishAt ??= DateTime.now().add(
                              const Duration(hours: 1),
                            );
                            break;
                        }
                      });
                    },
                    isFeatured: _isFeatured,
                    onFeaturedChanged: (value) =>
                        setState(() => _isFeatured = value),
                    isPinned: _isPinned,
                    onPinnedChanged: (value) =>
                        setState(() => _isPinned = value),
                    sortOrder: _displayOrder,
                    onSortOrderChanged: (value) =>
                        setState(() => _displayOrder = value),
                    publishAt: _publishAt,
                    onPickPublishAt: _pickPublishAt,
                    onClearPublishAt: () => setState(() => _publishAt = null),
                  ),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    value: _isActive,
                    title: const Text('نشط في الإدارة'),
                    subtitle: const Text(
                      'التحكم المباشر بحالة العنصر داخل لوحة التحكم.',
                    ),
                    onChanged: (v) => setState(() => _isActive = v ?? true),
                    activeColor: AppConstants.royalRed,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _submitting
                            ? null
                            : () => Navigator.pop(context),
                        child: const Text('إلغاء'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _submitting ? null : _handleSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.royalRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 26,
                            vertical: 14,
                          ),
                        ),
                        child: _submitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(isEditing ? 'تحديث' : 'إضافة'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUnitDropdown() {
    final units = widget.units
        .where((u) => (u['is_active'] as bool?) ?? true)
        .toList();
    return DropdownButtonFormField<String>(
      value: units.any((u) => (u['id'] ?? '').toString() == _unitId)
          ? _unitId
          : (units.isNotEmpty ? (units.first['id'] ?? '').toString() : _unitId),
      decoration: const InputDecoration(
        labelText: 'الوحدة',
        border: OutlineInputBorder(),
      ),
      items: units.map((u) {
        final id = (u['id'] ?? '').toString();
        final name = (u['name_ar'] ?? u['slug'] ?? '').toString();
        final slug = (u['slug'] ?? '').toString();
        return DropdownMenuItem<String>(
          value: id,
          child: Text('$name  ($slug)'),
        );
      }).toList(),
      onChanged: (v) => setState(() => _unitId = v ?? _unitId),
    );
  }

  Widget _buildTypeDropdown() {
    return DropdownButtonFormField<MediaType>(
      value: _type,
      decoration: const InputDecoration(
        labelText: 'نوع الوسائط',
        border: OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: MediaType.photo, child: Text('صور')),
        DropdownMenuItem(value: MediaType.video, child: Text('فيديو')),
      ],
      onChanged: (v) => setState(() => _type = v ?? _type),
    );
  }

  Widget _buildPreviewCard() {
    final previewUrl =
        (_thumbUrl.text.trim().isNotEmpty
                ? _thumbUrl.text.trim()
                : _mediaUrl.text.trim())
            .trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'معاينة سريعة',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          if (previewUrl.isEmpty)
            const Text(
              'ستظهر المعاينة هنا بعد رفع الملف أو لصق الرابط.',
              style: TextStyle(color: Color(0xFF6B7280)),
            )
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  previewUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFFE5E7EB),
                    child: Center(
                      child: Icon(
                        _type == MediaType.photo
                            ? Icons.image_outlined
                            : Icons.ondemand_video_outlined,
                        size: 42,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _pickAndUpload({required bool isThumbnail}) async {
    final allowed = isThumbnail
        ? <String>['jpg', 'jpeg', 'png', 'webp']
        : (_type == MediaType.photo
              ? <String>['jpg', 'jpeg', 'png', 'webp']
              : <String>['mp4', 'mov', 'm4v', 'webm']);

    final familyKey = 'gallery';
    final folder = isThumbnail
        ? 'thumbs'
        : (_type == MediaType.photo ? 'photos' : 'videos');

    final scopeKey = _scopeKeyForUnitId(_unitId);

    try {
      setState(() {
        if (isThumbnail) {
          _uploadingThumb = true;
        } else {
          _uploadingMedia = true;
        }
      });

      final url = await SharedContentMediaUploadHelper.pickAndUpload(
        context: context,
        familyKey: familyKey,
        folder: folder,
        unitScopeKey: scopeKey,
        allowedExtensions: allowed,
      );

      if (url == null || url.trim().isEmpty) return;

      setState(() {
        if (isThumbnail) {
          _thumbUrl.text = url;
        } else {
          _mediaUrl.text = url;
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          _uploadingMedia = false;
          _uploadingThumb = false;
        });
      }
    }
  }

  Future<void> _pickPublishAt() async {
    final now = DateTime.now();
    final base = _publishAt ?? now;
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (pickedDate == null || !mounted) return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(base),
    );
    if (pickedTime == null || !mounted) return;
    setState(() {
      _publishAt = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      _publicationMode = SharedContentPublicationMode.scheduled;
      _isActive = true;
    });
  }

  SharedContentPublicationMode _inferPublicationMode({
    required bool isActive,
    required DateTime? publishAt,
  }) {
    if (!isActive) return SharedContentPublicationMode.draft;
    if (publishAt != null && publishAt.isAfter(DateTime.now())) {
      return SharedContentPublicationMode.scheduled;
    }
    return SharedContentPublicationMode.published;
  }

  String _scopeKeyForUnitId(String unitId) {
    final row = widget.units.cast<Map<String, dynamic>?>().firstWhere(
      (u) => (u?['id'] ?? '').toString() == unitId,
      orElse: () => null,
    );
    final slug = (row?['slug'] ?? '').toString().trim().toLowerCase();
    if (slug.isNotEmpty) return slug;
    return unitId.trim().isEmpty ? 'home' : unitId;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_mediaUrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('رابط الملف الأساسي مطلوب')));
      return;
    }
    setState(() => _submitting = true);
    try {
      final res = MediaGalleryFormResult(
        unitId: _unitId,
        type: _type,
        title: _title.text.trim(),
        description: _desc.text.trim(),
        mediaUrl: _mediaUrl.text.trim(),
        thumbnailUrl: _thumbUrl.text.trim().isEmpty
            ? null
            : _thumbUrl.text.trim(),
        externalUrl: _externalUrl.text.trim().isEmpty
            ? null
            : _externalUrl.text.trim(),
        isActive: _isActive,
        displayOrder: _displayOrder,
        isFeatured: _isFeatured,
        isPinned: _isPinned,
        publishAt: _publishAt,
      );
      await widget.onSubmit(res);
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
