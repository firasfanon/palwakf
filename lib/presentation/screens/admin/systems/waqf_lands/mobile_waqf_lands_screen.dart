import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqf/core/constants/app_constants.dart';
import 'package:waqf/data/models/waqf_land.dart';
import 'package:waqf/presentation/widgets/common/custom_app_bar.dart';


class MobileWaqfLandsScreen extends ConsumerStatefulWidget {
  const MobileWaqfLandsScreen({super.key});

  @override
  ConsumerState<MobileWaqfLandsScreen> createState() => _WaqfLandsScreenState();
}

class _WaqfLandsScreenState extends ConsumerState<MobileWaqfLandsScreen> {
  String _searchQuery = '';
  LandStatus? _selectedStatus;
  String? _selectedGovernorate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'الأراضي الوقفية',
      ),
      body: Column(
        children: [
          _buildFilters(),
          _buildStatistics(),
          Expanded(child: _buildLandsList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddLandDialog,
        icon: const Icon(Icons.add_location),
        label: const Text('تسجيل أرض'),
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
          TextField(
            decoration: InputDecoration(
              hintText: 'بحث في الأراضي...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedGovernorate,
                  decoration: const InputDecoration(labelText: 'المحافظة'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('الكل')),
                    ...AppConstants.governorates.map((g) => DropdownMenuItem(value: g, child: Text(g))),
                  ],
                  onChanged: (value) => setState(() => _selectedGovernorate = value),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<LandStatus>(
                  initialValue: _selectedStatus,
                  decoration: const InputDecoration(labelText: 'الحالة'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('الكل')),
                    ...LandStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.displayName))),
                  ],
                  onChanged: (value) => setState(() => _selectedStatus = value),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      child: Row(
        children: [
          Expanded(child: _buildStatCard('إجمالي الأراضي', '128', AppColors.islamicGreen)),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard('مسجلة', '98', AppColors.success)),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard('متنازع عليها', '12', AppColors.warning)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        child: Column(
          children: [
            Text(value, style: AppTextStyles.headlineSmall.copyWith(color: color, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildLandsList() {
    final lands = _getSampleLands();
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      itemCount: lands.length,
      itemBuilder: (context, index) => _buildLandCard(lands[index]),
    );
  }

  Widget _buildLandCard(WaqfLand land) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
      child: InkWell(
        onTap: () => _showLandDetails(land),
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
                        Text(land.referenceNumber, style: AppTextStyles.labelLarge.copyWith(color: AppColors.islamicGreen)),
                        const SizedBox(height: 4),
                        Text(land.name, style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Chip(
                    label: Text(land.status.displayName),
                    backgroundColor: _getStatusColor(land.status).withValues(alpha:0.1),
                    labelStyle: TextStyle(color: _getStatusColor(land.status)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text('${land.city}, ${land.governorate}', style: AppTextStyles.bodySmall),
                  const Spacer(),
                  Icon(Icons.square_foot, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text('${land.area.toStringAsFixed(0)} م²', style: AppTextStyles.bodySmall),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Chip(label: Text(land.type.displayName), backgroundColor: AppColors.surfaceVariant),
                  const SizedBox(width: 8),
                  Chip(label: Text(land.ownershipType.displayName), backgroundColor: AppColors.surfaceVariant),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(LandStatus status) {
    switch (status) {
      case LandStatus.registered: return AppColors.success;
      case LandStatus.disputed: return AppColors.warning;
      case LandStatus.occupied: return AppColors.error;
      default: return AppColors.info;
    }
  }

  void _showLandDetails(WaqfLand land) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          child: ListView(
            controller: scrollController,
            children: [
              Text(land.name, style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(land.referenceNumber, style: AppTextStyles.titleMedium.copyWith(color: AppColors.islamicGreen)),
              const Divider(height: 24),
              _buildDetailRow('النوع', land.type.displayName),
              _buildDetailRow('الحالة', land.status.displayName),
              _buildDetailRow('نوع الملكية', land.ownershipType.displayName),
              _buildDetailRow('المساحة', '${land.area} متر مربع'),
              _buildDetailRow('المحافظة', land.governorate),
              _buildDetailRow('المدينة', land.city),
              _buildDetailRow('الحي', land.district),
              _buildDetailRow('العنوان', land.address),
              if (land.documentation.deedNumber != null)
                _buildDetailRow('رقم السند', land.documentation.deedNumber!),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.map),
                label: const Text('عرض على الخريطة'),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text('$label:', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }

  void _showAddLandDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل أرض وقفية'),
        content: const Text('سيتم إضافة نموذج تسجيل أرض جديدة هنا'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('إضافة')),
        ],
      ),
    );
  }

  List<WaqfLand> _getSampleLands() {
    return [
      WaqfLand(
        id: 1,
        referenceNumber: 'WL-2024-001',
        name: 'أرض وقف المسجد الكبير',
        type: LandType.residential,
        status: LandStatus.registered,
        ownershipType: OwnershipType.waqfKhayri,
        area: 5000,
        governorate: 'القدس',
        city: 'القدس',
        district: 'البلدة القديمة',
        address: 'بالقرب من المسجد الأقصى',
        location: const LandLocation(latitude: 31.7767, longitude: 35.2345),
        documentation: const LandDocumentation(deedNumber: '12345', hasOfficialDocuments: true),
        registrationDate: DateTime.now().subtract(const Duration(days: 365)),
        registeredBy: 'أحمد محمد',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }
}