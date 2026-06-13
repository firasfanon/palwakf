
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:waqf/app/routing/app_routes.dart';

import '../../data/models/media_center_publish_models.dart';
import '../../data/repositories/media_center_mobile_local_draft_store.dart';
import '../providers/media_center_local_draft_providers.dart';
import '../widgets/media_center_mobile_visual_contract.dart';

class MediaCenterLocalDraftsPage extends ConsumerWidget {
  const MediaCenterLocalDraftsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drafts = ref.watch(mediaCenterLocalDraftsProvider);

    return MediaCenterMobileShell(
      title: 'مسودات الهاتف',
      body: drafts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _DraftError(message: error.toString()),
        data: (items) {
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(mediaCenterLocalDraftsProvider),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: MediaCenterOfficialHero(
                    title: 'مسودات ميدانية مؤقتة',
                    subtitle:
                        'احفظ الخبر على الهاتف عند ضعف الإنترنت، ثم أرسله لاحقًا إلى المنصة الرسمية.',
                    icon: Icons.offline_pin_outlined,
                    chips: const [
                      MediaCenterContractChip(
                        label: 'Local only',
                        icon: Icons.phone_android,
                        emphasis: true,
                      ),
                      MediaCenterContractChip(
                        label: 'Not official yet',
                        icon: Icons.pending_actions,
                      ),
                    ],
                  ),
                ),
                if (items.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        'لا توجد مسودات محلية محفوظة.',
                        style: TextStyle(
                          color: MediaCenterMobileVisualContract.muted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                else
                  SliverList.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final draft = items[index];
                      return Padding(
                        padding: EdgeInsets.fromLTRB(
                          16,
                          index == 0 ? 0 : 0,
                          16,
                          0,
                        ),
                        child: _DraftCard(draft: draft),
                      );
                    },
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 96)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: MediaCenterMobileVisualContract.platformGold,
        foregroundColor: MediaCenterMobileVisualContract.platformDark,
        onPressed: () => context.push(AppRoutes.mediaCenterMobilePublish),
        icon: const Icon(Icons.add),
        label: const Text(
          'مسودة جديدة',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _DraftCard extends ConsumerWidget {
  const _DraftCard({required this.draft});

  final MediaCenterLocalDraft draft;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(mediaCenterLocalDraftStoreProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                MediaCenterSoftChip(label: _contentTypeLabel(draft.contentType), gold: true),
                const MediaCenterSoftChip(label: 'محلي فقط'),
                MediaCenterSoftChip(label: draft.unitSlug),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              draft.titleAr.trim().isEmpty ? 'مسودة بدون عنوان' : draft.titleAr,
              style: const TextStyle(
                color: MediaCenterMobileVisualContract.text,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              draft.summaryAr.trim().isEmpty
                  ? 'لم يتم إدخال ملخص بعد.'
                  : draft.summaryAr,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: MediaCenterMobileVisualContract.muted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: MediaCenterMobileVisualContract.secondaryButtonStyle(),
                    onPressed: () => context.push(
                      AppRoutes.mediaCenterMobilePublish,
                      extra: draft,
                    ),
                    icon: const Icon(Icons.edit),
                    label: const Text('متابعة التحرير'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'حذف المسودة',
                  onPressed: () async {
                    await store.deleteDraft(draft.id);
                    ref.invalidate(mediaCenterLocalDraftsProvider);
                  },
                  icon: const Icon(
                    Icons.delete_outline,
                    color: MediaCenterMobileVisualContract.royalRed,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DraftError extends StatelessWidget {
  const _DraftError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Text(
            'تعذر تحميل المسودات المحلية.\n$message',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: MediaCenterMobileVisualContract.muted,
              height: 1.6,
            ),
          ),
        ),
      ),
    );
  }
}


String _contentTypeLabel(MediaPublishingContentType type) {
  switch (type) {
    case MediaPublishingContentType.news:
      return 'خبر';
    case MediaPublishingContentType.announcement:
      return 'إعلان';
    case MediaPublishingContentType.activity:
      return 'نشاط';
  }
}
