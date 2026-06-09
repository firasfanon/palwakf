import 'package:flutter/material.dart';

/// Runtime-facing control page for the database ownership and domain migration
/// program. The page intentionally does not execute SQL from Flutter; it gives
/// admins a precise operational map, execution order, and gate status so the
/// Supabase SQL steps stay auditable and reversible.
class PwfDatabaseDomainMigrationPage extends StatelessWidget {
  const PwfDatabaseDomainMigrationPage({super.key});

  static const _surface = Color(0xFFF8FAFC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          _DatabaseOwnershipPhaseBMediaCenterMegaClosureCard(),
          _HeroCard(),
          SizedBox(height: 18),
          _StateStrip(),
          SizedBox(height: 18),
          _DatabaseOwnershipClosureMasterPackCard(),
          SizedBox(height: 18),
          _DatabaseDependencyRemediationWaveACard(),
          SizedBox(height: 18),
          _DatabaseDependencyWaveAExactBodyReviewGateCard(),
          SizedBox(height: 18),
          _DatabaseDependencyWaveAExactBodyExportReviewIntakeCard(),
          SizedBox(height: 18),
          _DatabaseDependencyWaveASql29CoreRelationHotfixCard(),
          SizedBox(height: 18),
          _DatabaseDependencyWaveAAccessHelpersActualRemediationCard(),
          SizedBox(height: 18),
          _DatabaseDependencyWaveAAccessHelpersPreflightPassedCard(),
          SizedBox(height: 18),
          _DatabaseOwnershipWaveASafeStopCard(),
          SizedBox(height: 18),
          _DatabaseOwnershipPhaseBMediaCenterControlledClosureCard(),
          SizedBox(height: 18),
          _DomainProgressGrid(),
          SizedBox(height: 18),
          _ExecutionOrderCard(),
          SizedBox(height: 18),
          _CandidateMatrixCard(),
          SizedBox(height: 18),
          _RuntimeCertificationGateCard(),
          SizedBox(height: 18),
          _RouteConsoleReroutePlanningGateCard(),
          SizedBox(height: 18),
          _DirectDependencyRemediationPlanCard(),
          SizedBox(height: 18),
          _RouteConsoleEvidenceClosureCard(),
          SizedBox(height: 18),
          _Phase2RbacPlanningGateCard(),
          SizedBox(height: 18),
          _Phase2RbacImplementationCard(),
          SizedBox(height: 18),
          _Phase3CoreAdminAuthPlanningGateCard(),
          SizedBox(height: 18),
          _OwnerWriteRpcDesignGateCard(),
          SizedBox(height: 18),
          _OwnerWriteRpcAuthorizationReviewGateCard(),
          SizedBox(height: 18),
          _OwnerWriteRpcConsolidationGateCard(),
          SizedBox(height: 18),
          _PlatformDevelopment10ConsolidatedGateCard(),
          SizedBox(height: 18),
          _PlatformDevelopment10AAuthorizationTokenGateCard(),
          SizedBox(height: 18),
          _PlatformDevelopment10FNegativeUatGateCard(),
          SizedBox(height: 18),
          _PlatformDevelopment10HActualEvidenceBundleCard(),
          SizedBox(height: 18),
          _PlatformDevelopment10IActualNegativeUatResultCard(),
          SizedBox(height: 18),
          _PlatformDevelopment10J0ASiteContentAdapterCompileFixCard(),
          SizedBox(height: 18),
          _PlatformDevelopment10J0DObservability404FixCard(),
          SizedBox(height: 18),
          _SafetyRulesCard(),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Color(0xFF0F4C81), Color(0xFF0B1220)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.account_tree_rounded,
              color: Color(0xFF0F4C81),
              size: 38,
            ),
          ),
          const SizedBox(width: 18),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'برنامج ضبط ملكية public schema وبوابة اعتماد runtime',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'مساحة متابعة تشغيلية للتمييز بين ما أُنجز فعليًا، وما هو قيد الفحص، وما لا يزال ممنوع التنفيذ. هذه الصفحة تضبط مسار N2.36 وتمنع الخلط بين الوحدات، نقل الجداول، وأعمال الأنظمة شبه المستقلة.',
                  style: TextStyle(
                    color: Color(0xFFE2E8F0),
                    height: 1.65,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _HeroBadge(label: 'Dev8 Gate'),
                    _HeroBadge(label: 'dependency/analyzer/browser gate'),
                    _HeroBadge(label: 'production-not-approved'),
                    _HeroBadge(label: 'no waqf_assets mutation'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({required this.label});

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
          fontSize: 12,
        ),
      ),
    );
  }
}

class _StateStrip extends StatelessWidget {
  const _StateStrip();

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: const [
          _StatusBadge(
            icon: Icons.check_circle_rounded,
            label: 'org_units حُلّت: core هو مصدر الحقيقة',
            tone: _BadgeTone.success,
          ),
          _StatusBadge(
            icon: Icons.archive_rounded,
            label: 'كاش الوحدات: quarantine مشروط',
            tone: _BadgeTone.warning,
          ),
          _StatusBadge(
            icon: Icons.public_rounded,
            label: 'public يعود إلى views/RPC فقط',
            tone: _BadgeTone.info,
          ),
          _StatusBadge(
            icon: Icons.block_rounded,
            label: 'locations لا تزال manual review',
            tone: _BadgeTone.danger,
          ),
        ],
      ),
    );
  }
}

class _DomainProgressGrid extends StatelessWidget {
  const _DomainProgressGrid();

  @override
  Widget build(BuildContext context) {
    const cards = [
      _ProgressCard(
        title: 'الوحدات المؤسسية',
        value: 'مغلق جزئيًا',
        description:
            'public.org_units أصبح compatibility view فوق core.org_units. الكاش لم يُعزل بعد.',
        icon: Icons.apartment_rounded,
        tone: _BadgeTone.success,
      ),
      _ProgressCard(
        title: 'site_content',
        value: 'أول تنفيذ',
        description:
            'header_settings و footer_settings هما مرشحا النقل الحقيقي الأول في N2.36.',
        icon: Icons.web_rounded,
        tone: _BadgeTone.info,
      ),
      _ProgressCard(
        title: 'media_center',
        value: 'مؤجل',
        description:
            'لم يبدأ النقل؛ يحتاج matrix منفصلة للـ RLS/RPC/workflow قبل التنفيذ.',
        icon: Icons.perm_media_rounded,
        tone: _BadgeTone.warning,
      ),
      _ProgressCard(
        title: 'platform_services',
        value: 'مؤجل',
        description:
            'services مرشح لاحق؛ servicepoints/providers/types لم تُحسم ملكيتها بعد.',
        icon: Icons.design_services_rounded,
        tone: _BadgeTone.warning,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 980;
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: compact ? 1 : 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: compact ? 3.1 : 2.75,
          children: cards,
        );
      },
    );
  }
}

