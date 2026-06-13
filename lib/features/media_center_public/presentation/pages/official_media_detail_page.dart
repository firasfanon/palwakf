
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:waqf/features/media_center_mobile/presentation/widgets/media_center_mobile_visual_contract.dart';
import 'package:waqf/presentation/providers/supabase_providers.dart';

class OfficialMediaDetailPage extends ConsumerWidget {
  const OfficialMediaDetailPage({
    super.key,
    required this.family,
    required this.id,
  });

  final String family;
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabase = ref.watch(supabaseServiceProvider).client;

    return MediaCenterMobileShell(
      title: 'رابط رسمي',
      body: FutureBuilder<Map<String, dynamic>>(
        future: supabase
            .rpc('rpc_media_center_public_content_detail_v1', params: {
              'p_family': family,
              'p_content_item_id': id,
            })
            .then((value) => _asMap(value)),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return _PublicErrorState(message: snapshot.error?.toString());
          }

          final item = snapshot.data!;
          final title = (item['title_ar'] ?? 'منشور رسمي').toString();
          final summary = (item['summary_ar'] ?? '').toString();
          final body = (item['body_ar'] ?? '').toString();
          final officialUrl = (item['official_url'] ?? '').toString();
          final publishedAt = (item['published_at'] ?? '').toString();

          return ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              MediaCenterOfficialHero(
                title: 'منشور رسمي من منصة الأوقاف',
                subtitle:
                    'هذا الرابط هو المصدر الرسمي للمحتوى. وسائل التواصل تشارك الرابط ولا تكون المصدر الأصلي.',
                icon: Icons.verified,
                chips: const [
                  MediaCenterContractChip(
                    label: 'Official URL',
                    icon: Icons.link,
                    emphasis: true,
                  ),
                  MediaCenterContractChip(
                    label: 'Published',
                    icon: Icons.public,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 24,
                            height: 1.35,
                            fontWeight: FontWeight.w900,
                            color: MediaCenterMobileVisualContract.text,
                          ),
                        ),
                        if (publishedAt.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'تاريخ النشر: $publishedAt',
                            style: const TextStyle(
                              color: MediaCenterMobileVisualContract.muted,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        if (summary.isNotEmpty)
                          Text(
                            summary,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.7,
                              color: Color(0xFF334155),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        const SizedBox(height: 18),
                        Text(
                          body.isEmpty ? summary : body,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.8,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (officialUrl.isNotEmpty)
                          FilledButton.icon(
                            style: MediaCenterMobileVisualContract
                                .primaryButtonStyle(),
                            onPressed: () => Share.share(officialUrl),
                            icon: const Icon(Icons.share),
                            label: const Text('مشاركة الرابط الرسمي'),
                          ),
                        const SizedBox(height: 12),
                        const Text(
                          'هذا المحتوى منشور من خلال المنصة الرسمية. أي مشاركة خارجية يجب أن تستخدم هذا الرابط.',
                          style: TextStyle(
                            color: MediaCenterMobileVisualContract.muted,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return const <String, dynamic>{};
  }
}

class _PublicErrorState extends StatelessWidget {
  const _PublicErrorState({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Text(
              'تعذر عرض المنشور الرسمي.\n${message ?? ''}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: MediaCenterMobileVisualContract.muted,
                height: 1.6,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
