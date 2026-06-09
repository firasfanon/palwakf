part of 'pwf_public_pages_admin_screens.dart';

class _AdminTextField extends StatelessWidget {
  const _AdminTextField({
    required this.controller,
    required this.label,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: maxLines > 1 ? maxLines : 1,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }
}

class _PreviewBox extends StatelessWidget {
  const _PreviewBox({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(_excerpt(body), style: const TextStyle(height: 1.7)),
        ],
      ),
    );
  }
}

String _excerpt(String text) {
  final value = text.trim();
  if (value.isEmpty) return 'لا يوجد محتوى محفوظ حاليًا.';
  if (value.length <= 260) return value;
  return '${value.substring(0, 260)}...';
}

String _safeText(String value) {
  final text = value.trim();
  return text.isEmpty ? '—' : text;
}

String _fmtDate(DateTime? value) {
  if (value == null) return 'غير متوفر';
  final d = value.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
}

class _ContactChannelsAdminTab extends ConsumerStatefulWidget {
  const _ContactChannelsAdminTab();

  @override
  ConsumerState<_ContactChannelsAdminTab> createState() =>
      _ContactChannelsAdminTabState();
}

class _ContactChannelsAdminTabState
    extends ConsumerState<_ContactChannelsAdminTab> {
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _workingDaysCtrl;
  late final TextEditingController _workingHoursCtrl;

  bool _showPhone = true;
  bool _showEmail = true;
  bool _showAddress = true;
  bool _showWorkingHours = true;
  bool _isSaving = false;
  bool _dirty = false;
  String? _revision;
  String? _message;

  @override
  void initState() {
    super.initState();
    _phoneCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _addressCtrl = TextEditingController();
    _workingDaysCtrl = TextEditingController();
    _workingHoursCtrl = TextEditingController();
    for (final controller in [
      _phoneCtrl,
      _emailCtrl,
      _addressCtrl,
      _workingDaysCtrl,
      _workingHoursCtrl,
    ]) {
      controller.addListener(() {
        if (!_dirty) setState(() => _dirty = true);
      });
    }
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _workingDaysCtrl.dispose();
    _workingHoursCtrl.dispose();
    super.dispose();
  }

  void _hydrate(FooterSettings settings) {
    final revision = '${settings.id}:${settings.updatedAt.toIso8601String()}';
    if (_revision == revision || _dirty) return;
    _revision = revision;
    _phoneCtrl.text = settings.contactPhone ?? '';
    _emailCtrl.text = settings.contactEmail ?? '';
    _addressCtrl.text = settings.contactAddress ?? '';
    _workingDaysCtrl.text = settings.workingDays;
    _workingHoursCtrl.text = settings.workingHours;
    _showPhone = settings.showPhone;
    _showEmail = settings.showEmail;
    _showAddress = settings.showAddress;
    _showWorkingHours = settings.showWorkingHours;
    _message = null;
  }

  Future<void> _save(FooterSettings current) async {
    setState(() {
      _isSaving = true;
      _message = null;
    });
    try {
      final repo = ref.read(footerRepositoryProvider);
      final homeUnitId = await ref.read(unitIdBySlugProvider('home').future);
      final updated = current.copyWith(
        contactPhone: _phoneCtrl.text.trim(),
        contactEmail: _emailCtrl.text.trim(),
        contactAddress: _addressCtrl.text.trim(),
        workingDays: _workingDaysCtrl.text.trim(),
        workingHours: _workingHoursCtrl.text.trim(),
        showPhone: _showPhone,
        showEmail: _showEmail,
        showAddress: _showAddress,
        showWorkingHours: _showWorkingHours,
        updatedAt: DateTime.now(),
      );
      await repo.saveFooterSettingsForUnit(updated, unitId: homeUnitId);
      ref.invalidate(editableFooterSettingsProvider('home'));
      ref.invalidate(publicFooterSettingsProvider('home'));
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _dirty = false;
        _message = 'تم حفظ بيانات التواصل بنجاح.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _message = 'تعذر حفظ بيانات التواصل: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final footerAsync = ref.watch(editableFooterSettingsProvider('home'));
    final current = footerAsync.valueOrNull;
    if (current != null) {
      _hydrate(current);
    }

    return footerAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, _) => PwfAdminSectionCard(
        title: 'تعذر قراءة بيانات التواصل',
        subtitle: 'حدث خطأ أثناء قراءة السجل الفعلي من footer_settings.',
        child: Text(error.toString()),
      ),
      data: (settings) => Column(
        children: [
          PwfAdminSectionCard(
            title: 'بيانات التواصل الفعلية',
            subtitle:
                'هذا التبويب يحرر بيانات التواصل التي تعتمد عليها صفحة اتصل بنا فعليًا عبر footer_settings.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: _isSaving ? null : () => _save(settings),
                      icon: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(
                        _isSaving ? 'جارٍ الحفظ...' : 'حفظ بيانات التواصل',
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => context.go(AppRoutes.contact),
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: const Text('فتح الصفحة العامة'),
                    ),
                  ],
                ),
                if (_message != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _message!,
                    style: TextStyle(
                      color: _message!.startsWith('تم')
                          ? const Color(0xFF166534)
                          : const Color(0xFFB91C1C),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                _AdminTextField(controller: _phoneCtrl, label: 'الهاتف الرسمي'),
                const SizedBox(height: 12),
                _AdminTextField(
                  controller: _emailCtrl,
                  label: 'البريد الإلكتروني الرسمي',
                ),
                const SizedBox(height: 12),
                _AdminTextField(controller: _addressCtrl, label: 'العنوان'),
                const SizedBox(height: 12),
                _AdminTextField(
                  controller: _workingDaysCtrl,
                  label: 'أيام الدوام',
                ),
                const SizedBox(height: 12),
                _AdminTextField(
                  controller: _workingHoursCtrl,
                  label: 'ساعات الدوام',
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _ToggleChip(
                      label: 'إظهار الهاتف',
                      value: _showPhone,
                      onChanged: (v) => setState(() {
                        _showPhone = v;
                        _dirty = true;
                      }),
                    ),
                    _ToggleChip(
                      label: 'إظهار البريد',
                      value: _showEmail,
                      onChanged: (v) => setState(() {
                        _showEmail = v;
                        _dirty = true;
                      }),
                    ),
                    _ToggleChip(
                      label: 'إظهار العنوان',
                      value: _showAddress,
                      onChanged: (v) => setState(() {
                        _showAddress = v;
                        _dirty = true;
                      }),
                    ),
                    _ToggleChip(
                      label: 'إظهار الدوام',
                      value: _showWorkingHours,
                      onChanged: (v) => setState(() {
                        _showWorkingHours = v;
                        _dirty = true;
                      }),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          PwfAdminSectionCard(
            title: 'الربط الحاكم',
            subtitle:
                'الصفحة العامة الهجينة تستخدم site_pages للمحتوى التحريري، وfooter_settings للبيانات الرسمية الفعلية.',
            child: Column(
              children: [
                PwfAdminInfoRow(
                  label: 'مصدر المحتوى التعريفي',
                  value: 'public.site_pages / slug=contact',
                ),
                PwfAdminInfoRow(
                  label: 'مصدر بيانات التواصل',
                  value: 'public.footer_settings',
                ),
                PwfAdminInfoRow(
                  label: 'نطاق التحرير الحالي',
                  value: 'home / global public scope',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FormerMinistersAdminTab extends ConsumerStatefulWidget {
  const _FormerMinistersAdminTab();

  @override
  ConsumerState<_FormerMinistersAdminTab> createState() =>
      _FormerMinistersAdminTabState();
}

class _FormerMinistersAdminTabState
    extends ConsumerState<_FormerMinistersAdminTab> {
  bool _busy = false;
  String? _message;

  Future<void> _openEditor([PwfFormerMinister? item]) async {
    final result = await showDialog<PwfFormerMinister>(
      context: context,
      builder: (context) => _FormerMinisterEditorDialog(initial: item),
    );
    if (result == null) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final repo = ref.read(pwfFormerMinistersRepositoryProvider);
      final homeUnitId = await ref.read(unitIdBySlugProvider('home').future);
      await repo.upsertMinister(result, unitId: homeUnitId);
      ref.invalidate(editablePwfFormerMinistersProvider('home'));
      ref.invalidate(pwfFormerMinistersProvider('home'));
      if (!mounted) return;
      setState(() {
        _busy = false;
        _message = item == null
            ? 'تمت إضافة السجل التاريخي بنجاح.'
            : 'تم تحديث السجل التاريخي بنجاح.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _message = 'تعذر حفظ السجل: $e';
      });
    }
  }

  Future<void> _delete(PwfFormerMinister item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف السجل التاريخي'),
        content: Text(
          'سيتم حذف سجل ${_displayName(item, true)} نهائيًا من جدول الوزراء السابقين.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final repo = ref.read(pwfFormerMinistersRepositoryProvider);
      await repo.deleteMinister(item.id);
      ref.invalidate(editablePwfFormerMinistersProvider('home'));
      ref.invalidate(pwfFormerMinistersProvider('home'));
      if (!mounted) return;
      setState(() {
        _busy = false;
        _message = 'تم حذف السجل التاريخي بنجاح.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _message = 'تعذر حذف السجل: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final recordsAsync = ref.watch(editablePwfFormerMinistersProvider('home'));
    return recordsAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, _) => PwfAdminSectionCard(
        title: 'تعذر قراءة السجل التاريخي',
        subtitle: 'حدث خطأ أثناء قراءة جدول former_ministers.',
        child: Text(error.toString()),
      ),
      data: (items) => Column(
        children: [
          PwfAdminSectionCard(
            title: 'السجل التاريخي للوزراء السابقين',
            subtitle:
                'هذا التبويب يدير البيانات الفعلية القادمة من جدول former_ministers، وليس مجرد محتوى تحريري في site_pages.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: _busy ? null : () => _openEditor(),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('إضافة سجل جديد'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => context.go(AppRoutes.formerMinisters),
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: const Text('فتح الصفحة العامة'),
                    ),
                  ],
                ),
                if (_message != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _message!,
                    style: TextStyle(
                      color: _message!.startsWith('تم')
                          ? const Color(0xFF166534)
                          : const Color(0xFFB91C1C),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                if (items.isEmpty)
                  const Text(
                    'لا توجد سجلات محفوظة حاليًا. أضف أول سجل تاريخي من هنا.',
                  ),
                if (items.isNotEmpty)
                  Column(
                    children: items
                        .map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFE5E7EB),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _displayName(item, true),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      if (item.isCurrent)
                                        const PwfAdminBadge(
                                          label: 'حالي/أحدث',
                                          color: Color(0xFFE8F5E9),
                                          textColor: Color(0xFF166534),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  PwfAdminInfoRow(
                                    label: 'الفترة',
                                    value: _tenureLabel(item, true),
                                  ),
                                  PwfAdminInfoRow(
                                    label: 'الترتيب',
                                    value: '${item.sortOrder}',
                                  ),
                                  PwfAdminInfoRow(
                                    label: 'الحالة',
                                    value: item.isActive ? 'نشط' : 'غير نشط',
                                  ),
                                  if (_displayNotes(
                                    item,
                                    true,
                                  ).trim().isNotEmpty)
                                    PwfAdminInfoRow(
                                      label: 'ملاحظات',
                                      value: _displayNotes(item, true),
                                    ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 8,
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: _busy
                                            ? null
                                            : () => _openEditor(item),
                                        icon: const Icon(Icons.edit_outlined),
                                        label: const Text('تعديل'),
                                      ),
                                      OutlinedButton.icon(
                                        onPressed: _busy
                                            ? null
                                            : () => _delete(item),
                                        icon: const Icon(Icons.delete_outline),
                                        label: const Text('حذف'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(growable: false),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const PwfAdminSectionCard(
            title: 'الربط الحاكم',
            subtitle:
                'صفحة الوزراء السابقين صفحة Hybrid: intro من site_pages + السجل التاريخي من former_ministers.',
            child: Column(
              children: [
                PwfAdminInfoRow(
                  label: 'المحتوى التحريري',
                  value: 'public.site_pages / slug=former-ministers',
                ),
                PwfAdminInfoRow(
                  label: 'السجل التاريخي',
                  value: 'public.former_ministers',
                ),
                PwfAdminInfoRow(
                  label: 'نوع الصفحة',
                  value: 'Hybrid page with real historical dataset',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FormerMinisterEditorDialog extends StatefulWidget {
  const _FormerMinisterEditorDialog({this.initial});

  final PwfFormerMinister? initial;

  @override
  State<_FormerMinisterEditorDialog> createState() =>
      _FormerMinisterEditorDialogState();
}

class _FormerMinisterEditorDialogState
    extends State<_FormerMinisterEditorDialog> {
  late final TextEditingController _nameArCtrl;
  late final TextEditingController _nameEnCtrl;
  late final TextEditingController _notesArCtrl;
  late final TextEditingController _notesEnCtrl;
  late final TextEditingController _sortCtrl;
  late final TextEditingController _startCtrl;
  late final TextEditingController _endCtrl;
  late bool _isCurrent;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    final item = widget.initial;
    _nameArCtrl = TextEditingController(text: item?.fullNameAr ?? '');
    _nameEnCtrl = TextEditingController(text: item?.fullNameEn ?? '');
    _notesArCtrl = TextEditingController(text: item?.notesAr ?? '');
    _notesEnCtrl = TextEditingController(text: item?.notesEn ?? '');
    _sortCtrl = TextEditingController(text: '${item?.sortOrder ?? 0}');
    _startCtrl = TextEditingController(text: _dateForField(item?.startDate));
    _endCtrl = TextEditingController(text: _dateForField(item?.endDate));
    _isCurrent = item?.isCurrent ?? false;
    _isActive = item?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameArCtrl.dispose();
    _nameEnCtrl.dispose();
    _notesArCtrl.dispose();
    _notesEnCtrl.dispose();
    _sortCtrl.dispose();
    _startCtrl.dispose();
    _endCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initial == null ? 'إضافة وزير سابق' : 'تعديل سجل وزير سابق',
      ),
      content: SizedBox(
        width: 680,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _AdminTextField(controller: _nameArCtrl, label: 'الاسم العربي'),
              const SizedBox(height: 10),
              _AdminTextField(
                controller: _nameEnCtrl,
                label: 'الاسم الإنجليزي',
              ),
              const SizedBox(height: 10),
              _AdminTextField(
                controller: _startCtrl,
                label: 'تاريخ البداية (YYYY-MM-DD)',
              ),
              const SizedBox(height: 10),
              _AdminTextField(
                controller: _endCtrl,
                label: 'تاريخ النهاية (YYYY-MM-DD)',
              ),
              const SizedBox(height: 10),
              _AdminTextField(controller: _sortCtrl, label: 'الترتيب'),
              const SizedBox(height: 10),
              _AdminTextField(
                controller: _notesArCtrl,
                label: 'ملاحظات عربية',
                maxLines: 4,
              ),
              const SizedBox(height: 10),
              _AdminTextField(
                controller: _notesEnCtrl,
                label: 'English notes',
                maxLines: 4,
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                value: _isCurrent,
                onChanged: (v) => setState(() => _isCurrent = v ?? false),
                contentPadding: EdgeInsets.zero,
                title: const Text('سجل حالي/الأحدث'),
              ),
              CheckboxListTile(
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v ?? true),
                contentPadding: EdgeInsets.zero,
                title: const Text('نشط للنشر العام'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        FilledButton(
          onPressed: () {
            final item =
                (widget.initial ??
                        const PwfFormerMinister(
                          id: '',
                          fullNameAr: '',
                          fullNameEn: '',
                          notesAr: '',
                          notesEn: '',
                        ))
                    .copyWith(
                      fullNameAr: _nameArCtrl.text.trim(),
                      fullNameEn: _nameEnCtrl.text.trim(),
                      notesAr: _notesArCtrl.text.trim(),
                      notesEn: _notesEnCtrl.text.trim(),
                      startDate: _parseDate(_startCtrl.text),
                      clearStartDate: _startCtrl.text.trim().isEmpty,
                      endDate: _parseDate(_endCtrl.text),
                      clearEndDate: _endCtrl.text.trim().isEmpty,
                      sortOrder: int.tryParse(_sortCtrl.text.trim()) ?? 0,
                      isCurrent: _isCurrent,
                      isActive: _isActive,
                    );
            Navigator.of(context).pop(item);
          },
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: value,
      label: Text(label),
      onSelected: onChanged,
    );
  }
}

DateTime? _parseDate(String value) {
  final text = value.trim();
  if (text.isEmpty) return null;
  return DateTime.tryParse(text);
}

String _dateForField(DateTime? value) =>
    value == null ? '' : value.toIso8601String().split('T').first;

String _displayName(PwfFormerMinister item, bool isAr) {
  final primary = isAr ? item.fullNameAr.trim() : item.fullNameEn.trim();
  final fallback = isAr ? item.fullNameEn.trim() : item.fullNameAr.trim();
  if (primary.isNotEmpty) return primary;
  if (fallback.isNotEmpty) return fallback;
  return isAr ? 'بدون اسم' : 'Unnamed';
}

String _displayNotes(PwfFormerMinister item, bool isAr) {
  final primary = isAr ? item.notesAr.trim() : item.notesEn.trim();
  final fallback = isAr ? item.notesEn.trim() : item.notesAr.trim();
  return primary.isNotEmpty ? primary : fallback;
}

String _tenureLabel(PwfFormerMinister item, bool isAr) {
  String formatDate(DateTime? value) {
    if (value == null) return isAr ? 'غير محدد' : 'Unknown';
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  if (item.startDate == null && item.endDate == null) {
    return isAr ? 'غير محددة' : 'Not specified';
  }
  if (item.startDate != null && item.endDate == null) {
    return isAr
        ? 'من ${formatDate(item.startDate)} حتى الآن'
        : 'From ${formatDate(item.startDate)} to present';
  }
  if (item.startDate == null && item.endDate != null) {
    return isAr
        ? 'حتى ${formatDate(item.endDate)}'
        : 'Until ${formatDate(item.endDate)}';
  }
  return '${formatDate(item.startDate)} — ${formatDate(item.endDate)}';
}

class _ServicesLinksAdminTab extends StatelessWidget {
  const _ServicesLinksAdminTab();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        PwfAdminSectionCard(
          title: 'مصدر الخدمات السريعة',
          subtitle:
              'هذه البطاقات تُغذي صفحة الخدمات العامة مباشرة عبر footer_settings ضمن النطاق العام home، وليست نصًا ثابتًا داخل site_pages.',
          child: Column(
            children: [
              PwfAdminInfoRow(
                label: 'المحتوى التحريري',
                value: 'public.site_pages / slug=services',
              ),
              PwfAdminInfoRow(
                label: 'الخدمات السريعة',
                value: 'public.footer_settings.services_links',
              ),
              PwfAdminInfoRow(
                label: 'النطاق التشغيلي',
                value: 'home / global public scope',
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        ScopedFooterLinksManagementSection(
          mode: ScopedFooterLinksMode.services,
          title: 'الخدمات السريعة',
          description:
              'إدارة روابط وبطاقات الخدمات السريعة التي تظهر داخل صفحة الخدمات العامة والواجهة الرئيسية.',
        ),
      ],
    );
  }
}

class _EServicesPortalAdminTab extends StatelessWidget {
  const _EServicesPortalAdminTab();

  static const List<ScopedCardEditableItem>
  _defaults = <ScopedCardEditableItem>[
    ScopedCardEditableItem(
      icon: 'file_signature',
      title: 'الشكاوى والمتابعة',
      description:
          'تقديم الشكاوى العامة ومتابعة حالتها ضمن واجهة المنصة العامة.',
      linkLabel: 'فتح الخدمة',
      route: AppRoutes.complaints,
    ),
    ScopedCardEditableItem(
      icon: 'credit_card',
      title: 'حاسبة الزكاة',
      description:
          'احتساب الزكاة لأنواع الأموال المختلفة وفق الضوابط الشرعية المعتمدة.',
      linkLabel: 'الانتقال للخدمة',
      route: AppRoutes.zakat,
    ),
    ScopedCardEditableItem(
      icon: 'clock',
      title: 'مواقيت الصلاة',
      description:
          'مواقيت الصلاة واتجاه القبلة وفق المدينة وطريقة الاحتساب المعتمدة.',
      linkLabel: 'عرض المواقيت',
      route: AppRoutes.prayerTimes,
    ),
    ScopedCardEditableItem(
      icon: 'mosque',
      title: 'القرآن الكريم',
      description:
          'قراءة السور والآيات ضمن واجهة منسجمة مع بوابة وزارة الأوقاف.',
      linkLabel: 'فتح الصفحة',
      route: AppRoutes.quran,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        PwfAdminSectionCard(
          title: 'مصدر بوابة الخدمات الإلكترونية',
          subtitle:
              'هذا التبويب يدير البطاقات الفعلية لقسم pwf_eservices_portal التي تظهر داخل صفحتي الخدمات والخدمات الإلكترونية ضمن النطاق العام أو الوحدوي.',
          child: Column(
            children: [
              PwfAdminInfoRow(
                label: 'المحتوى التحريري',
                value: 'public.site_pages / slug=services أو slug=eservices',
              ),
              PwfAdminInfoRow(
                label: 'بطاقات البوابة',
                value:
                    'public.homepage_sections / section=pwf_eservices_portal',
              ),
              PwfAdminInfoRow(
                label: 'نوع الصفحة',
                value: 'Hybrid page with real scoped cards',
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        ScopedCardsSectionManagementSection(
          sectionName: 'pwf_eservices_portal',
          title: 'بوابة الخدمات الإلكترونية',
          description:
              'إدارة بطاقات البوابة الإلكترونية التي تغذي الصفحة الرئيسية وصفحات الخدمات بحسب النطاق الحالي.',
          defaultTitle: 'بوابة الخدمات الإلكترونية',
          defaultSubtitle:
              'خدمات وبطاقات إلكترونية مشتركة تُدار بحسب home أو slug وتُعرض في القسم الخاص ببوابة الخدمات.',
          defaultItems: _defaults,
          publicPreviewRoute: AppRoutes.eservices,
        ),
      ],
    );
  }
}
