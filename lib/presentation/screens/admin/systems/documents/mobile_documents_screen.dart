import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqf/core/constants/app_constants.dart';
import 'package:waqf/presentation/widgets/common/custom_app_bar.dart';


class MobileDocumentsScreen extends ConsumerStatefulWidget {
  const MobileDocumentsScreen({super.key});

  @override
  ConsumerState<MobileDocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<MobileDocumentsScreen> {
  String _searchQuery = '';
  String? _selectedCategory;

  final List<String> _categories = [
    'الكل',
    'عقود',
    'قرارات',
    'وثائق رسمية',
    'مراسلات',
    'تقارير',
    'أخرى',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'إدارة الوثائق',
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(child: _buildDocumentsList()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showUploadDialog,
        icon: const Icon(Icons.upload_file),
        label: const Text('رفع وثيقة'),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
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
              hintText: 'بحث في الوثائق...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category ||
                    (_selectedCategory == null && category == 'الكل');

                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category == 'الكل' ? null : category;
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsList() {
    final documents = _getSampleDocuments();

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      itemCount: documents.length,
      itemBuilder: (context, index) {
        return _buildDocumentCard(documents[index]);
      },
    );
  }

  Widget _buildDocumentCard(Map<String, dynamic> doc) {
    final icon = _getFileIcon(doc['type']);

    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.islamicGreen.withValues(alpha:0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.islamicGreen),
        ),
        title: Text(
          doc['name'],
          style: AppTextStyles.titleSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              doc['category'],
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: 2),
            Text(
              '${doc['size']} • ${doc['date']}',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility),
                  SizedBox(width: 8),
                  Text('عرض'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'download',
              child: Row(
                children: [
                  Icon(Icons.download),
                  SizedBox(width: 8),
                  Text('تحميل'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share),
                  SizedBox(width: 8),
                  Text('مشاركة'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('حذف', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) => _handleDocumentAction(value, doc),
        ),
      ),
    );
  }

  IconData _getFileIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  void _handleDocumentAction(String action, Map<String, dynamic> doc) {
    switch (action) {
      case 'view':
        _viewDocument(doc);
        break;
      case 'download':
        _downloadDocument(doc);
        break;
      case 'share':
        _shareDocument(doc);
        break;
      case 'delete':
        _deleteDocument(doc);
        break;
    }
  }

  void _viewDocument(Map<String, dynamic> doc) {
    // TODO: Implement document viewing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('عرض ${doc['name']}')),
    );
  }

  void _downloadDocument(Map<String, dynamic> doc) {
    // TODO: Implement document download
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تحميل ${doc['name']}')),
    );
  }

  void _shareDocument(Map<String, dynamic> doc) {
    // TODO: Implement document sharing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('مشاركة ${doc['name']}')),
    );
  }

  void _deleteDocument(Map<String, dynamic> doc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف ${doc['name']}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement delete
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حذف الوثيقة')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showUploadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('رفع وثيقة جديدة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('اختر ملف لرفعه'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement file picker
              },
              icon: const Icon(Icons.file_upload),
              label: const Text('اختيار ملف'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getSampleDocuments() {
    return [
      {
        'name': 'عقد إيجار أرض وقفية.pdf',
        'category': 'عقود',
        'type': 'pdf',
        'size': '2.5 MB',
        'date': '2024-01-15',
      },
      {
        'name': 'قرار وزاري رقم 123.docx',
        'category': 'قرارات',
        'type': 'docx',
        'size': '1.2 MB',
        'date': '2024-01-10',
      },
      {
        'name': 'تقرير سنوي 2023.pdf',
        'category': 'تقارير',
        'type': 'pdf',
        'size': '5.8 MB',
        'date': '2024-01-05',
      },
    ];
  }
}