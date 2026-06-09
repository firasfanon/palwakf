import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/awqaf_waqf_assets_platform_contract.dart';

class AwqafWaqfAssetsIntegrationIntakePage extends ConsumerWidget {
  const AwqafWaqfAssetsIntegrationIntakePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('استلام الأصول الوقفية')),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: const [
            _HeaderCard(),
            SizedBox(height: 16),
            _StatusGrid(),
            SizedBox(height: 16),
            _ContractSection(
              title: 'المسموح للمنصة',
              icon: Icons.verified_user_outlined,
              values:
                  AwqafWaqfAssetsPlatformContract.allowedPlatformIntakeActions,
            ),
            SizedBox(height: 16),
            _ContractSection(
              title: 'ممنوع من جهة المنصة',
              icon: Icons.block_outlined,
              values: AwqafWaqfAssetsPlatformContract.unsafePlatformActions,
            ),
            SizedBox(height: 16),
            _ContractSection(
              title: 'جداول لا تُمس من تطوير المنصة',
              icon: Icons.storage_outlined,
              values: AwqafWaqfAssetsPlatformContract.doNotTouchTables,
            ),
            SizedBox(height: 16),
            _ContractSection(
              title: 'RPCs لا تستبدلها المنصة',
              icon: Icons.api_outlined,
              values: AwqafWaqfAssetsPlatformContract.doNotReplaceRpcs,
            ),
            SizedBox(height: 16),
            _ContractSection(
              title: 'بوابات P1 قبل التكامل الكامل',
              icon: Icons.rule_folder_outlined,
              values: AwqafWaqfAssetsPlatformContract.p1IntegrationGates,
            ),
          ],
        ),
        backgroundColor: theme.colorScheme.surface,
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Icon(
                  Icons.account_tree_outlined,
                  color: theme.colorScheme.primary,
                ),
                Text(
                  AwqafWaqfAssetsPlatformContract.intakeTitleAr,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Chip(label: Text('review-ready / staging / partial')),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              AwqafWaqfAssetsPlatformContract.platformRoleAr,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            const _KeyValueLine(
              label: 'الحكم الحالي',
              value: AwqafWaqfAssetsPlatformContract.currentJudgment,
            ),
            const _KeyValueLine(
              label: 'Baseline',
              value: AwqafWaqfAssetsPlatformContract.baselineZip,
            ),
            const _KeyValueLine(
              label: 'SHA256',
              value: AwqafWaqfAssetsPlatformContract.baselineSha256,
            ),
            const _KeyValueLine(
              label: 'حزمة المصدر',
              value: AwqafWaqfAssetsPlatformContract.sourcePackage,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusGrid extends StatelessWidget {
  const _StatusGrid();

  @override
  Widget build(BuildContext context) {
    final entries = AwqafWaqfAssetsPlatformContract.uatEvidence.entries.toList(
      growable: false,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 920;
        return GridView.builder(
          itemCount: entries.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isWide ? 3 : 1,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: isWide ? 3.2 : 5.5,
          ),
          itemBuilder: (context, index) {
            final entry = entries[index];
            return _MetricCard(label: entry.key, value: entry.value);
          },
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContractSection extends StatelessWidget {
  const _ContractSection({
    required this.title,
    required this.icon,
    required this.values,
  });

  final String title;
  final IconData icon;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...values.map(
              (value) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_outline, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(value)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KeyValueLine extends StatelessWidget {
  const _KeyValueLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
  }
}