class _ExecutionOrderCard extends StatelessWidget {
  const _ExecutionOrderCard();

  @override
  Widget build(BuildContext context) {
    const steps = [
      _ExecutionStep(
        index: '53',
        title: 'Preflight read-only',
        body:
            'فحص كاش الوحدات ومرشحي site/media/services بنتيجة واحدة قابلة للنسخ من Supabase.',
      ),
      _ExecutionStep(
        index: '54',
        title: 'Cache quarantine guarded',
        body:
            'ينقل org_units_cache و pwf_org_units_cache إلى legacy_archive فقط إذا نجحت جميع gates.',
      ),
      _ExecutionStep(
        index: '55',
        title: 'Site content first real migration',
        body:
            'ينقل header_settings و footer_settings إلى site_content مع public compatibility views.',
      ),
      _ExecutionStep(
        index: '56',
        title: 'Rollback ready',
        body:
            'يعيد site_content.header/footer إلى public إن احتجنا التراجع قبل التوسع.',
      ),
      _ExecutionStep(
        index: '57',
        title: 'Post-UAT read-only',
        body:
            'يتحقق من العلاقات، column-order compatibility، واستمرار منع أي waqf mutation.',
      ),
    ];

    return _Card(
      title: 'ترتيب التشغيل في Supabase',
      subtitle:
          'لا تشغّل 54 أو 55 قبل قراءة نتيجة 53. SQL 56 للرجوع فقط، وليس ضمن المسار العادي.',
      child: Column(
        children: [
          for (final step in steps) ...[
            step,
            if (step != steps.last) const Divider(height: 22),
          ],
        ],
      ),
    );
  }
}

class _ExecutionStep extends StatelessWidget {
  const _ExecutionStep({
    required this.index,
    required this.title,
    required this.body,
  });

  final String index;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF2F8),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            index,
            style: const TextStyle(
              color: Color(0xFF0F4C81),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                body,
                style: const TextStyle(color: Color(0xFF64748B), height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CandidateMatrixCard extends StatelessWidget {
  const _CandidateMatrixCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'قرار المرشحين في N2.36',
      subtitle:
          'الدفعة لا تعلن انتهاء برنامج النقل؛ هي تنفذ أول حركة آمنة فقط وتؤجل النطاقات المتداخلة.',
      child: Column(
        children: const [
          _CandidateRow(
            objectName: 'public.org_units_cache',
            owner: 'legacy_archive',
            decision: 'quarantine if strict gate passes',
            tone: _BadgeTone.warning,
          ),
          _CandidateRow(
            objectName: 'public.pwf_org_units_cache',
            owner: 'legacy_archive',
            decision: 'quarantine if strict gate passes',
            tone: _BadgeTone.warning,
          ),
          _CandidateRow(
            objectName: 'public.header_settings',
            owner: 'site_content',
            decision: 'first real migration candidate',
            tone: _BadgeTone.info,
          ),
          _CandidateRow(
            objectName: 'public.footer_settings',
            owner: 'site_content',
            decision: 'first real migration candidate',
            tone: _BadgeTone.info,
          ),
          _CandidateRow(
            objectName: 'media tables',
            owner: 'media_center',
            decision: 'defer to Wave C',
            tone: _BadgeTone.warning,
          ),
          _CandidateRow(
            objectName: 'services/servicepoints/providers/types',
            owner: 'platform_services / facilities_module',
            decision: 'manual ownership review',
            tone: _BadgeTone.danger,
          ),
        ],
      ),
    );
  }
}

class _CandidateRow extends StatelessWidget {
  const _CandidateRow({
    required this.objectName,
    required this.owner,
    required this.decision,
    required this.tone,
  });

  final String objectName;
  final String owner;
  final String decision;
  final _BadgeTone tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              objectName,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              owner,
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: _TonePill(label: decision, tone: tone),
            ),
          ),
        ],
      ),
    );
  }
}

class _RuntimeCertificationGateCard extends StatelessWidget {
  const _RuntimeCertificationGateCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'بوابة اعتماد runtime بعد owner-shadow migration',
      subtitle:
          'هذه الدفعة لا تنفذ حذفًا ولا تبديل أسماء. الهدف هو منع الانتقال إلى exact replacement قبل إغلاق dependency-zero وBrowser UAT وAnalyzer.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _StatusBadge(
            icon: Icons.lock_rounded,
            label: 'dependency-zero غير معتمد بعد',
            tone: _BadgeTone.warning,
          ),
          SizedBox(height: 12),
          _RuleLine(
            text:
                'SQL 01 يفحص owner-shadow targets وDB view/function dependencies على جداول public legacy.',
          ),
          _RuleLine(
            text:
                'SQL 02 يصدر قرار gate: missing targets/surfaces/dependencies/analyzer/browser UAT.',
          ),
          _RuleLine(
            text:
                'SQL 03 يثبت مصفوفة Browser/Role/Console UAT للمسارات العامة ولوحة الهجرة.',
          ),
          _RuleLine(
            text:
                'أي dependency أو خطأ Console أحمر يعني بقاء legacy public tables محفوظة دون archive/delete.',
          ),
          _RuleLine(
            text:
                'الاعتماد الإنتاجي، payment workflow، وwaqf_assets خارج نطاق هذه الدفعة.',
          ),
        ],
      ),
    );
  }
}

