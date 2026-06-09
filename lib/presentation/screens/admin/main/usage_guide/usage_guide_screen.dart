import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:waqf/app/routing/app_routes.dart';
import 'package:waqf/core/access/access_profile.dart';
import 'package:waqf/core/access/access_provider.dart';
import 'package:waqf/core/access/admin_route_access_contract.dart';
import 'package:waqf/core/access/user_dashboard_contract.dart';
import 'package:waqf/core/enums/enums.dart';
import 'package:waqf/presentation/providers/user_dashboard_provider.dart';

class UsageGuideScreen extends ConsumerStatefulWidget {
  const UsageGuideScreen({super.key});

  @override
  ConsumerState<UsageGuideScreen> createState() => _UsageGuideScreenState();
}

class _UsageGuideScreenState extends ConsumerState<UsageGuideScreen> {
  List<_GuideDoc> _docs = const [];
  bool _isLoading = true;
  String? _error;
  String _query = '';
  String _category = 'all';
  String? _selectedId;

  @override
  void initState() {
    super.initState();
    _loadGuideBundle();
  }

  Future<void> _loadGuideBundle() async {
    try {
      final manifestRaw = await rootBundle.loadString(
        'assets/docs/usage_guide_manifest.json',
      );
      final manifest = jsonDecode(manifestRaw) as Map<String, dynamic>;
      final docsRaw = (manifest['docs'] as List<dynamic>? ?? const []);

      final loadedDocs = <_GuideDoc>[];
      for (final item in docsRaw) {
        final map = item as Map<String, dynamic>;
        final assetPath = (map['assetPath'] ?? '').toString();
        final content = await rootBundle.loadString(assetPath);
        loadedDocs.add(
          _GuideDoc(
            id: (map['id'] ?? '').toString(),
            title: (map['title'] ?? '').toString(),
            subtitle: (map['subtitle'] ?? '').toString(),
            assetPath: assetPath,
            category: (map['category'] ?? 'general').toString(),
            audience: (map['audience'] ?? '').toString(),
            systemKey: (map['systemKey'] ?? '').toString(),
            accessScope: (map['accessScope'] ?? '').toString(),
            tags: (map['tags'] as List<dynamic>? ?? const [])
                .map((e) => e.toString())
                .toList(growable: false),
            content: content,
          ),
        );
      }

      if (!mounted) return;
      setState(() {
        _docs = loadedDocs;
        _selectedId = loadedDocs.isEmpty ? null : loadedDocs.first.id;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = _friendlyGuideError(e);
        _isLoading = false;
      });
    }
  }

  String _friendlyGuideError(Object error) {
    final raw = error.toString();
    if (raw.contains('usage_guide_manifest.json')) {
      return 'تعذر تحميل فهرس دليل الاستخدام. تأكد من وجود assets/docs/usage_guide_manifest.json ضمن أصول التطبيق ثم أعد البناء.';
    }
    if (raw.contains('Unable to load asset')) {
      return 'تعذر تحميل أحد مستندات دليل الاستخدام. تأكد من وجود جميع ملفات الدليل المشار إليها في الفهرس.';
    }
    return 'تعذر تحميل دليل الاستخدام حاليًا. راجع إعدادات الأصول ثم أعد المحاولة.';
  }

  List<_GuideDoc> _scopedDocsFor(
    AccessProfile? profile,
    UserDashboardContract? contract,
  ) {
    return _docs
        .where((doc) => _canViewDoc(doc, profile, contract))
        .toList(growable: false);
  }

  List<_GuideDoc> _filteredDocsFor(
    AccessProfile? profile,
    UserDashboardContract? contract,
  ) {
    final query = _query.trim().toLowerCase();
    return _scopedDocsFor(profile, contract)
        .where((doc) {
          final matchesCategory =
              _category == 'all' || doc.category == _category;
          if (!matchesCategory) return false;
          if (query.isEmpty) return true;
          final haystack = [
            doc.title,
            doc.subtitle,
            doc.audience,
            doc.systemKey,
            ...doc.tags,
            doc.content,
          ].join(' ').toLowerCase();
          return haystack.contains(query);
        })
        .toList(growable: false);
  }

  _GuideDoc? _selectedDocFor(
    AccessProfile? profile,
    UserDashboardContract? contract,
  ) {
    final filtered = _filteredDocsFor(profile, contract);
    if (filtered.isEmpty) return null;
    return filtered.firstWhere(
      (doc) => doc.id == _selectedId,
      orElse: () => filtered.first,
    );
  }

