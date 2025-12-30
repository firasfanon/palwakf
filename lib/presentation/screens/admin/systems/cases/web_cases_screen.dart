// lib/presentation/screens/admin/cases/web_cases_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqf/core/constants/app_constants.dart';
import 'package:waqf/data/models/case.dart';
import 'package:waqf/presentation/widgets/admin/admin_layout.dart';


class WebCasesScreen extends ConsumerWidget {
  const WebCasesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const AdminLayout(
      currentRoute: '/admin/cases',
      child: CasesContent(),
    );
  }
}

class CasesContent extends ConsumerStatefulWidget {
  const CasesContent({super.key});

  @override
  ConsumerState<CasesContent> createState() => _CasesContentState();
}

class _CasesContentState extends ConsumerState<CasesContent> {
  CaseStatus? _selectedStatus;
  CasePriority? _selectedPriority;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsCards(),
                  const SizedBox(height: 24),
                  _buildFilters(),
                  const SizedBox(height: 24),
                  _buildCasesTable(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            const Text(
              'إدارة القضايا',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppConstants.islamicGreen,
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _showAddCaseDialog,
              icon: const Icon(Icons.add),
              label: const Text('قضية جديدة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.islamicGreen,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    final cases = _getSampleCases();
    final totalCases = cases.length;
    final underReview = cases.where((c) => c.status == CaseStatus.underReview).length;
    final investigation = cases.where((c) => c.status == CaseStatus.investigation).length;
    final resolved = cases.where((c) => c.status == CaseStatus.resolved).length;

    return Row(
      children: [
        _buildStatCard('إجمالي القضايا', totalCases.toString(), AppConstants.islamicGreen, Icons.gavel),
        const SizedBox(width: 16),
        _buildStatCard('قيد المراجعة', underReview.toString(), AppColors.warning, Icons.pending),
        const SizedBox(width: 16),
        _buildStatCard('قيد التحقيق', investigation.toString(), AppColors.info, Icons.search),
        const SizedBox(width: 16),
        _buildStatCard('محلولة', resolved.toString(), AppColors.success, Icons.check_circle),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey[200]!),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'تصفية النتائج',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'بحث في القضايا...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<CaseStatus>(
                    initialValue: _selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'الحالة',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('الكل')),
                      ...CaseStatus.values.map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(s.displayName),
                      )),
                    ],
                    onChanged: (value) => setState(() => _selectedStatus = value),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<CasePriority>(
                    initialValue: _selectedPriority,
                    decoration: InputDecoration(
                      labelText: 'الأولوية',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('الكل')),
                      ...CasePriority.values.map((p) => DropdownMenuItem(
                        value: p,
                        child: Text(p.displayName),
                      )),
                    ],
                    onChanged: (value) => setState(() => _selectedPriority = value),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCasesTable() {
    final cases = _filterCases(_getSampleCases());

    if (cases.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(60),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.gavel, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'لا توجد قضايا',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Expanded(flex: 2, child: _buildTableHeader('رقم القضية')),
                Expanded(flex: 3, child: _buildTableHeader('العنوان')),
                Expanded(flex: 2, child: _buildTableHeader('النوع')),
                Expanded(flex: 2, child: _buildTableHeader('الحالة')),
                Expanded(flex: 2, child: _buildTableHeader('الأولوية')),
                Expanded(flex: 2, child: _buildTableHeader('التاريخ')),
                const SizedBox(width: 50, child: Text('')),
              ],
            ),
          ),
          ...cases.map((caseItem) => _buildTableRow(caseItem)),
        ],
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
    );
  }

  Widget _buildTableRow(Case caseItem) {
    return InkWell(
      onTap: () => _showCaseDetails(caseItem),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                caseItem.caseNumber,
                style: const TextStyle(
                  color: AppConstants.islamicGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(flex: 3, child: Text(caseItem.title)),
            Expanded(flex: 2, child: Text(caseItem.type.displayName)),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppConstants.islamicGreen.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  caseItem.status.displayName,
                  style: const TextStyle(
                    color: AppConstants.islamicGreen,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: _buildPriorityBadge(caseItem.priority),
            ),
            Expanded(
              flex: 2,
              child: Text(
                caseItem.filingDate.toString().split(' ')[0],
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            SizedBox(
              width: 50,
              child: IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showCaseDetails(caseItem),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(CasePriority priority) {
    Color color;
    switch (priority) {
      case CasePriority.critical:
        color = Colors.red;
      case CasePriority.urgent:
        color = Colors.orange;
      case CasePriority.high:
        color = AppColors.warning;
      case CasePriority.medium:
        color = AppColors.info;
      case CasePriority.low:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        priority.displayName,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  List<Case> _filterCases(List<Case> cases) {
    var filtered = cases;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((c) {
        return c.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            c.caseNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            c.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    if (_selectedStatus != null) {
      filtered = filtered.where((c) => c.status == _selectedStatus).toList();
    }

    if (_selectedPriority != null) {
      filtered = filtered.where((c) => c.priority == _selectedPriority).toList();
    }

    return filtered;
  }

  void _showCaseDetails(Case caseItem) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          caseItem.caseNumber,
                          style: const TextStyle(
                            color: AppConstants.islamicGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          caseItem.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 32),
              Text(caseItem.description),
              const SizedBox(height: 24),
              _buildDetailRow('النوع', caseItem.type.displayName),
              _buildDetailRow('الحالة', caseItem.status.displayName),
              _buildDetailRow('الأولوية', caseItem.priority.displayName),
              _buildDetailRow('المحافظة', caseItem.governorate),
              _buildDetailRow('المدعي', caseItem.plaintiff.name),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('إغلاق'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('تعديل'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showAddCaseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة قضية جديدة'),
        content: const Text('سيتم إضافة نموذج إنشاء قضية جديدة هنا'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  List<Case> _getSampleCases() {
    return [
      Case(
        id: 1,
        caseNumber: 'Q-2024-001',
        title: 'نزاع ملكية أرض وقفية',
        description: 'نزاع حول ملكية قطعة أرض وقفية في محافظة القدس',
        type: CaseType.propertyDispute,
        status: CaseStatus.underReview,
        priority: CasePriority.high,
        governorate: 'القدس',
        plaintiff: const CaseParty(
          name: 'وزارة الأوقاف',
          idNumber: '000000000',
          phoneNumber: '+970-2-2406340',
          address: 'رام الله',
        ),
        filingDate: DateTime.now().subtract(const Duration(days: 15)),
        assignedTo: 'أحمد محمد',
        createdBy: 1,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      Case(
        id: 2,
        caseNumber: 'Q-2024-002',
        title: 'نزاع إيجار',
        description: 'نزاع بين المستأجر ووزارة الأوقاف حول عقد الإيجار',
        type: CaseType.leaseDispute,
        status: CaseStatus.investigation,
        priority: CasePriority.medium,
        governorate: 'نابلس',
        plaintiff: const CaseParty(
          name: 'محمد خالد',
          idNumber: '123456789',
          phoneNumber: '+970-59-1234567',
          address: 'نابلس',
        ),
        filingDate: DateTime.now().subtract(const Duration(days: 30)),
        assignedTo: 'فاطمة أحمد',
        createdBy: 1,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Case(
        id: 3,
        caseNumber: 'Q-2024-003',
        title: 'نزاع حدود أرض',
        description: 'نزاع على حدود أرض وقفية مع أرض خاصة مجاورة',
        type: CaseType.propertyDispute,
        status: CaseStatus.resolved,
        priority: CasePriority.low,
        governorate: 'الخليل',
        plaintiff: const CaseParty(
          name: 'علي سالم',
          idNumber: '987654321',
          phoneNumber: '+970-59-9876543',
          address: 'الخليل',
        ),
        filingDate: DateTime.now().subtract(const Duration(days: 60)),
        assignedTo: 'سارة أحمد',
        createdBy: 1,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }
}