class _RouteConsoleReroutePlanningGateCard extends StatelessWidget {
  const _RouteConsoleReroutePlanningGateCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'بوابة Route Console وقرار reroute المحكوم',
      subtitle:
          'تم قبول analyzer وChrome startup سابقًا، لكن route-console evidence وdependency-zero ما زالا شرطين حاكمين قبل أي تحويل runtime.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _StatusBadge(
            icon: Icons.route_rounded,
            label: 'runtime reroute غير مصرح',
            tone: _BadgeTone.warning,
          ),
          SizedBox(height: 12),
          _RuleLine(
            text:
                'SQL 05 يصدر مصفوفة المسارات التي يجب فحص Console لها: /home، الأخبار، الإعلانات، الزكاة، gallery، و/admin/database-migration.',
          ),
          _RuleLine(
            text:
                'SQL 06 يجمع dependency-zero gate مع static Flutter dependency snapshot؛ أي direct reference يبقي reroute محظورًا.',
          ),
          _RuleLine(
            text:
                'SQL 07 يثبت تسلسل reroute مستقبلي reversible: wrapper-first، family-by-family، مع rollback flag.',
          ),
          _RuleLine(
            text:
                'SQL 08 يعيد تثبيت السيادة: لا destructive SQL، لا exact replacement، ولا لمس waqf_assets/waqf/awqaf_system.',
          ),
          _RuleLine(
            text:
                'هذه الصفحة لا تنفذ SQL ولا تبدل مصادر البيانات؛ هي تعرض حالة الحظر والتخطيط فقط.',
          ),
        ],
      ),
    );
  }
}

class _DirectDependencyRemediationPlanCard extends StatelessWidget {
  const _DirectDependencyRemediationPlanCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'خطة معالجة الاعتماديات المباشرة قبل أي reroute',
      subtitle:
          'SQL 06 أكد أن dependency-zero غير معتمد: 29 زوج ملف/جدول داخل 16 ملفًا. هذه البطاقة تعرض خطة التصحيح المرحلي ولا تنفذ أي تحويل runtime.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _StatusBadge(
            icon: Icons.block_rounded,
            label: 'dependency-zero غير معتمد',
            tone: _BadgeTone.danger,
          ),
          SizedBox(height: 12),
          _RuleLine(
            text:
                'Phase 1: platform shell/site-content — معالجة 14 اعتمادًا مباشرًا عبر wrappers/RPCs وtyped adapters.',
          ),
          _RuleLine(
            text:
                'Phase 2: platform RBAC/access — معالجة 10 اعتماديات عالية الحساسية مع Role UAT وrollback flag.',
          ),
          _RuleLine(
            text:
                'Phase 3: core linkage — معالجة 5 اعتماديات admin_users/auth عبر core-compatible wrappers دون نقل auth.users.',
          ),
          _RuleLine(
            text:
                'Phase 4: assistant — guard مستقبلي؛ لا توجد أزواج مباشرة حاليًا ضمن scan الأخير، لكن لا يفتح reroute تلقائيًا.',
          ),
          _RuleLine(
            text:
                'Route Console Evidence Pack مطلوب للمسارات العامة والإدارية قبل أي feature flag أو تحويل مصدر بيانات.',
          ),
        ],
      ),
    );
  }
}

class _RouteConsoleEvidenceClosureCard extends StatelessWidget {
  const _RouteConsoleEvidenceClosureCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'إغلاق Route Console Evidence — مسجل كقيد لا كاعتماد',
      subtitle:
          'طلب الإغلاق سُجل بعد Phase 1، لكن لا توجد أدلة Console نظيفة لكل مسار. لذلك يبقى runtime reroute وexact replacement محظورين.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _StatusBadge(
            icon: Icons.browser_updated_rounded,
            label: 'Route Console evidence غير مقبول بعد',
            tone: _BadgeTone.warning,
          ),
          SizedBox(height: 12),
          _RuleLine(
            text:
                'SQL 15 يسجل قائمة المسارات المطلوبة ويقرر أن غياب أدلة Console لا يساوي اعتمادًا.',
          ),
          _RuleLine(
            text:
                'الأدلة المقبولة سابقًا: analyzer clean وChrome startup فقط؛ لا تكفي لتصديق route-console-clean.',
          ),
          _RuleLine(
            text:
                'المسارات المطلوبة تشمل /home، الأخبار، الإعلانات، gallery، services، /zakat، /press-releases، و/admin/database-migration.',
          ),
          _RuleLine(
            text:
                'أي خطأ Supabase/PostgREST أحمر مرتبط بجداول public المرحّلة يبقي Phase 2 في planning فقط.',
          ),
        ],
      ),
    );
  }
}

class _Phase2RbacPlanningGateCard extends StatelessWidget {
  const _Phase2RbacPlanningGateCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Phase 2 — بوابة تخطيط RBAC/Access فقط',
      subtitle:
          'تم حصر 10 اعتماديات مباشرة لعائلة platform_access_rbac. هذه الدفعة لا تغير runtime ولا صلاحيات ولا RLS؛ هي تجهز شروط الإصلاح القادم.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _StatusBadge(
            icon: Icons.admin_panel_settings_rounded,
            label: 'RBAC runtime remediation غير منفذ',
            tone: _BadgeTone.warning,
          ),
          SizedBox(height: 12),
          _RuleLine(
            text:
                'SQL 16 يحصر 10 أزواج file/table: user_system_permissions، user_system_roles، platform_permissions، platform_systems.',
          ),
          _RuleLine(
            text:
                'SQL 17 يحدد Role UAT المطلوب: super_admin، platform_admin، unit_admin، scoped user، unauthorized، anonymous.',
          ),
          _RuleLine(
            text:
                'أي تنفيذ فعلي لاحق يجب أن يكون one-family فقط، مع rollback flag وlegacy-read fallback.',
          ),
          _RuleLine(
            text:
                'core_linkage يبقى Phase 3 ولا يخلط مع RBAC، وauth.users لا يُنقل.',
          ),
        ],
      ),
    );
  }
}

