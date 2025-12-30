import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqf/core/constants/app_constants.dart';
import 'package:waqf/data/models/case.dart';
import 'package:waqf/presentation/widgets/common/custom_app_bar.dart';

class MobileCasesScreen extends ConsumerStatefulWidget {
  const MobileCasesScreen({super.key});

  @override
  ConsumerState<MobileCasesScreen> createState() => _CasesScreenState();
}

class _CasesScreenState extends ConsumerState<MobileCasesScreen> {
  CaseStatus? _selectedStatus;
  CasePriority? _selectedPriority;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'إدارة القضايا',
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(child: _buildCasesList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCaseDialog,
        icon: const Icon(Icons.add),
        label: const Text('قضية جديدة'),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search field
          TextField(
            decoration: InputDecoration(
              hintText: 'بحث في القضايا...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingM,
                vertical: AppConstants.paddingS,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 12),

          // Filters
          Row(
            children: [
              Expanded(
                child: _buildStatusFilter(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPriorityFilter(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    return DropdownButtonFormField<CaseStatus>(
      initialValue: _selectedStatus,
      decoration: InputDecoration(
        labelText: 'الحالة',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingM,
          vertical: AppConstants.paddingS,
        ),
      ),
      items: [
        const DropdownMenuItem(
          value: null,
          child: Text('الكل'),
        ),
        ...CaseStatus.values.map((status) {
          return DropdownMenuItem(
            value: status,
            child: Text(status.displayName),
          );
        }),
      ],
      onChanged: (value) {
        setState(() {
          _selectedStatus = value;
        });
      },
    );
  }

  Widget _buildPriorityFilter() {
    return DropdownButtonFormField<CasePriority>(
      initialValue: _selectedPriority,
      decoration: InputDecoration(
        labelText: 'الأولوية',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingM,
          vertical: AppConstants.paddingS,
        ),
      ),
      items: [
        const DropdownMenuItem(
          value: null,
          child: Text('الكل'),
        ),
        ...CasePriority.values.map((priority) {
          return DropdownMenuItem(
            value: priority,
            child: Text(priority.displayName),
          );
        }),
      ],
      onChanged: (value) {
        setState(() {
          _selectedPriority = value;
        });
      },
    );
  }

  Widget _buildCasesList() {
    // TODO: Replace with actual data provider
    final cases = _getSampleCases();
    final filteredCases = _filterCases(cases);

    if (filteredCases.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.gavel,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد قضايا',
              style: AppTextStyles.titleMedium.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      itemCount: filteredCases.length,
      itemBuilder: (context, index) {
        return _buildCaseCard(filteredCases[index]);
      },
    );
  }

  Widget _buildCaseCard(Case caseItem) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
      child: InkWell(
        onTap: () => _showCaseDetails(caseItem),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          child: Column(
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
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.islamicGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          caseItem.title,
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildPriorityBadge(caseItem.priority),
                ],
              ),
              const SizedBox(height: 12),

              Text(
                caseItem.description,
                style: AppTextStyles.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  _buildStatusChip(caseItem.status),
                  const SizedBox(width: 8),
                  _buildTypeChip(caseItem.type),
                  const Spacer(),
                  Text(
                    caseItem.filingDate.toString().split(' ')[0],
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(CasePriority priority) {
    Color color;
    switch (priority) {
      case CasePriority.critical:
        color = Colors.red;
        break;
      case CasePriority.urgent:
        color = Colors.orange;
        break;
      case CasePriority.high:
        color = AppColors.warning;
        break;
      case CasePriority.medium:
        color = AppColors.info;
        break;
      case CasePriority.low:
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        priority.displayName,
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusChip(CaseStatus status) {
    return Chip(
      label: Text(status.displayName),
      backgroundColor: AppColors.islamicGreen.withValues(alpha:0.1),
      labelStyle: AppTextStyles.labelSmall.copyWith(
        color: AppColors.islamicGreen,
      ),
    );
  }

  Widget _buildTypeChip(CaseType type) {
    return Chip(
      label: Text(type.displayName),
      backgroundColor: AppColors.surfaceVariant,
      labelStyle: AppTextStyles.labelSmall,
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
      builder: (context) => AlertDialog(
        title: Text(caseItem.caseNumber),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                caseItem.title,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(caseItem.description),
              const SizedBox(height: 16),
              _buildDetailRow('النوع', caseItem.type.displayName),
              _buildDetailRow('الحالة', caseItem.status.displayName),
              _buildDetailRow('الأولوية', caseItem.priority.displayName),
              _buildDetailRow('المحافظة', caseItem.governorate),
              _buildDetailRow('المدعي', caseItem.plaintiff.name),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to edit screen
            },
            child: const Text('تعديل'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium,
            ),
          ),
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
            onPressed: () {
              Navigator.pop(context);
              // TODO: Handle case creation
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  // Sample data
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
    ];
  }
}