  bool _canViewDoc(
    _GuideDoc doc,
    AccessProfile? profile,
    UserDashboardContract? contract,
  ) {
    final active = profile?.isActive ?? false;
    if (!active) return false;
    if (profile?.isSuperuser == true) return true;

    final hasOperationalAccess = _hasOperationalGuideAccess(profile, contract);
    final accessScope = doc.accessScope.trim();
    if (accessScope == 'active_admin_common') return true;
    if (accessScope == 'operational_or_superuser_only')
      return hasOperationalAccess;

    switch (doc.id) {
      case 'platform_general':
      case 'assistant_binding':
        return true;
      case 'role_based':
      case 'system_unit_permission':
        return hasOperationalAccess;
    }

    final normalizedSystem = doc.systemKey.trim();
    if (normalizedSystem.isEmpty) return true;
    if (normalizedSystem == 'assistant') return true;
    if (normalizedSystem == 'multi-system') return hasOperationalAccess;
    if (normalizedSystem == 'platformAdmin') {
      return hasOperationalAccess ||
          (profile?.canAccessSystem(SystemKey.platformAdmin) ?? false);
    }
    return hasOperationalAccess;
  }

  bool _hasOperationalGuideAccess(
    AccessProfile? profile,
    UserDashboardContract? contract,
  ) {
    if (profile == null || !profile.isActive) return false;
    if (profile.isSuperuser || profile.canManagePlatformAdmin()) return true;
    if (profile.roles.isNotEmpty) return true;
    if (profile.permissions.values.any((permissions) => permissions.isNotEmpty))
      return true;
    if ((contract?.visibleSystemsCount ?? 0) > 0) return true;
    if ((contract?.adminTools.isNotEmpty ?? false)) return true;
    return false;
  }

