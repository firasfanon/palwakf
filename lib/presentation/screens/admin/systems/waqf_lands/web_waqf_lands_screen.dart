// lib/presentation/screens/admin/waqf_lands/web_waqf_lands_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqf/core/constants/app_constants.dart';
import 'package:waqf/data/models/waqf_land.dart';
import 'package:waqf/presentation/widgets/admin/admin_layout.dart';


class WebWaqfLandsScreen extends ConsumerWidget {
  const WebWaqfLandsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const AdminLayout(
      currentRoute: '/admin/waqf-lands',
      child: WaqfLandsContent(),
    );
  }
}

class WaqfLandsContent extends ConsumerStatefulWidget {
  const WaqfLandsContent({super.key});

  @override
  ConsumerState<WaqfLandsContent> createState() => _WaqfLandsContentState();
}

class _WaqfLandsContentState extends ConsumerState<WaqfLandsContent> {
  String _searchQuery = '';
  LandStatus? _selectedStatus;
  String? _selectedGovernorate;

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
                  _buildLandsTable(),
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
              'الأراضي الوقفية',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppConstants.islamicGreen,
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _showAddLandDialog,
              icon: const Icon(Icons.add_location),
              label: const Text('تسجيل أرض'),
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
    final lands = _getSampleLands();
    final totalLands = lands.length;
    final registered = lands.where((l) => l.status == LandStatus.registered).length;
    final disputed = lands.where((l) => l.status == LandStatus.disputed).length;
    final totalArea = lands.fold(0.0, (sum, land) => sum + land.area);

    return Row(
      children: [
        _buildStatCard('إجمالي الأراضي', totalLands.toString(), AppConstants.islamicGreen, Icons.landscape),
        const SizedBox(width: 16),
        _buildStatCard('مسجلة', registered.toString(), AppColors.success, Icons.check_circle),
        const SizedBox(width: 16),
        _buildStatCard('متنازع عليها', disputed.toString(), AppColors.warning, Icons.warning),
        const SizedBox(width: 16),
        _buildStatCard('المساحة الإجمالية', '${totalArea.toStringAsFixed(0)} م²', AppColors.info, Icons.square_foot),
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
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
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
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'بحث في الأراضي...',
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
              child: DropdownButtonFormField<String>(
                initialValue: _selectedGovernorate,
                decoration: InputDecoration(
                  labelText: 'المحافظة',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('الكل')),
                  ...AppConstants.governorates.map(
                        (g) => DropdownMenuItem(value: g, child: Text(g)),
                  ),
                ],
                onChanged: (value) => setState(() => _selectedGovernorate = value),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<LandStatus>(
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
                  ...LandStatus.values.map(
                        (s) => DropdownMenuItem(value: s, child: Text(s.displayName)),
                  ),
                ],
                onChanged: (value) => setState(() => _selectedStatus = value),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLandsTable() {
    final lands = _getSampleLands();

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
                Expanded(flex: 2, child: _buildTableHeader('الرقم المرجعي')),
                Expanded(flex: 3, child: _buildTableHeader('الاسم')),
                Expanded(flex: 2, child: _buildTableHeader('المحافظة')),
                Expanded(flex: 2, child: _buildTableHeader('النوع')),
                Expanded(flex: 2, child: _buildTableHeader('المساحة')),
                Expanded(flex: 2, child: _buildTableHeader('الحالة')),
                const SizedBox(width: 50, child: Text('')),
              ],
            ),
          ),
          ...lands.map((land) => _buildTableRow(land)),
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

  Widget _buildTableRow(WaqfLand land) {
    return InkWell(
      onTap: () => _showLandDetails(land),
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
                land.referenceNumber,
                style: const TextStyle(
                  color: AppConstants.islamicGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(flex: 3, child: Text(land.name)),
            Expanded(flex: 2, child: Text(land.governorate)),
            Expanded(flex: 2, child: Text(land.type.displayName)),
            Expanded(flex: 2, child: Text('${land.area.toStringAsFixed(0)} م²')),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(land.status).withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  land.status.displayName,
                  style: TextStyle(
                    color: _getStatusColor(land.status),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(
              width: 50,
              child: IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showLandDetails(land),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(LandStatus status) {
    switch (status) {
      case LandStatus.registered:
        return AppColors.success;
      case LandStatus.disputed:
        return AppColors.warning;
      case LandStatus.occupied:
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }

  void _showLandDetails(WaqfLand land) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700, maxHeight: 600),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppConstants.islamicGreen,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.landscape, color: Colors.white, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            land.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            land.referenceNumber,
                            style: const TextStyle(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.map),
                          label: const Text('عرض على الخريطة'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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

  void _showAddLandDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل أرض وقفية'),
        content: const Text('سيتم إضافة نموذج تسجيل أرض جديدة هنا'),
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
      WaqfLand(
        id: 2,
        referenceNumber: 'WL-2024-002',
        name: 'أرض زراعية في نابلس',
        type: LandType.agricultural,
        status: LandStatus.registered,
        ownershipType: OwnershipType.waqfAhli,
        area: 8000,
        governorate: 'نابلس',
        city: 'نابلس',
        district: 'البلدة القديمة',
        address: 'شارع فيصل',
        location: const LandLocation(latitude: 32.2211, longitude: 35.2544),
        documentation: const LandDocumentation(deedNumber: '67890', hasOfficialDocuments: true),
        registrationDate: DateTime.now().subtract(const Duration(days: 200)),
        registeredBy: 'فاطمة علي',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      WaqfLand(
        id: 3,
        referenceNumber: 'WL-2024-003',
        name: 'أرض تجارية في رام الله',
        type: LandType.commercial,
        status: LandStatus.disputed,
        ownershipType: OwnershipType.waqfKhayri,
        area: 3000,
        governorate: 'رام الله',
        city: 'رام الله',
        district: 'المصيون',
        address: 'شارع الإرسال',
        location: const LandLocation(latitude: 31.9038, longitude: 35.2034),
        documentation: const LandDocumentation(deedNumber: '11111', hasOfficialDocuments: true),
        registrationDate: DateTime.now().subtract(const Duration(days: 100)),
        registeredBy: 'محمد خالد',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }
}