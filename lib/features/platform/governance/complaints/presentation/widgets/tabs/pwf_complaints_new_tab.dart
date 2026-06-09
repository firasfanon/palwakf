import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/pwf_complaint.dart';
import '../../l10n/pwf_complaints_strings.dart';
import '../../providers/pwf_complaints_providers.dart';
import '../../utils/pwf_complaints_validators.dart';
import '../../utils/pwf_file_picker.dart';
import '../pwf_picked_file.dart';
import '../pwf_section_card.dart';
import '../pwf_uploaded_files_list.dart';

class PwfComplaintsNewTab extends ConsumerStatefulWidget {
  const PwfComplaintsNewTab({super.key});

  @override
  ConsumerState<PwfComplaintsNewTab> createState() =>
      _PwfComplaintsNewTabState();
}

class _PwfComplaintsNewTabState extends ConsumerState<PwfComplaintsNewTab> {
  final _formKey = GlobalKey<FormState>();

  PwfComplaintType? _type = PwfComplaintType.complaint;
  PwfComplaintDepartment? _dept = PwfComplaintDepartment.general;

  final _subjectCtrl = TextEditingController();
  final _detailsCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  final List<PwfPickedFile> _files = [];

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _detailsCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  String _typeLabel(BuildContext context, PwfComplaintType t) {
    final s = PwfComplaintsStrings.of(context);
    return s.t('complaints.type.${t.name}');
  }

  String _deptLabel(BuildContext context, PwfComplaintDepartment d) {
    final s = PwfComplaintsStrings.of(context);
    return s.t('complaints.dept.${d.name}');
  }