class _Phase2RbacImplementationCard extends StatelessWidget {
  const _Phase2RbacImplementationCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Phase 2 — تنفيذ adapters لقراءات RBAC/Access',
      subtitle:
          'تم تحويل مسارات القراءة لعائلة platform_access_rbac إلى public compatibility wrappers، مع إبقاء الكتابة الإدارية على legacy public tables حتى تصميم owner-write RPCs.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _StatusBadge(
            icon: Icons.security_update_good_rounded,
            label: 'RBAC read adapters remediated',
            tone: _BadgeTone.success,
          ),
          SizedBox(height: 12),
          _RuleLine(
            text:
                'AccessRepository يقرأ user_system_roles وuser_system_permissions من public.v_platform_*_compat_v1 بدل الجداول القديمة مباشرة.',
          ),
          _RuleLine(
            text:
                'RbacAdminRepository ونسخة tasks_system تقرأ platform_systems وplatform_permissions وأدوار/صلاحيات المستخدم من wrappers.',
          ),
          _RuleLine(
            text:
                'مسارات insert/update/delete بقيت مؤقتًا على legacy public tables، لأنها تحتاج owner-write RPCs قبل نقل الكتابة إلى platform schema.',
          ),
          _RuleLine(
            text:
                'لا يوجد runtime reroute عام ولا exact table-name replacement؛ المطلوب بعد التطبيق Role/RLS/Browser Console UAT.',
          ),
        ],
      ),
    );
  }
}

class _Phase3CoreAdminAuthPlanningGateCard extends StatelessWidget {
  const _Phase3CoreAdminAuthPlanningGateCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Phase 3 — Core/Admin/Auth linkage planning gate',
      subtitle:
          'هذه المرحلة تفصل معالجة admin_users/auth عن RBAC. لا يتم نقل auth.users ولا تنفيذ runtime reroute؛ الهدف تحديد الاعتماديات وتصميم المسار الآمن.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _StatusBadge(
            icon: Icons.account_circle_rounded,
            label: 'Core/Admin/Auth runtime remediation غير منفذ',
            tone: _BadgeTone.warning,
          ),
          SizedBox(height: 12),
          _RuleLine(
            text:
                'SQL 23 يحصر نطاق Phase 3: public.admin_users، core/admin profile linkage، وauth.users كمرجع مصادقة غير قابل للنقل.',
          ),
          _RuleLine(
            text:
                'SQL 24 يسجل 5 أزواج file/table متبقية حول admin_users في access/auth/admin repositories ونسخ tasks_system.',
          ),
          _RuleLine(
            text:
                'SQL 30 يثبت أن قراءات Core/Admin/Auth runtime تحولت إلى public.v_core_admin_users_compat_v1 مع بقاء الكتابات blockers.',
          ),
          _RuleLine(
            text:
                'SQL 31 يفتح بوابة مراجعة owner-write RPC implementation دون CREATE FUNCTION أو write reroute.',
          ),
          _RuleLine(
            text:
                'SQL 32 يضيف عقد مراجعة أجسام owner-write RPCs كـ read-only matrix؛ لا ينشئ دوال.',
          ),
          _RuleLine(
            text:
                'SQL 33 يثبت قرار implementation gate: التنفيذ محجوب حتى إغلاق RLS/audit/search_path/rollback والأدلة.',
          ),
          _RuleLine(
            text:
                'أي معالجة لاحقة يجب أن تبدأ بقراءات core/admin compatibility wrappers ثم owner-write RPCs؛ لا direct writes إلى core من Flutter.',
          ),
          _RuleLine(
            text:
                'auth.users يبقى تحت Supabase Auth، ولا يتم نسخه أو ترحيله أو اعتباره جدول منصة تشغيلي.',
          ),
        ],
      ),
    );
  }
}

class _OwnerWriteRpcDesignGateCard extends StatelessWidget {
  const _OwnerWriteRpcDesignGateCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Owner-write RPC design — تصميم فقط',
      subtitle:
          'تمت إضافة عقد تصميم RPCs للكتابة إلى platform/core، لكنه ليس DDL قابلًا للتنفيذ في هذه الدفعة ولا يجيز تحويل repositories للكتابة عبره بعد.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _StatusBadge(
            icon: Icons.api_rounded,
            label: 'Owner-write RPCs غير منشأة بعد',
            tone: _BadgeTone.warning,
          ),
          SizedBox(height: 12),
          _RuleLine(
            text:
                'SQL 25 هو design-only/DRAFT_NOT_RUN ويعرض RPC matrix دون CREATE FUNCTION أو GRANT أو DDL.',
          ),
          _RuleLine(
            text:
                'SQL 26 يفحص جاهزية owner surfaces وcompat wrappers وغياب/وجود RPCs المقترحة عبر pg_catalog فقط.',
          ),
          _RuleLine(
            text:
                'كل RPC لاحق يجب أن يملك auth.uid/scope checks، audit event، locked search_path، وخطة rollback قبل أي Flutter write reroute.',
          ),
          _RuleLine(
            text:
                'إنتاج المنصة يبقى غير معتمد لأن أدلة Role/RLS/Browser Console لم تُرفق في هذه الدفعة.',
          ),
        ],
      ),
    );
  }
}

class _OwnerWriteRpcAuthorizationReviewGateCard extends StatelessWidget {
  const _OwnerWriteRpcAuthorizationReviewGateCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Development 9F — Owner-write authorization review',
      subtitle:
          'تم استيعاب SQL 32/33. التنفيذ ما زال غير مخول، وتم فتح exact body draft gate كمراجعة فقط دون CREATE FUNCTION أو GRANT أو تحويل كتابة.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _StatusBadge(
            icon: Icons.lock_outline_rounded,
            label: 'Implementation not authorized',
            tone: _BadgeTone.danger,
          ),
          SizedBox(height: 12),
          _RuleLine(
            text:
                'SQL 34 يسجل authorization review كـ read-only ويثبت أن RPC implementation ما زال محجوبًا.',
          ),
          _RuleLine(
            text:
                'SQL 35 يحدد متطلبات exact body draft لكل RPC دون إنشاء أي دوال أو صلاحيات.',
          ),
          _RuleLine(
            text:
                'أي تنفيذ لاحق يحتاج RLS/auth.uid guards وaudit وlocked search_path وrollback وself-lockout وRole/RLS/Browser evidence.',
          ),
          _RuleLine(
            text:
                'لا auth.users migration، لا service_role في Flutter، ولا أي mutation على waqf_assets/waqf/awqaf_system.',
          ),
        ],
      ),
    );
  }
}

