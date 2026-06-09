import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/pwf_complaint.dart';
import '../../l10n/pwf_complaints_strings.dart';
import '../../providers/pwf_admin_complaints_providers.dart';
import '../pwf_section_card.dart';
import '../pwf_status_badge.dart';
import '../../utils/pwf_datetime_format.dart';

class PwfAdminComplaintDetailsDialog extends ConsumerStatefulWidget {
  final String referenceCode;

  const PwfAdminComplaintDetailsDialog({
    super.key,
    required this.referenceCode,
  });

  @override
  ConsumerState<PwfAdminComplaintDetailsDialog> createState() =>
      _PwfAdminComplaintDetailsDialogState();
}

class _PwfAdminComplaintDetailsDialogState
    extends ConsumerState<PwfAdminComplaintDetailsDialog> {
  PwfComplaintStatus? _selectedStatus;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final s = PwfComplaintsStrings.of(context);
    final cs = Theme.of(context).colorScheme;
    final detailsAsync = ref.watch(
      pwfAdminComplaintDetailsProvider(widget.referenceCode),
    );

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 920),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: detailsAsync.when(
            loading: () => const SizedBox(
              height: 220,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SizedBox(
              height: 220,
              child: Center(
                child: Text(
                  '${s.t('complaints.admin.error')}: $e',
                  style: TextStyle(color: cs.error),
                ),
              ),
            ),
            data: (data) {
              if (data == null) {
                return SizedBox(
                  height: 220,
                  child: Center(child: Text(s.t('complaints.admin.notFound'))),
                );
              }

              final c = data.complaint;
              _selectedStatus ??= c.status;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          s.t('complaints.admin.detailsTitle'),
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        tooltip: s.t('complaints.btn.close'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          PwfSectionCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: SelectableText(
                                        '${s.t('complaints.admin.ref')}: ${c.referenceCode}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ),
                                    PwfStatusBadge(status: c.status),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 16,
                                  runSpacing: 8,
                                  children: [
                                    _MetaChip(
                                      label: s.t('complaints.track.meta.type'),
                                      value: s.t(
                                        'complaints.type.${c.type.name}',
                                      ),
                                    ),
                                    _MetaChip(
                                      label: s.t(
                                        'complaints.track.meta.department',
                                      ),
                                      value: s.t(
                                        'complaints.dept.${c.department.name}',
                                      ),
                                    ),
                                    _MetaChip(
                                      label: s.t('complaints.track.meta.date'),
                                      value: PwfDateTimeFormat.format(
                                        context,
                                        c.createdAt,
                                      ),
                                    ),
                                    _MetaChip(
                                      label: s.t(
                                        'complaints.admin.attachmentsCount',
                                      ),
                                      value: c.attachmentsCount.toString(),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  c.subject,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 8),
                                Text(c.description),
                                const SizedBox(height: 14),
                                Divider(
                                  color: cs.outline.withValues(alpha: 0.20),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  s.t('complaints.admin.contact'),
                                  style: Theme.of(context).textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 16,
                                  runSpacing: 8,
                                  children: [
                                    _MetaChip(
                                      label: s.t('complaints.form.name'),
                                      value: c.name ?? '-',
                                    ),
                                    _MetaChip(
                                      label: s.t('complaints.form.email'),
                                      value: c.email.isEmpty ? '-' : c.email,
                                    ),
                                    _MetaChip(
                                      label: s.t('complaints.form.phone'),
                                      value: c.phone ?? '-',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          PwfSectionCard(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        s.t('complaints.admin.timeline'),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                if (c.updates.isEmpty)
                                  Text(s.t('complaints.admin.timelineEmpty'))
                                else
                                  Column(
                                    children: [
                                      for (final u in c.updates)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 6,
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: 160,
                                                child: Text(
                                                  PwfDateTimeFormat.format(
                                                    context,
                                                    u.date,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Text(s.t(u.messageKey)),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  PwfSectionCard(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<PwfComplaintStatus>(
                            value: _selectedStatus,
                            decoration: InputDecoration(
                              labelText: s.t('complaints.admin.changeStatus'),
                              border: const OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: PwfComplaintStatus.values
                                .map(
                                  (st) => DropdownMenuItem(
                                    value: st,
                                    child: Text(
                                      s.t('complaints.status.${st.name}'),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: _saving
                                ? null
                                : (v) => setState(() => _selectedStatus = v),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _saving
                              ? null
                              : () async {
                                  final next = _selectedStatus;
                                  if (next == null) return;
                                  if (next == c.status) {
                                    Navigator.of(context).pop();
                                    return;
                                  }

                                  setState(() => _saving = true);
                                  try {
                                    final repo = ref.read(
                                      pwfAdminComplaintsRepositoryProvider,
                                    );
                                    await repo.setStatus(
                                      referenceCode: c.referenceCode,
                                      status: next,
                                      messageKey:
                                          'complaints.update.${next.name}',
                                    );

                                    // refresh details + list
                                    ref.invalidate(
                                      pwfAdminComplaintDetailsProvider(
                                        widget.referenceCode,
                                      ),
                                    );
                                    ref.invalidate(
                                      pwfAdminComplaintsListProvider,
                                    );

                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            s.t('complaints.admin.statusSaved'),
                                          ),
                                        ),
                                      );
                                      Navigator.of(context).pop();
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            '${s.t('complaints.admin.error')}: $e',
                                          ),
                                          backgroundColor: cs.error,
                                        ),
                                      );
                                    }
                                  } finally {
                                    if (mounted)
                                      setState(() => _saving = false);
                                  }
                                },
                          icon: _saving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.save_outlined),
                          label: Text(s.t('complaints.admin.save')),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String label;
  final String value;

  const _MetaChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline.withValues(alpha: 0.20)),
      ),
      child: RichText(
        text: TextSpan(
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: cs.onSurface),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
