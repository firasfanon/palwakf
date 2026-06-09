import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/pwf_admin_complaint.dart';
import '../../../data/models/pwf_complaint.dart';
import '../../l10n/pwf_complaints_strings.dart';
import '../../providers/pwf_admin_complaints_providers.dart';
import '../../widgets/pwf_section_card.dart';
import '../../widgets/pwf_status_badge.dart';
import '../../widgets/admin/pwf_admin_complaint_details_dialog.dart';
import '../../utils/pwf_datetime_format.dart';

class PwfAdminComplaintsScreen extends ConsumerStatefulWidget {
  const PwfAdminComplaintsScreen({super.key});

  @override
  ConsumerState<PwfAdminComplaintsScreen> createState() =>
      _PwfAdminComplaintsScreenState();
}

class _PwfAdminComplaintsScreenState
    extends ConsumerState<PwfAdminComplaintsScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = PwfComplaintsStrings.of(context);
    final cs = Theme.of(context).colorScheme;

    final filter = ref.watch(pwfAdminComplaintsFilterProvider);
    final listAsync = ref.watch(pwfAdminComplaintsListProvider);

    if (_searchCtrl.text != filter.query) {
      _searchCtrl.text = filter.query;
      _searchCtrl.selection = TextSelection.fromPosition(
        TextPosition(offset: _searchCtrl.text.length),
      );
    }

    return Scaffold(
      backgroundColor: cs.surfaceContainerLowest,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      s.t('complaints.admin.title'),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ),
                  IconButton(
                    tooltip: s.t('complaints.admin.refresh'),
                    onPressed: () =>
                        ref.invalidate(pwfAdminComplaintsListProvider),
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              PwfSectionCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search),
                              labelText: s.t('complaints.admin.search'),
                              border: const OutlineInputBorder(),
                              isDense: true,
                            ),
                            onChanged: (v) {
                              ref
                                  .read(
                                    pwfAdminComplaintsFilterProvider.notifier,
                                  )
                                  .state = filter.copyWith(
                                query: v,
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 220,
                          child: DropdownButtonFormField<PwfComplaintStatus?>(
                            value: filter.status,
                            decoration: InputDecoration(
                              labelText: s.t('complaints.admin.statusFilter'),
                              border: const OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: [
                              DropdownMenuItem<PwfComplaintStatus?>(
                                value: null,
                                child: Text(s.t('complaints.admin.statusAll')),
                              ),
                              ...PwfComplaintStatus.values.map(
                                (st) => DropdownMenuItem<PwfComplaintStatus?>(
                                  value: st,
                                  child: Text(
                                    s.t('complaints.status.${st.name}'),
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (v) {
                              ref
                                  .read(
                                    pwfAdminComplaintsFilterProvider.notifier,
                                  )
                                  .state = filter.copyWith(
                                status: v,
                                clearStatus: v == null,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          '${s.t('complaints.admin.total')}: ${listAsync.maybeWhen(data: (d) => d.length, orElse: () => 0)}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: cs.onSurface.withValues(alpha: 0.70),
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: listAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(
                    child: Text(
                      '${s.t('complaints.admin.error')}: $e',
                      style: TextStyle(color: cs.error),
                    ),
                  ),
                  data: (items) {
                    if (items.isEmpty) {
                      return Center(child: Text(s.t('complaints.admin.empty')));
                    }

                    return ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) =>
                          _ComplaintRow(item: items[i]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComplaintRow extends ConsumerWidget {
  final PwfAdminComplaintItem item;

  const _ComplaintRow({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = PwfComplaintsStrings.of(context);
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (_) =>
              PwfAdminComplaintDetailsDialog(referenceCode: item.referenceCode),
        );
      },
      child: PwfSectionCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 150,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    item.referenceCode,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    PwfDateTimeFormat.format(context, item.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.subject,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    runSpacing: 6,
                    children: [
                      _SmallChip(
                        text: s.t('complaints.type.${item.type.name}'),
                      ),
                      _SmallChip(
                        text: s.t('complaints.dept.${item.department.name}'),
                      ),
                      if (item.attachmentsCount > 0)
                        _SmallChip(
                          text:
                              '${s.t('complaints.admin.attachmentsCount')}: ${item.attachmentsCount}',
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            PwfStatusBadge(status: item.status),
          ],
        ),
      ),
    );
  }
}

class _SmallChip extends StatelessWidget {
  final String text;

  const _SmallChip({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outline.withValues(alpha: 0.20)),
      ),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}