class _OwnerWriteRpcConsolidationGateCard extends StatelessWidget {
  const _OwnerWriteRpcConsolidationGateCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Development 9G — Consolidation gate',
      subtitle:
          'تم إغلاق مسار الباتشات الصغيرة في Phase 3. الخطوة التالية يجب أن تكون حزمة تنفيذية موحدة بأجسام SQL وأدلة كاملة، أو ملف توريث/انتقال لمسار آخر.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _StatusBadge(
            icon: Icons.route_outlined,
            label: 'No more review-only micro-patches',
            tone: _BadgeTone.warning,
          ),
          SizedBox(height: 12),
          _RuleLine(
            text: 'SQL 36 يستوعب نتائج SQL 34/35 ويثبت استمرار منع التنفيذ.',
          ),
          _RuleLine(
            text:
                'SQL 37 يحدد Negative UAT للـ anonymous/unauthorized/scoped/unit/platform/superuser.',
          ),
          _RuleLine(
            text:
                'أي متابعة يجب أن تكون consolidated implementation candidate، لا سلسلة gates صغيرة.',
          ),
          _RuleLine(
            text:
                'لا CREATE FUNCTION ولا GRANT ولا write reroute قبل الأجسام والأدلة والتفويض الصريح.',
          ),
        ],
      ),
    );
  }
}

class _PlatformDevelopment10ConsolidatedGateCard extends StatelessWidget {
  const _PlatformDevelopment10ConsolidatedGateCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Platform Development 10 — Consolidated candidate gate',
      subtitle:
          'Development 10 يوحد مسار Phase 3 لكنه لا ينفذ owner-write RPCs؛ التنفيذ محجوب حتى توفير أجسام SQL والأدلة والتفويض الصريح.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _StatusBadge(
            icon: Icons.security_update_warning_outlined,
            label: 'Implementation candidate blocked',
            tone: _BadgeTone.warning,
          ),
          SizedBox(height: 12),
          _RuleLine(
            text:
                'SQL 38 يقبل نتيجة SQL 37 ويمنع التنفيذ لعدم توفر الأجسام والأدلة.',
          ),
          _RuleLine(
            text:
                'SQL 39 يحدد قائمة أجسام RPCs الثمانية المطلوبة قبل أي CREATE FUNCTION.',
          ),
          _RuleLine(
            text:
                'SQL 40 يحدد Negative UAT execution matrix لكل الأدوار الحرجة.',
          ),
          _RuleLine(
            text:
                'SQL 41 يعيد قرار البوابة: production غير معتمد وwrite reroute غير مخول.',
          ),
        ],
      ),
    );
  }
}

class _PlatformDevelopment10AAuthorizationTokenGateCard
    extends StatelessWidget {
  const _PlatformDevelopment10AAuthorizationTokenGateCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Platform Development 10A — Authorization token intake',
      subtitle:
          'تم تسجيل AUTHORIZE_OWNER_WRITE_RPC_EXECUTION=true كنية تنفيذ، لكنه لا يفتح التنفيذ دون أجسام SQL كاملة وأدلة Negative UAT وRole/RLS/Console.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _StatusBadge(
            icon: Icons.gpp_maybe_rounded,
            label: 'Token received — execution still blocked',
            tone: _BadgeTone.danger,
          ),
          SizedBox(height: 12),
          _RuleLine(text: 'SQL 42 يسجل token التفويض ويثبت أنه غير كاف وحده.'),
          _RuleLine(
            text: 'SQL 43 يثبت أن أجسام RPCs الثمانية وأدلة UAT ما زالت ناقصة.',
          ),
          _RuleLine(
            text: 'SQL 44 يحدد شروط 10B التنفيذية كحزمة واحدة لا باتشات صغيرة.',
          ),
          _RuleLine(
            text: 'SQL 45 يعيد قرار الإنتاج: غير معتمد، ولا write reroute.',
          ),
        ],
      ),
    );
  }
}

class _PlatformDevelopment10FNegativeUatGateCard extends StatelessWidget {
  const _PlatformDevelopment10FNegativeUatGateCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Platform Development 10F — Negative UAT actor bundle',
      subtitle:
          'تم قبول startup وpublic route console evidence، لكن الإنتاج يبقى محجوبًا حتى تمر حالات الرفض السلبية للأدوار الحساسة.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _StatusBadge(
            icon: Icons.security_rounded,
            label: 'Negative UAT pending — production not approved',
            tone: _BadgeTone.warning,
          ),
          SizedBox(height: 12),
          _RuleLine(
            text:
                'SQL 10 يسجل مصفوفة Negative UAT ويقبل أدلة startup والـ public routes فقط.',
          ),
          _RuleLine(
            text:
                'SQL 11 يحدد قالب أدلة محاولات الرفض لكل actor دون تنفيذ DML.',
          ),
          _RuleLine(
            text: 'SQL 12 يعيد قرار الإنتاج: غير معتمد حتى تمر كل actor cases.',
          ),
        ],
      ),
    );
  }
}

class _SafetyRulesCard extends StatelessWidget {
  const _SafetyRulesCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'قواعد أمان لا تُكسر',
      subtitle:
          'هذه القواعد تمنع تكرار التشويش السابق وتفصل بين حل الوحدات ونقل الجداول وتطوير الأنظمة.',
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RuleLine(
            text:
                'لا تعديل على waqf_assets أو schema waqf أو runtime أوقاف سيستم الداخلي.',
          ),
          _RuleLine(
            text:
                'لا نقل لأي جدول دون public compatibility view أو rollback واضح.',
          ),
          _RuleLine(
            text:
                'media_center و platform_services لا تُنفذ في هذه الدفعة؛ فقط تُصنف وتؤجل.',
          ),
          _RuleLine(
            text: 'locations تبقى unresolved/manual_review ولا تدخل في N2.36.',
          ),
          _RuleLine(
            text:
                'الإنتاج غير معتمد حتى إغلاق SQL UAT وBrowser UAT وFlutter analyzer.',
          ),
        ],
      ),
    );
  }
}

