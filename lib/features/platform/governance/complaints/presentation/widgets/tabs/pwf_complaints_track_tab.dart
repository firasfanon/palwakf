import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/pwf_complaint.dart';
import '../../l10n/pwf_complaints_strings.dart';
import '../../providers/pwf_complaints_providers.dart';
import '../../utils/pwf_complaints_validators.dart';
import '../../utils/pwf_datetime_format.dart';
import '../pwf_section_card.dart';
import '../pwf_status_badge.dart';

class PwfComplaintsTrackTab extends ConsumerStatefulWidget {
  const PwfComplaintsTrackTab({super.key});

  @override
  ConsumerState<PwfComplaintsTrackTab> createState() =>
      _PwfComplaintsTrackTabState();
}

class _PwfComplaintsTrackTabState extends ConsumerState<PwfComplaintsTrackTab> {
  final _refCtrl = TextEditingController();
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    final lastRef = ref.read(pwfLastSubmittedReferenceProvider);
    if (lastRef != null && lastRef.trim().isNotEmpty) {
      _refCtrl.text = lastRef;
      // Defer auto-track slightly so route/gesture transitions on web settle first.
      Future<void>.delayed(const Duration(milliseconds: 60), () {
        if (!mounted) return;
        _track();
      });
    }
  }

  @override
  void dispose() {
    _refCtrl.dispose();
    super.dispose();
  }

  Future<void> _track() async {
    final s = PwfComplaintsStrings.of(context);
    final refText = _refCtrl.text;

    if (!PwfComplaintsValidators.isValidReference(refText)) {
      setState(() => _hasSearched = true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(s.t('complaints.validation.ref'))));
      return;
    }

    setState(() => _hasSearched = true);
    await ref.read(pwfComplaintTrackControllerProvider.notifier).track(refText);
  }

  String _typeLabel(BuildContext context, PwfComplaintType t) {
    final s = PwfComplaintsStrings.of(context);
    return s.t('complaints.type.${t.name}');
  }

  String _deptLabel(BuildContext context, PwfComplaintDepartment d) {
    final s = PwfComplaintsStrings.of(context);
    return s.t('complaints.dept.${d.name}');
  }

  @override
  Widget build(BuildContext context) {
    final s = PwfComplaintsStrings.of(context);
    final state = ref.watch(pwfComplaintTrackControllerProvider);

    return SingleChildScrollView(
      child: PwfSectionCard(
        child: Column(
          children: [
            _TitleRow(
              icon: Icons.search_rounded,
              title: s.t('complaints.track.title'),
              subtitle: s.t('complaints.track.subtitle'),
            ),
            const SizedBox(height: 20),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                children: [
                  TextField(
                    controller: _refCtrl,
                    decoration: InputDecoration(
                      labelText: s.t('complaints.track.refLabel'),
                      hintText: s.t('complaints.track.refHint'),
                      prefixIcon: const Icon(Icons.tag_rounded),
                      border: const OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _track(),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 220,
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: state.isLoading ? null : _track,
                      icon: state.isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.search),
                      label: Text(s.t('complaints.btn.track')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2A6E3F),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            state.when(
              data: (complaint) {
                if (complaint == null) {
                  if (!_hasSearched) return const SizedBox.shrink();
                  return _NotFoundCard(
                    title: s.t('complaints.track.notFound.title'),
                    body: s.t('complaints.track.notFound.body'),
                  );
                }

                return _TrackResultCard(
                  complaint: complaint,
                  typeLabel: _typeLabel(context, complaint.type),
                  deptLabel: _deptLabel(context, complaint.department),
                );
              },
              error: (e, _) => _NotFoundCard(
                title: s.t('complaints.track.notFound.title'),
                body: e.toString(),
              ),
              loading: () => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _TitleRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _TitleRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF0D3C61)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0D3C61),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            color: const Color(0xFF666666).withValues(alpha: 220),
          ),
        ),
      ],
    );
  }
}

class _NotFoundCard extends StatelessWidget {
  final String title;
  final String body;
  const _NotFoundCard({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFF0D3C61)),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(
            body,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF666666)),
          ),
        ],
      ),
    );
  }
}

class _TrackResultCard extends StatelessWidget {
  final PwfComplaint complaint;
  final String typeLabel;
  final String deptLabel;

  const _TrackResultCard({
    required this.complaint,
    required this.typeLabel,
    required this.deptLabel,
  });

  Color _borderColor(PwfComplaintStatus s) {
    switch (s) {
      case PwfComplaintStatus.pending:
        return const Color(0xFFFFC107);
      case PwfComplaintStatus.processing:
        return const Color(0xFF007BFF);
      case PwfComplaintStatus.resolved:
        return const Color(0xFF2A6E3F);
      case PwfComplaintStatus.rejected:
        return const Color(0xFFB22222);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = PwfComplaintsStrings.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 14),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border(
          right: BorderSide(color: _borderColor(complaint.status), width: 4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PwfStatusBadge(status: complaint.status),
          const SizedBox(height: 12),
          Text(
            complaint.subject,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0D3C61),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 18,
            runSpacing: 8,
            children: [
              _MetaItem(
                icon: Icons.category_rounded,
                label: s.t('complaints.track.meta.type'),
                value: typeLabel,
              ),
              _MetaItem(
                icon: Icons.apartment_rounded,
                label: s.t('complaints.track.meta.department'),
                value: deptLabel,
              ),
              _MetaItem(
                icon: Icons.calendar_month_rounded,
                label: s.t('complaints.track.meta.date'),
                value: PwfDateTimeFormat.formatShortDate(
                  context,
                  complaint.createdAt,
                ),
              ),
              _MetaItem(
                icon: Icons.tag_rounded,
                label: s.t('complaints.track.refLabel'),
                value: complaint.referenceCode,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            s.t('complaints.track.details'),
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFF0D3C61),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            complaint.description,
            style: const TextStyle(color: Color(0xFF666666)),
          ),
          const SizedBox(height: 18),
          Text(
            s.t('complaints.track.history'),
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFF0D3C61),
            ),
          ),
          const SizedBox(height: 10),
          if (complaint.updates.isEmpty)
            Text(
              s.t('complaints.update.received'),
              style: const TextStyle(color: Color(0xFF666666)),
            )
          else
            ...complaint.updates.map((u) => _UpdateItem(update: u)),
        ],
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetaItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF0D3C61)),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(
            color: const Color(0xFF666666).withValues(alpha: 220),
          ),
        ),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _UpdateItem extends StatelessWidget {
  final PwfComplaintUpdate update;
  const _UpdateItem({required this.update});

  Color _color(PwfComplaintStatus s) {
    switch (s) {
      case PwfComplaintStatus.pending:
        return const Color(0xFFFFC107);
      case PwfComplaintStatus.processing:
        return const Color(0xFF007BFF);
      case PwfComplaintStatus.resolved:
        return const Color(0xFF2A6E3F);
      case PwfComplaintStatus.rejected:
        return const Color(0xFFB22222);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = PwfComplaintsStrings.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          right: BorderSide(color: _color(update.status), width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  s.t('complaints.status.${update.status.name}'),
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              Text(
                '${PwfDateTimeFormat.formatShortDate(context, update.date)} - ${PwfDateTimeFormat.formatTime(context, update.date)}',
                style: TextStyle(
                  color: const Color(0xFF666666).withValues(alpha: 220),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            s.t(update.messageKey),
            style: const TextStyle(color: Color(0xFF666666)),
          ),
        ],
      ),
    );
  }
}
