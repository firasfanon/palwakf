
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/models/media_center_publish_models.dart';
import '../../data/repositories/media_center_mobile_local_draft_store.dart';
import '../providers/media_center_publishing_providers.dart';
import '../providers/media_center_local_draft_providers.dart';
import '../widgets/media_center_mobile_visual_contract.dart';

class MediaCenterQuickPublishPage extends ConsumerStatefulWidget {
  const MediaCenterQuickPublishPage({super.key, this.initialDraft});

  final Object? initialDraft;

  @override
  ConsumerState<MediaCenterQuickPublishPage> createState() =>
      _MediaCenterQuickPublishPageState();
}

class _MediaCenterQuickPublishPageState
    extends ConsumerState<MediaCenterQuickPublishPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _summaryController = TextEditingController();
  final _bodyController = TextEditingController();
  final _unitSlugController = TextEditingController(text: 'home');

  MediaPublishingContentType _contentType = MediaPublishingContentType.news;
  MediaMobilePublishAction _action = MediaMobilePublishAction.submitForReview;
  XFile? _pickedImage;
  bool _busy = false;
  MediaMobilePublishResult? _lastResult;

  @override
  void initState() {
    super.initState();
    final extra = widget.initialDraft;
    if (extra is MediaCenterLocalDraft) {
      _contentType = extra.contentType;
      _titleController.text = extra.titleAr;
      _summaryController.text = extra.summaryAr;
      _bodyController.text = extra.bodyAr;
      _unitSlugController.text = extra.unitSlug;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _bodyController.dispose();
    _unitSlugController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repository = ref.watch(mediaCenterMobilePublishingRepositoryProvider);
    final signedIn = repository.isSignedIn;

    return MediaCenterMobileShell(
      title: 'نشر رسمي سريع',
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          MediaCenterOfficialHero(
            title: 'الموقع الرسمي أولًا',
            subtitle:
                'أنشئ الخبر من الهاتف، واحفظه محليًا عند ضعف الإنترنت، ثم أرسله للمنصة الرسمية وشارك الرابط الرسمي.',
            icon: Icons.verified,
            chips: [
              MediaCenterContractChip(
                label: signedIn ? 'جلسة موثقة' : 'تسجيل الدخول مطلوب',
                icon: signedIn ? Icons.verified_user : Icons.lock_outline,
                emphasis: signedIn,
                danger: !signedIn,
              ),
              const MediaCenterContractChip(
                label: 'Audit',
                icon: Icons.history,
              ),
              const MediaCenterContractChip(
                label: 'Official URL',
                icon: Icons.link,
              ),
            ],
          ),
          if (!signedIn) const _SignInRequiredCard(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: _buildForm(signedIn: signedIn),
          ),
          if (_lastResult != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _PublishResultCard(result: _lastResult!),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton.icon(
              style: MediaCenterMobileVisualContract.secondaryButtonStyle(),
              onPressed: _busy ? null : _saveLocalDraft,
              icon: const Icon(Icons.save_outlined),
              label: const Text('حفظ على الهاتف'),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              style: MediaCenterMobileVisualContract.primaryButtonStyle(),
              onPressed: !_busy && signedIn ? _submit : null,
              icon: _busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              label: Text(_busy ? 'جارٍ التنفيذ...' : _action.labelAr),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm({required bool signedIn}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: AbsorbPointer(
          absorbing: !signedIn,
          child: Opacity(
            opacity: signedIn ? 1 : 0.58,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<MediaPublishingContentType>(
                    value: _contentType,
                    decoration: const InputDecoration(
                      labelText: 'نوع المحتوى',
                    ),
                    items: MediaPublishingContentType.values
                        .map(
                          (type) => DropdownMenuItem(
                            value: type,
                            child: Text(type.labelAr),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _contentType = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'العنوان الرسمي',
                    ),
                    maxLength: 160,
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.length < 5) return 'العنوان قصير جدًا.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _summaryController,
                    decoration: const InputDecoration(
                      labelText: 'ملخص قصير',
                    ),
                    maxLines: 3,
                    maxLength: 360,
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.length < 10) return 'الملخص مطلوب.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _bodyController,
                    decoration: const InputDecoration(
                      labelText: 'نص الخبر / الإعلان / النشاط',
                    ),
                    maxLines: 7,
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.length < 20) return 'النص التفصيلي مطلوب.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _unitSlugController,
                    decoration: const InputDecoration(
                      labelText: 'نطاق النشر / الوحدة',
                      helperText:
                          'مثال: home أو slug الخاص بالمديرية. لا يتم استنتاج الوحدة تلقائيًا.',
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ImagePickerTile(
                    pickedImage: _pickedImage,
                    onPick: _pickImage,
                    onClear: () => setState(() => _pickedImage = null),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<MediaMobilePublishAction>(
                    value: _action,
                    decoration: const InputDecoration(
                      labelText: 'مسار الاعتماد',
                    ),
                    items: MediaMobilePublishAction.values
                        .map(
                          (action) => DropdownMenuItem(
                            value: action,
                            child: Text(action.labelAr),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _action = value);
                    },
                  ),
                  const SizedBox(height: 10),
                  const _GovernanceNote(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      imageQuality: 86,
    );
    if (picked == null) return;
    setState(() => _pickedImage = picked);
  }

  Future<void> _saveLocalDraft() async {
    final store = ref.read(mediaCenterLocalDraftStoreProvider);
    final now = DateTime.now();
    final extra = widget.initialDraft;
    final current = extra is MediaCenterLocalDraft ? extra : null;

    final draft = MediaCenterLocalDraft(
      id: current?.id ?? 'local_${now.microsecondsSinceEpoch}',
      contentType: _contentType,
      titleAr: _titleController.text,
      summaryAr: _summaryController.text,
      bodyAr: _bodyController.text,
      unitSlug: _unitSlugController.text.trim().isEmpty
          ? 'home'
          : _unitSlugController.text.trim(),
      createdAt: current?.createdAt ?? now,
      updatedAt: now,
    );

    await store.saveDraft(draft);
    ref.invalidate(mediaCenterLocalDraftsProvider);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حفظ المسودة محليًا على الهاتف.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _submit() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    final repository = ref.read(mediaCenterMobilePublishingRepositoryProvider);

    setState(() {
      _busy = true;
      _lastResult = null;
    });

    try {
      String? storagePath;
      int? sizeBytes;
      String? mimeType;

      final image = _pickedImage;
      if (image != null) {
        final bytes = await image.length();
        storagePath = await repository.uploadPrimaryImage(
          file: image,
          contentType: _contentType,
          unitSlug: _unitSlugController.text.trim(),
        );
        sizeBytes = bytes;
        mimeType = image.mimeType;
      }

      final draft = MediaMobilePublishDraft(
        contentType: _contentType,
        titleAr: _titleController.text,
        summaryAr: _summaryController.text,
        bodyAr: _bodyController.text,
        unitSlug: _unitSlugController.text.trim().isEmpty
            ? 'home'
            : _unitSlugController.text.trim(),
        primaryAssetBucket: storagePath == null ? null : 'media-gallery',
        primaryAssetPath: storagePath,
        primaryAssetMimeType: mimeType,
        primaryAssetSizeBytes: sizeBytes,
      );

      final result = await repository.execute(draft: draft, action: _action);

      if (!mounted) return;
      setState(() => _lastResult = result);

      if (result.isPublished && result.officialUrl.trim().isNotEmpty) {
        await Share.share(
          'رابط رسمي من وزارة الأوقاف والشؤون الدينية:\n${result.officialUrl}',
          subject: result.messageAr,
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          behavior: SnackBarBehavior.floating,
          backgroundColor: MediaCenterMobileVisualContract.royalRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _SignInRequiredCard extends StatelessWidget {
  const _SignInRequiredCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Card(
        color: const Color(0xFFFFF1F2),
        child: const Padding(
          padding: EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(
                Icons.lock_outline,
                color: MediaCenterMobileVisualContract.royalRed,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'هذه واجهة موظفين. يجب تسجيل الدخول قبل إنشاء أو إرسال أو نشر أي محتوى رسمي.',
                  style: TextStyle(
                    color: MediaCenterMobileVisualContract.royalRed,
                    height: 1.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImagePickerTile extends StatelessWidget {
  const _ImagePickerTile({
    required this.pickedImage,
    required this.onPick,
    required this.onClear,
  });

  final XFile? pickedImage;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final image = pickedImage;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: MediaCenterMobileVisualContract.border),
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
      ),
      child: ListTile(
        leading: const Icon(
          Icons.photo_camera_outlined,
          color: MediaCenterMobileVisualContract.platformBlue,
        ),
        title: Text(
          image == null ? 'إضافة صورة من الهاتف' : image.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: const Text(
          'الصورة ترفع إلى media-gallery لكنها لا تصبح public إلا بعد نشر المحتوى رسميًا.',
          style: TextStyle(height: 1.45),
        ),
        trailing: image == null
            ? IconButton(
                onPressed: onPick,
                icon: const Icon(Icons.add_a_photo_outlined),
              )
            : IconButton(
                onPressed: onClear,
                icon: const Icon(Icons.close),
              ),
      ),
    );
  }
}

class _GovernanceNote extends StatelessWidget {
  const _GovernanceNote();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'الموظف العادي يرسل للمراجعة. الناشر المعتمد يستطيع النشر المباشر فقط إذا سمحت صلاحياته. كل عملية تسجل في audit.',
      style: TextStyle(
        color: MediaCenterMobileVisualContract.muted,
        height: 1.55,
      ),
    );
  }
}

class _PublishResultCard extends StatelessWidget {
  const _PublishResultCard({required this.result});

  final MediaMobilePublishResult result;

  @override
  Widget build(BuildContext context) {
    final published = result.isPublished;
    return Card(
      color: published
          ? MediaCenterMobileVisualContract.successSoft
          : MediaCenterMobileVisualContract.warningSoft,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              result.messageAr,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text('الحالة: ${result.status}'),
            if (result.officialUrl.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              SelectableText(result.officialUrl),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                style: MediaCenterMobileVisualContract.secondaryButtonStyle(),
                onPressed: () => Share.share(result.officialUrl),
                icon: const Icon(Icons.share),
                label: const Text('مشاركة الرابط الرسمي'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