  Future<void> _pickFiles(BuildContext context) async {
    final s = PwfComplaintsStrings.of(context);
    final picked = await PwfFilePicker.pickFiles(multiple: true);
    if (picked.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.t('complaints.upload.notSupported'))),
      );
      return;
    }

    const maxBytes = 10 * 1024 * 1024;
    bool anyTooLarge = false;

    setState(() {
      for (final f in picked) {
        if (f.sizeBytes > maxBytes) {
          anyTooLarge = true;
          continue;
        }
        _files.add(f);
      }
    });

    if (anyTooLarge && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.t('complaints.validation.fileTooLarge'))),
      );
    }
  }

  Future<void> _submit(BuildContext context) async {
    final s = PwfComplaintsStrings.of(context);

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final type = _type;
    final dept = _dept;
    if (type == null || dept == null) return;

    final res = await ref
        .read(pwfComplaintSubmitControllerProvider.notifier)
        .submit(
          type: type,
          department: dept,
          subject: _subjectCtrl.text,
          description: _detailsCtrl.text,
          email: _emailCtrl.text,
          name: _nameCtrl.text,
          phone: _phoneCtrl.text,
          attachmentsCount: _files.length,
        );

    if (!context.mounted) return;

    if (res == null) {
      final submitState = ref.read(pwfComplaintSubmitControllerProvider);
      final err = submitState.whenOrNull(error: (e, _) => e);
      var msg = s.t('complaints.submit.error');
      if (kDebugMode && err != null) {
        msg = '$msg\n${err.toString()}';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      return;
    }

    // Save last reference for track tab
    ref.read(pwfLastSubmittedReferenceProvider.notifier).state =
        res.referenceCode;

    // Refresh suggestions if needed
    if (type == PwfComplaintType.suggestion) {
      ref.invalidate(pwfSuggestionsProvider);
    }

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(s.t('complaints.submit.success.title')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${s.t('complaints.submit.success.body1')} ${res.referenceCode}',
              ),
              const SizedBox(height: 8),
              Text(s.t('complaints.submit.success.body2')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(s.t('complaints.btn.close')),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: res.referenceCode));
                Navigator.of(ctx).pop();
              },
              icon: const Icon(Icons.copy),
              label: Text(s.t('complaints.btn.copyRef')),
            ),
          ],
        );
      },
    );

    if (!context.mounted) return;

    // Clear form
    _formKey.currentState?.reset();
    _subjectCtrl.clear();
    _detailsCtrl.clear();
    _nameCtrl.clear();
    _emailCtrl.clear();
    _phoneCtrl.clear();
    setState(() => _files.clear());

    // Switch to track tab
    final tabController = DefaultTabController.of(context);
    tabController.animateTo(1);
  }

  @override
  Widget build(BuildContext context) {
    final s = PwfComplaintsStrings.of(context);
    final loading = ref.watch(pwfComplaintSubmitControllerProvider).isLoading;

    return SingleChildScrollView(
      child: PwfSectionCard(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _TitleRow(
                icon: Icons.edit_note_rounded,
                title: s.t('complaints.tab.new'),
              ),
              const SizedBox(height: 24),

              // Row: type + department
              LayoutBuilder(
                builder: (context, c) {
                  final isWide = c.maxWidth >= 700;
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      SizedBox(
                        width: isWide ? (c.maxWidth - 16) / 2 : c.maxWidth,
                        child: DropdownButtonFormField<PwfComplaintType>(
                          value: _type,
                          items: [
                            for (final t in PwfComplaintType.values)
                              DropdownMenuItem(
                                value: t,
                                child: Text(_typeLabel(context, t)),
                              ),
                          ],
                          onChanged: loading
                              ? null
                              : (v) => setState(() => _type = v),
                          decoration: InputDecoration(
                            labelText: s.t('complaints.form.messageType'),
                            hintText: s.t('complaints.form.messageType.hint'),
                            prefixIcon: const Icon(Icons.category_rounded),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: isWide ? (c.maxWidth - 16) / 2 : c.maxWidth,
                        child: DropdownButtonFormField<PwfComplaintDepartment>(
                          value: _dept,
                          items: [
                            for (final d in PwfComplaintDepartment.values)
                              DropdownMenuItem(
                                value: d,
                                child: Text(_deptLabel(context, d)),
                              ),
                          ],
                          onChanged: loading
                              ? null
                              : (v) => setState(() => _dept = v),
                          decoration: InputDecoration(
                            labelText: s.t('complaints.form.department'),
                            hintText: s.t('complaints.form.department.hint'),
                            prefixIcon: const Icon(Icons.apartment_rounded),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _subjectCtrl,
                enabled: !loading,
                validator: PwfComplaintsValidators.requiredField(context),
                decoration: InputDecoration(
                  labelText: s.t('complaints.form.subject'),
                  hintText: s.t('complaints.form.subject.hint'),
                  prefixIcon: const Icon(Icons.title_rounded),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _detailsCtrl,
                enabled: !loading,
                maxLines: 7,
                validator: PwfComplaintsValidators.requiredField(context),
                decoration: InputDecoration(
                  labelText: s.t('complaints.form.details'),
                  hintText: s.t('complaints.form.details.hint'),
                  alignLabelWithHint: true,
                  prefixIcon: const Icon(Icons.description_rounded),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Attachments
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Text(
                  s.t('complaints.form.attachments'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0D3C61),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: loading ? null : () => _pickFiles(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 28,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE6E6E6)),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.cloud_upload_rounded,
                        size: 28,
                        color: Color(0xFF0D3C61),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        s.t('complaints.upload.title'),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        s.t('complaints.upload.max'),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF777777),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_files.isNotEmpty) ...[
                const SizedBox(height: 12),
                PwfUploadedFilesList(
                  files: _files,
                  onRemove: (f) => setState(() => _files.remove(f)),
                ),
              ],

              const SizedBox(height: 20),

              // Contact row
              LayoutBuilder(
                builder: (context, c) {
                  final isWide = c.maxWidth >= 700;
                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      SizedBox(
                        width: isWide ? (c.maxWidth - 16) / 2 : c.maxWidth,
                        child: TextFormField(
                          controller: _nameCtrl,
                          enabled: !loading,
                          decoration: InputDecoration(
                            labelText: s.t('complaints.form.name'),
                            prefixIcon: const Icon(Icons.person_rounded),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: isWide ? (c.maxWidth - 16) / 2 : c.maxWidth,
                        child: TextFormField(
                          controller: _emailCtrl,
                          enabled: !loading,
                          validator: PwfComplaintsValidators.email(context),
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: s.t('complaints.form.email'),
                            hintText: s.t('complaints.form.email.hint'),
                            prefixIcon: const Icon(Icons.email_rounded),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: isWide ? (c.maxWidth - 16) / 2 : c.maxWidth,
                        child: TextFormField(
                          controller: _phoneCtrl,
                          enabled: !loading,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: s.t('complaints.form.phone'),
                            hintText: s.t('complaints.form.phone.hint'),
                            prefixIcon: const Icon(Icons.phone_rounded),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: loading ? null : () => _submit(context),
                  icon: loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send_rounded),
                  label: Text(
                    s.t('complaints.btn.send'),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D3C61),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
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

class _TitleRow extends StatelessWidget {
  final IconData icon;
  final String title;

  const _TitleRow({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF0D3C61)),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0D3C61),
          ),
        ),
      ],
    );
  }
}