  bool _canOpenTasks(AccessProfile? profile) {
    if (profile == null || !profile.isActive) return false;
    final contract = AdminRouteAccessContracts.contractFor(
      AppRoutes.adminTasks,
    );
    return contract?.allows(profile) ?? profile.isSuperuser;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accessProfileAsync = ref.watch(accessProfileProvider);
    final dashboardContractAsync = ref.watch(
      currentUserDashboardContractProvider,
    );
    final profile = accessProfileAsync.valueOrNull;
    final dashboardContract = dashboardContractAsync.valueOrNull;
    final scopedDocs = _scopedDocsFor(profile, dashboardContract);

    final accessLoading =
        accessProfileAsync.isLoading || dashboardContractAsync.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: _isLoading || accessLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? _GuideErrorState(message: _error!, onRetry: _loadGuideBundle)
            : Column(
                children: [
                  _GuideHeader(
                    docsCount: scopedDocs.length,
                    scopeLabel: _guideScopeLabel(profile, dashboardContract),
                    onOpenAssistant: () => context.go(AppRoutes.adminAssistant),
                    onOpenTasks: _canOpenTasks(profile)
                        ? () => context.go(AppRoutes.adminTasks)
                        : null,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth >= 1120;
                          final sidebar = _buildSidebar(
                            theme,
                            profile,
                            dashboardContract,
                          );
                          final content = _buildContent(
                            theme,
                            profile,
                            dashboardContract,
                          );
                          final availableHeight = constraints.hasBoundedHeight
                              ? constraints.maxHeight
                              : MediaQuery.sizeOf(context).height - 160;
                          if (isWide) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 360,
                                  height: availableHeight,
                                  child: sidebar,
                                ),
                                const SizedBox(width: 16),
                                Expanded(child: content),
                              ],
                            );
                          }
                          final sidebarHeight = (availableHeight * 0.42).clamp(
                            260.0,
                            380.0,
                          );
                          return Column(
                            children: [
                              SizedBox(height: sidebarHeight, child: sidebar),
                              const SizedBox(height: 16),
                              Expanded(child: content),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  String _guideScopeLabel(
    AccessProfile? profile,
    UserDashboardContract? contract,
  ) {
    if (profile?.isSuperuser == true)
      return 'الدليل الكامل حسب صلاحية superuser';
    if (_hasOperationalGuideAccess(profile, contract))
      return 'الدليل معروض حسب أنظمتك وصلاحياتك';
    return 'دليل إرشادي محدود حسب صلاحياتك الحالية';
  }

  Widget _buildSidebar(
    ThemeData theme,
    AccessProfile? profile,
    UserDashboardContract? contract,
  ) {
    final filtered = _filteredDocsFor(profile, contract);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'فهرس الدليل',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'مرجع حي للمنصة، حسب الدور، النظام، والوحدة، مع ربط مباشر بمسار المهام.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          _GuideScopeNotice(
            label: _guideScopeLabel(profile, contract),
            visibleDocs: _scopedDocsFor(profile, contract).length,
            totalDocs: _docs.length,
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              hintText: 'ابحث داخل الدليل...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
              ),
            ),
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildCategoryChip('all', 'الكل'),
              _buildCategoryChip('general', 'عام'),
              _buildCategoryChip('roles', 'حسب الدور'),
              _buildCategoryChip('systems', 'حسب النظام'),
              _buildCategoryChip('tasks', 'المهام'),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text('لا توجد نتائج مطابقة ضمن الدليل الحالي.'),
                  )
                : ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final doc = filtered[index];
                      final selected =
                          doc.id == _selectedDocFor(profile, contract)?.id;
                      return InkWell(
                        onTap: () => setState(() => _selectedId = doc.id),
                        borderRadius: BorderRadius.circular(16),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFFEEF5FB)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selected
                                  ? const Color(0xFF0F4C81)
                                  : const Color(0xFFE5E7EB),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doc.title,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: selected
                                      ? const Color(0xFF0F4C81)
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                doc.subtitle,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFF6B7280),
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  _MiniTag(label: doc.audience),
                                  if (doc.systemKey.isNotEmpty)
                                    _MiniTag(label: doc.systemKey),
                                  ...doc.tags
                                      .take(2)
                                      .map((tag) => _MiniTag(label: tag)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String value, String label) {
    final selected = _category == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _category = value),
      selectedColor: const Color(0xFFE8F0FE),
      labelStyle: TextStyle(
        color: selected ? const Color(0xFF0F4C81) : const Color(0xFF374151),
        fontWeight: FontWeight.w700,
      ),
      side: const BorderSide(color: Color(0xFFE5E7EB)),
    );
  }

  Widget _buildContent(
    ThemeData theme,
    AccessProfile? profile,
    UserDashboardContract? contract,
  ) {
    final doc = _selectedDocFor(profile, contract);
    if (doc == null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: const Center(
          child: Text('اختر مرجعًا من الفهرس لعرض محتوى الدليل.'),
        ),
      );
    }

    final lines = doc.content.split('\n');
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F4C81), Color(0xFF154B79)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              runSpacing: 12,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      doc.subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _HeaderPill(label: doc.audience),
                    if (doc.systemKey.isNotEmpty)
                      _HeaderPill(label: doc.systemKey),
                    _HeaderPill(
                      label: doc.assetPath.replaceFirst('assets/docs/', ''),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Scrollbar(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: lines.length,
                itemBuilder: (context, index) {
                  final line = lines[index].trimRight();
                  if (line.trim().isEmpty) return const SizedBox(height: 10);
                  if (line.startsWith('# ')) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: SelectableText(
                        line.substring(2),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F4C81),
                        ),
                      ),
                    );
                  }
                  if (line.startsWith('## ')) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 10),
                      child: SelectableText(
                        line.substring(3),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF7A1F2B),
                        ),
                      ),
                    );
                  }
                  if (line.startsWith('### ')) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 6, bottom: 8),
                      child: SelectableText(
                        line.substring(4),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    );
                  }
                  if (line.startsWith('- ')) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 7),
                            child: Icon(
                              Icons.circle,
                              size: 8,
                              color: Color(0xFF0F4C81),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SelectableText(
                              line.substring(2),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                height: 1.7,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SelectableText(
                      line,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.8,
                        color: const Color(0xFF111827),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideDoc {
  const _GuideDoc({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.assetPath,
    required this.category,
    required this.audience,
    required this.systemKey,
    required this.accessScope,
    required this.tags,
    required this.content,
  });

  final String id;
  final String title;
  final String subtitle;
  final String assetPath;
  final String category;
  final String audience;
  final String systemKey;
  final String accessScope;
  final List<String> tags;
  final String content;
}

class _GuideHeader extends StatelessWidget {
  const _GuideHeader({
    required this.docsCount,
    required this.scopeLabel,
    required this.onOpenAssistant,
    required this.onOpenTasks,
  });

  final int docsCount;
  final String scopeLabel;
  final VoidCallback onOpenAssistant;
  final VoidCallback? onOpenTasks;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 12,
        spacing: 12,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'دليل الاستخدام المؤسسي الحي',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F4C81),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'مرجع تشغيلي موحد للمنصة، مع ربط مباشر بالأدوار، لوحة العمل، المساعد الداخلي، ومسار نظام المهام. $scopeLabel',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF6B7280),
                  height: 1.5,
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _TopBarPill(label: '$docsCount مستندات حية'),
              if (onOpenTasks != null)
                FilledButton.icon(
                  onPressed: onOpenTasks,
                  icon: const Icon(Icons.task_alt_outlined),
                  label: const Text('فتح نظام المهام'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF7A1F2B),
                  ),
                ),
              OutlinedButton.icon(
                onPressed: onOpenAssistant,
                icon: const Icon(Icons.assistant_rounded),
                label: const Text('المساعد الداخلي'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GuideScopeNotice extends StatelessWidget {
  const _GuideScopeNotice({
    required this.label,
    required this.visibleDocs,
    required this.totalDocs,
  });

  final String label;
  final int visibleDocs;
  final int totalDocs;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lock_outline_rounded,
            color: Color(0xFF92400E),
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label — المستندات المتاحة: $visibleDocs من $totalDocs.',
              style: const TextStyle(
                color: Color(0xFF92400E),
                fontWeight: FontWeight.w700,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBarPill extends StatelessWidget {
  const _TopBarPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F0FE),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF0F4C81),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  const _MiniTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    if (label.trim().isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0F4C81),
        ),
      ),
    );
  }
}

class _GuideErrorState extends StatelessWidget {
  const _GuideErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Color(0xFFB22222),
                ),
                const SizedBox(height: 12),
                const Text(
                  'تعذر تحميل دليل الاستخدام',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(height: 1.6),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => onRetry(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
