import 'package:flutter/material.dart';

import '../../domain/pwf_cross_system_contracts.dart';

class PwfCrossSystemIntegrationPage extends StatelessWidget {
  const PwfCrossSystemIntegrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final contracts = PwfCrossSystemIntegrationContracts.systems;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('عقود الربط بين الأنظمة')),
        backgroundColor: theme.colorScheme.surface,
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const _HeaderCard(),
            const SizedBox(height: 16),
            const _RulesGrid(),
            const SizedBox(height: 16),
            Text(
              'مصفوفة العقود المعتمدة للربط',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            ...contracts.map(
              (contract) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _SystemContractCard(contract: contract),
              ),
            ),
          ],
        ),
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
                  PwfCrossSystemIntegrationContracts.titleAr,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Chip(label: Text('read-only contracts')),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              PwfCrossSystemIntegrationContracts.anchorRuleAr,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            const _KeyValueLine(
              label: 'الحكم الحالي',
              value: PwfCrossSystemIntegrationContracts.judgment,
            ),
          ],
        ),
      ),
    );
  }
}

class _RulesGrid extends StatelessWidget {
  const _RulesGrid();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 960;
        return GridView.count(
          crossAxisCount: isWide ? 2 : 1,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: isWide ? 2.2 : 1.7,
          children: const [
            _RuleCard(
              title: 'المسموح للمنصة',
              icon: Icons.verified_user_outlined,
              values: PwfCrossSystemIntegrationContracts.allowedPlatformActions,
            ),
            _RuleCard(
              title: 'الممنوع من جهة المنصة',
              icon: Icons.block_outlined,
              values:
                  PwfCrossSystemIntegrationContracts.forbiddenPlatformActions,
            ),
          ],
        );
      },
    );
  }
}

class _RuleCard extends StatelessWidget {
  const _RuleCard({
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
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                physics: const NeverScrollableScrollPhysics(),
                children: values
                    .map(
                      (value) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle_outline, size: 18),
                            const SizedBox(width: 8),
                            Expanded(child: Text(value)),
                          ],
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SystemContractCard extends StatelessWidget {
  const _SystemContractCard({required this.contract});

  final PwfSystemContract contract;

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
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Icon(Icons.hub_outlined, color: theme.colorScheme.primary),
                Text(
                  contract.titleAr,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Chip(label: Text(contract.currentState)),
              ],
            ),
            const SizedBox(height: 12),
            _KeyValueLine(label: 'النظام المالك', value: contract.ownerAr),
            _KeyValueLine(label: 'مرساة الربط', value: contract.anchorField),
            _KeyValueLine(label: 'وضع المنصة', value: contract.platformMode),
            _KeyValueLine(
              label: 'بوابة الاعتماد',
              value: contract.requiredGate,
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 760;
                final children = [
                  _MiniList(
                    title: 'المراجع المسموحة',
                    values: contract.allowedReferences,
                  ),
                  _MiniList(
                    title: 'المراجع المحظورة',
                    values: contract.blockedReferences,
                  ),
                ];
                if (!isWide) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: children
                        .map(
                          (child) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: child,
                          ),
                        )
                        .toList(growable: false),
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: children.first),
                    const SizedBox(width: 12),
                    Expanded(child: children.last),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniList extends StatelessWidget {
  const _MiniList({required this.title, required this.values});

  final String title;
  final List<String> values;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            ...values.map(
              (value) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
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
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
  }
}