class _RuleLine extends StatelessWidget {
  const _RuleLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.verified_user_rounded,
            size: 19,
            color: Color(0xFF0F4C81),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Color(0xFF334155), height: 1.55),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.title,
    required this.value,
    required this.description,
    required this.icon,
    required this.tone,
  });

  final String title;
  final String value;
  final String description;
  final IconData icon;
  final _BadgeTone tone;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IconBox(icon: icon, tone: tone),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                _TonePill(label: value, tone: tone),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.title, this.subtitle});

  final Widget child;
  final String? title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(
                subtitle!,
                style: const TextStyle(color: Color(0xFF64748B), height: 1.55),
              ),
            ],
            const SizedBox(height: 14),
          ],
          child,
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.icon,
    required this.children,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: title,
      subtitle: subtitle,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _IconBox(icon: icon, tone: _BadgeTone.info),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF334155),
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(color: Color(0xFF64748B), height: 1.45),
          ),
        ],
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({required this.icon, required this.tone});

  final IconData icon;
  final _BadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = _toneColors(tone);
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: colors.foreground),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.icon,
    required this.label,
    required this.tone,
  });

  final IconData icon;
  final String label;
  final _BadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = _toneColors(tone);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: colors.foreground, size: 18),
          const SizedBox(width: 7),
          Text(
            label,
            style: TextStyle(
              color: colors.foreground,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _TonePill extends StatelessWidget {
  const _TonePill({required this.label, required this.tone});

  final String label;
  final _BadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = _toneColors(tone);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.border),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colors.foreground,
          fontWeight: FontWeight.w900,
          fontSize: 11,
        ),
      ),
    );
  }
}

enum _BadgeTone { success, warning, danger, info }

class _ToneColors {
  const _ToneColors({
    required this.background,
    required this.foreground,
    required this.border,
  });

  final Color background;
  final Color foreground;
  final Color border;
}

_ToneColors _toneColors(_BadgeTone tone) {
  switch (tone) {
    case _BadgeTone.success:
      return const _ToneColors(
        background: Color(0xFFEFFAF3),
        foreground: Color(0xFF166534),
        border: Color(0xFFBBF7D0),
      );
    case _BadgeTone.warning:
      return const _ToneColors(
        background: Color(0xFFFFF7ED),
        foreground: Color(0xFF9A3412),
        border: Color(0xFFFED7AA),
      );
    case _BadgeTone.danger:
      return const _ToneColors(
        background: Color(0xFFFEF2F2),
        foreground: Color(0xFFB22222),
        border: Color(0xFFFECACA),
      );
    case _BadgeTone.info:
      return const _ToneColors(
        background: Color(0xFFEAF2F8),
        foreground: Color(0xFF0F4C81),
        border: Color(0xFFBFDBFE),
      );
  }
}

// Platform Development 10B: Owner-write RPC executable implementation pack prepared.
// Write reroute remains behind PWF_OWNER_WRITE_RPC_WRITE_REROUTE and production is not approved.

// Platform Development 10D: anon revoke UAT accepted; public placeholder image
// console hardening applied. Browser console retest and Negative UAT remain
// required before production approval.

class _PlatformDevelopment10HActualEvidenceBundleCard extends StatelessWidget {
  const _PlatformDevelopment10HActualEvidenceBundleCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Platform Development 10H — Actual Negative UAT evidence bundle',
      subtitle:
          'تم تجهيز runner فعلي لتوليد أدلة محاولات الرفض للـ six actors. الإنتاج يبقى غير معتمد حتى تُرفق النتائج.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _StatusBadge(
            icon: Icons.fact_check_rounded,
            label: 'Evidence runner prepared — production not approved',
            tone: _BadgeTone.warning,
          ),
          SizedBox(height: 12),
          _RuleLine(
            text:
                'يشغل runner محاولات رفض فعلية دون service_role أو elevated secret.',
          ),
          _RuleLine(
            text:
                'SQL 14 يتحقق من حالة الدوال وامتيازات anon/authenticated read-only.',
          ),
          _RuleLine(
            text:
                'SQL 15 قالب قرار إنتاج بعد إرفاق JSON/MD والـ admin/write console proof.',
          ),
        ],
      ),
    );
  }
}

class _PlatformDevelopment10IActualNegativeUatResultCard
    extends StatelessWidget {
  const _PlatformDevelopment10IActualNegativeUatResultCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Platform Development 10I — Actual Negative UAT result intake',
      subtitle:
          'تم استيعاب JSON/MD فعلي من runner: جميع حالات الرفض المطلوبة ناجحة و unsafe_success_count = 0. الإنتاج ما زال ينتظر SQL/RLS proof و admin/write console.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _StatusBadge(
            icon: Icons.verified_user_rounded,
            label: 'Runner passed — production gate still pending',
            tone: _BadgeTone.warning,
          ),
          SizedBox(height: 12),
          _RuleLine(
            text:
                'all_required_actor_cases_denied=true across anonymous, unauthorized, scoped, unit_admin, platform_admin, superuser.',
          ),
          _RuleLine(
            text:
                'unsafe_success_count=0 and missing_config_count=0 from uploaded runner JSON.',
          ),
          _RuleLine(
            text:
                'Next gate: SQL 17 no unsafe mutation proof + admin/write-surface console clean evidence.',
          ),
        ],
      ),
    );
  }
}

class _PlatformDevelopment10J0ASiteContentAdapterCompileFixCard
    extends StatelessWidget {
  const _PlatformDevelopment10J0ASiteContentAdapterCompileFixCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Platform Development 10J-0A — Site content adapter compile fix',
      subtitle:
          'تم إغلاق blocker تجميعي في Flutter بسبب ثوابت adapter مفقودة في site_pages/homepage_sections أثناء جمع admin/write console evidence. الإنتاج غير معتمد.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _StatusBadge(
            icon: Icons.build_circle_rounded,
            label: 'Compile blocker fixed — local retest required',
            tone: _BadgeTone.warning,
          ),
          SizedBox(height: 12),
          _RuleLine(
            text:
                'أضيفت ثوابت read wrapper/write table إلى Visual Identity publish repository و Unit Pages repository و Site Pages repository.',
          ),
          _RuleLine(
            text:
                'SQL 17 partial auth boundary accepted: no auth.users mutation in script.',
          ),
          _RuleLine(
            text:
                'Next: flutter analyze + flutter run -d edge/chrome ثم admin/write-surface console clean evidence.',
          ),
        ],
      ),
    );
  }
}

class _PlatformDevelopment10J0DObservability404FixCard extends StatelessWidget {
  const _PlatformDevelopment10J0DObservability404FixCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Platform Development 10J-0D — Observability 404 console fix',
      subtitle:
          'تم قبول analyzer-clean و Edge startup، لكن dashboard كشف 404 على جداول observability اختيارية. تم إيقاف probes المباشرة من Flutter لحين تركيب public audit/session wrappers مراجعة.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _StatusBadge(
            icon: Icons.visibility_off_rounded,
            label:
                'Legacy observability REST probes disabled — retest required',
            tone: _BadgeTone.warning,
          ),
          SizedBox(height: 12),
          _RuleLine(
            text:
                'لم يعد Flutter يستعلم مباشرة عن user_activity_logs/activity_logs/user_sessions/admin_user_sessions/audit_logs.',
          ),
          _RuleLine(
            text:
                'User activity/session UI يتدهور مؤقتًا إلى empty read model بدل 404/406 console noise.',
          ),
          _RuleLine(
            text:
                'Owner-write server-side audit محفوظ؛ عرض audit في Flutter يحتاج public wrapper/RPC لاحقًا.',
          ),
          _RuleLine(
            text:
                'Next: flutter analyze + dashboard console retest + full SQL17 output قبل Production Gate Re-Decision.',
          ),
        ],
      ),
    );
  }
}

class _DatabaseOwnershipClosureMasterPackCard extends StatelessWidget {
  const _DatabaseOwnershipClosureMasterPackCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'إغلاق ملكية الجداول وترتيب السكيما — Master Pack',
      subtitle:
          'دفعة كبيرة تضبط owner schemas، compatibility surfaces، dependency-zero، وUAT قبل أي أرشفة أو حذف لجداول public legacy.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _StatusBadge(
            icon: Icons.schema_rounded,
            label:
                'CONTROLLED_SCHEMA_OWNERSHIP_CLOSURE_MASTER_PACK_PREPARED_EXECUTION_PENDING',
            tone: _BadgeTone.warning,
          ),
          SizedBox(height: 12),
          _RuleLine(
            text:
                'public يبقى compatibility views/RPCs فقط وليس مالك كتابة سيادي.',
          ),
          _RuleLine(
            text:
                'لا auth.users migration، لا service_role، لا waqf_assets mutation، ولا drop/delete قبل dependency-zero.',
          ),
          _RuleLine(
            text:
                'SQL pack 00–10 موجود تحت sql_sandbox/platform_database_ownership_closure_master_pack/.',
          ),
          _RuleLine(
            text:
                'الدفعة تحضّر التنفيذ ولا تعتمد الإنتاج أو النقل الفيزيائي النهائي دون نتائج SQL/UAT.',
          ),
        ],
      ),
    );
  }
}

class _DatabaseDependencyRemediationWaveACard extends StatelessWidget {
  const _DatabaseDependencyRemediationWaveACard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'DB Dependency Remediation — Wave A',
      subtitle:
          'استيعاب SQL 18/19/20: الرقم الخام 502 لم يعد blocker مسطحًا؛ Wave A تفصل المرشحات الحقيقية عن compatibility/review-only buckets.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _StatusBadge(
            icon: Icons.account_tree_rounded,
            label: 'RAW_502_NORMALIZED_WAVE_A_DESIGN_ONLY_EXECUTION_BLOCKED',
            tone: _BadgeTone.warning,
          ),
          SizedBox(height: 12),
          _RuleLine(
            text:
                'Wave A candidates محصورة في owner_schema_dependency_needs_wrapper_review و view_or_rule_dependency.',
          ),
          _RuleLine(
            text:
                'public compatibility wrappers و routine source mentions لا تُحسب كسبب حذف/أرشفة تلقائي.',
          ),
          _RuleLine(
            text:
                'GIS/waqf/awqaf_system protected review-only؛ لا migration أو mutation ضمن منصة database ownership batch.',
          ),
          _RuleLine(
            text:
                'SQL 21/22/23 read-only فقط. أي تنفيذ فعلي يحتاج token + backup + governance authorization.',
          ),
        ],
      ),
    );
  }
}

class _DatabaseDependencyWaveAExactBodyReviewGateCard extends StatelessWidget {
  const _DatabaseDependencyWaveAExactBodyReviewGateCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Wave A — استيعاب النتيجة وبوابة exact body review',
      subtitle:
          'تم قبول نتائج SQL 21/22/23. التنفيذ ما زال محظورًا؛ الخطوة الآمنة التالية هي تصدير أجسام المرشحات للمراجعة الدقيقة فقط.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _StatusBadge(
            icon: Icons.rule_folder_rounded,
            label:
                'WAVE_A_RESULTS_ACCEPTED_EXACT_BODY_REVIEW_REQUIRED_EXECUTION_BLOCKED',
            tone: _BadgeTone.warning,
          ),
          SizedBox(height: 12),
          _RuleLine(
            text:
                'SQL 24/25/26/27 read-only فقط؛ لا DDL/DML/GRANT/DROP ولا exact replacement.',
          ),
          _RuleLine(
            text:
                'Wave A execution design محصور في owner_schema_dependency_needs_wrapper_review و view_or_rule_dependency.',
          ),
          _RuleLine(
            text:
                'RLS negative UAT وBrowser Console وtoken/backup/governance authorization ما زالت مطلوبة قبل أي تنفيذ.',
          ),
          _RuleLine(
            text:
                'public compatibility wrappers تبقى محفوظة ولا تُحذف بسبب raw dependency count.',
          ),
        ],
      ),
    );
  }
}

class _DatabaseDependencyWaveAExactBodyExportReviewIntakeCard
    extends StatelessWidget {
  const _DatabaseDependencyWaveAExactBodyExportReviewIntakeCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Wave A — exact body export review intake',
      subtitle:
          'تم استيعاب SQL 24/25/26/27: أجسام المرشحات أصبحت متاحة للمراجعة، لكن التنفيذ ما زال محظورًا حتى RLS/Browser/token/backup.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _StatusBadge(
            icon: Icons.manage_search_rounded,
            label:
                'EXACT_BODY_EXPORT_ACCEPTED_FOR_REVIEW_EXECUTION_STILL_BLOCKED',
            tone: _BadgeTone.warning,
          ),
          SizedBox(height: 12),
          _RuleLine(
            text:
                'المرشحات العملية الآن: assistant/core/tasks access helpers التي تعتمد على public.admin_users أو صلاحيات public.',
          ),
          _RuleLine(
            text:
                'core waqf/community import loaders مستبعدة من التنفيذ في Wave A لأنها تحتوي DML تشغيلي وليست مجرد owner-wrapper remediation.',
          ),
          _RuleLine(
            text:
                'media_center.v_content_items_public_v1 accepted owner-schema public view ولا تحتاج تعديلًا في Wave A.',
          ),
          _RuleLine(
            text:
                'SQL 28/29/30/31 read-only فقط؛ لا تنفيذ قبل exact body approval + RLS/browser evidence + token/backup.',
          ),
        ],
      ),
    );
  }
}

class _DatabaseOwnershipPhaseBMediaCenterMegaClosureCard
    extends StatelessWidget {
  const _DatabaseOwnershipPhaseBMediaCenterMegaClosureCard();

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      title: 'Phase B — Media Center mega closure pack',
      icon: Icons.perm_media_rounded,
      subtitle:
          'دفعة واحدة كبيرة للمركز الإعلامي: master census، guarded apply، validation، browser/runtime UAT، وfinal closure gate.',
      children: const [
        _StatusLine(
          label: 'Decision',
          value:
              'Media Center DB ownership appears ready; SQL02 apply is not required unless validation shows a real gap',
        ),
        _StatusLine(
          label: 'Current evidence',
          value:
              'Master Census found 279 owner rows and required compatibility views present',
        ),
        _StatusLine(
          label: 'Run now',
          value:
              'Validate runtime/browser evidence only; do not run one-shot apply without a real mismatch',
        ),
        _StatusLine(
          label: 'Boundaries',
          value:
              'No Auth/RBAC, no service center, no waqf/GIS, no drop/delete/archive/exact replacement',
        ),
      ],
    );
  }
}

class _DatabaseDependencyWaveASql29CoreRelationHotfixCard
    extends StatelessWidget {
  const _DatabaseDependencyWaveASql29CoreRelationHotfixCard();

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Wave A — SQL 29 core relation hotfix',
      subtitle:
          'تصحيح SQL 29 بعد ERROR 42P01: relation "core" does not exist؛ التصحيح read-only ويعيد المصفوفة بدون VALUES recordset.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _StatusBadge(
            icon: Icons.build_circle_outlined,
            label: 'SQL29A_CORE_RELATION_HOTFIX_APPLIED_RETRY_REQUIRED',
            tone: _BadgeTone.warning,
          ),
          SizedBox(height: 12),
          _RuleLine(
            text:
                'SQL 29 أعيدت كتابته كمصفوفة UNION ALL صريحة حتى لا يفسر runner قيمة core كعلاقة/جدول.',
          ),
          _RuleLine(
            text:
                'شغّل 32 ثم 29 ثم 30 و31؛ التنفيذ ما زال محظورًا حتى RLS/Browser/token/backup.',
          ),
          _RuleLine(
            text:
                'لا توجد DDL/DML/GRANT/DROP ولا archive/delete ولا exact replacement في هذا التصحيح.',
          ),
        ],
      ),
    );
  }
}

class _DatabaseDependencyWaveAAccessHelpersActualRemediationCard
    extends StatelessWidget {
  const _DatabaseDependencyWaveAAccessHelpersActualRemediationCard();

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      title: 'Wave A access helpers — actual remediation draft',
      icon: Icons.security_update_warning_rounded,
      children: const [
        _StatusLine(
          label: 'Decision',
          value: 'Guarded replacement bodies drafted; execution fail-closed',
        ),
        _StatusLine(
          label: 'Scope',
          value: 'assistant/core/tasks access helpers only',
        ),
        _StatusLine(
          label: 'Execution',
          value: 'Not authorized; SQL37 requires governance token and evidence',
        ),
        _StatusLine(
          label: 'Exclusions',
          value: 'No media/waqf/gis/import loaders/public exact replacement',
        ),
      ],
    );
  }
}

class _DatabaseDependencyWaveAAccessHelpersPreflightPassedCard
    extends StatelessWidget {
  const _DatabaseDependencyWaveAAccessHelpersPreflightPassedCard();

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      title: 'Wave A access helpers — preflight passed',
      icon: Icons.fact_check_rounded,
      children: const [
        _StatusLine(
          label: 'Decision',
          value: 'SQL36 preflight passed; SQL37 review required',
        ),
        _StatusLine(
          label: 'Allowed now',
          value: 'Review guarded SQL37 body only',
        ),
        _StatusLine(
          label: 'Execution',
          value: 'Blocked until token + backup + RLS/browser evidence',
        ),
        _StatusLine(
          label: 'Boundaries',
          value: 'No SQL29, no 02/03/04, no archive/delete/drop',
        ),
      ],
    );
  }
}

class _DatabaseOwnershipWaveASafeStopCard extends StatelessWidget {
  const _DatabaseOwnershipWaveASafeStopCard();

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      title: 'Database Ownership Wave A — Safe Stop',
      icon: Icons.pause_circle_filled_rounded,
      children: const [
        _StatusLine(
          label: 'Final decision',
          value: 'Do not execute Wave A access-helper replacement',
        ),
        _StatusLine(
          label: 'Accepted',
          value:
              'Compatibility layer remains active; Wave A closed as preflight',
        ),
        _StatusLine(
          label: 'Do not run',
          value: 'SQL29, SQL37, SQL38/39/40, SQL02/03/04',
        ),
        _StatusLine(
          label: 'Future track',
          value: 'Access-helper rewrite requires separate Auth/RBAC migration',
        ),
      ],
    );
  }
}

class _DatabaseOwnershipPhaseBMediaCenterControlledClosureCard
    extends StatelessWidget {
  const _DatabaseOwnershipPhaseBMediaCenterControlledClosureCard();

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      title: 'Phase B — Media Center ownership closure',
      icon: Icons.perm_media_rounded,
      children: const [
        _StatusLine(
          label: 'Decision',
          value: 'Start with read-only media inventory and compatibility gates',
        ),
        _StatusLine(
          label: 'Scope',
          value: 'media_center + legacy public media compatibility only',
        ),
        _StatusLine(
          label: 'Run now',
          value: '01, 02, 03, 04, 06, 07 only; do not run 05',
        ),
        _StatusLine(
          label: 'Boundaries',
          value: 'No Auth/RBAC, no waqf/GIS, no drop/delete/exact replacement',
        ),
      ],
    );
  }
}
