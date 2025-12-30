// lib/presentation/screens/admin/documents/web_documents_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqf/core/constants/app_constants.dart';
import 'package:waqf/presentation/widgets/admin/admin_layout.dart';
import 'package:waqf/presentation/widgets/common/app_filter_chip.dart';

class WebDocumentsScreen extends ConsumerWidget {
  const WebDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const AdminLayout(
      currentRoute: '/admin/documents',
      child: DocumentsContent(),
    );
  }
}

class DocumentsContent extends ConsumerStatefulWidget {
  const DocumentsContent({super.key});

  @override
  ConsumerState<DocumentsContent> createState() => _DocumentsContentState();
}

class _DocumentsContentState extends ConsumerState<DocumentsContent> {
  String _searchQuery = '';
  String? _selectedCategory;
  String _viewMode = 'grid'; // 'grid' or 'list'

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
                  _viewMode == 'grid'
                      ? _buildDocumentsGrid()
                      : _buildDocumentsList(),
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
              'إدارة الوثائق',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppConstants.islamicGreen,
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _showUploadDialog,
              icon: const Icon(Icons.upload_file),
              label: const Text('رفع وثيقة'),
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
    return Row(
      children: [
        _buildStatCard('إجمالي الوثائق', '1,520', AppConstants.islamicGreen, Icons.folder),
        const SizedBox(width: 16),
        _buildStatCard('المضافة اليوم', '12', AppColors.info, Icons.today),
        const SizedBox(width: 16),
        _buildStatCard('المساحة المستخدمة', '2.5 GB', AppColors.warning, Icons.storage),
        const SizedBox(width: 16),
        _buildStatCard('التصنيفات', '6', AppColors.success, Icons.category),
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
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'بحث في الوثائق...',
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
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'grid',
                      icon: Icon(Icons.grid_view, size: 18),
                    ),
                    ButtonSegment(
                      value: 'list',
                      icon: Icon(Icons.list, size: 18),
                    ),
                  ],
                  selected: {_viewMode},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() => _viewMode = newSelection.first);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category ||
                    (_selectedCategory == null && category == 'الكل');

                return AppFilterChip(
                  label: category,
                  isSelected: isSelected,
                  onSelected: () {
                    setState(() {
                      _selectedCategory = category == 'الكل' ? null : category;
                    });
                  },
                  onDarkBackground: false,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsGrid() {
    final documents = _getSampleDocuments();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: documents.length,
      itemBuilder: (context, index) => _buildDocumentCard(documents[index]),
    );
  }

  Widget _buildDocumentsList() {
    final documents = _getSampleDocuments();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Column(
        children: documents.map((doc) => _buildDocumentListTile(doc)).toList(),
      ),
    );
  }

  Widget _buildDocumentCard(Map<String, dynamic> doc) {
    final icon = _getFileIcon(doc['type']);
    final color = _getFileColor(doc['type']);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: () => _viewDocument(doc),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: color.withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 40),
              ),
              const SizedBox(height: 16),
              Text(
                doc['name'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  doc['category'],
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[700],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                doc['size'],
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              PopupMenuButton(
                icon: const Icon(Icons.more_horiz, size: 20),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'view', child: Text('عرض')),
                  const PopupMenuItem(value: 'download', child: Text('تحميل')),
                  const PopupMenuItem(value: 'share', child: Text('مشاركة')),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('حذف', style: TextStyle(color: Colors.red)),
                  ),
                ],
                onSelected: (value) => _handleDocumentAction(value, doc),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentListTile(Map<String, dynamic> doc) {
    final icon = _getFileIcon(doc['type']);
    final color = _getFileColor(doc['type']);

    return InkWell(
      onTap: () => _viewDocument(doc),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        doc['category'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        ' • ',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      Text(
                        doc['size'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        ' • ',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      Text(
                        doc['date'],
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton(
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'view', child: Text('عرض')),
                const PopupMenuItem(value: 'download', child: Text('تحميل')),
                const PopupMenuItem(value: 'share', child: Text('مشاركة')),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('حذف', style: TextStyle(color: Colors.red)),
                ),
              ],
              onSelected: (value) => _handleDocumentAction(value, doc),
            ),
          ],
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

  Color _getFileColor(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'xls':
      case 'xlsx':
        return Colors.green;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _handleDocumentAction(String action, Map<String, dynamic> doc) {
    switch (action) {
      case 'view':
        _viewDocument(doc);
      case 'download':
        _downloadDocument(doc);
      case 'share':
        _shareDocument(doc);
      case 'delete':
        _deleteDocument(doc);
    }
  }

  void _viewDocument(Map<String, dynamic> doc) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('عرض ${doc['name']}')),
    );
  }

  void _downloadDocument(Map<String, dynamic> doc) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تحميل ${doc['name']}')),
    );
  }

  void _shareDocument(Map<String, dynamic> doc) {
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حذف الوثيقة')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
              onPressed: () {},
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
      {
        'name': 'مراسلة رسمية.docx',
        'category': 'مراسلات',
        'type': 'docx',
        'size': '800 KB',
        'date': '2024-01-20',
      },
      {
        'name': 'كشف حساب.xlsx',
        'category': 'تقارير',
        'type': 'xlsx',
        'size': '1.5 MB',
        'date': '2024-01-18',
      },
      {
        'name': 'صورة وثيقة.jpg',
        'category': 'وثائق رسمية',
        'type': 'jpg',
        'size': '3.2 MB',
        'date': '2024-01-12',
      },
    ];
  }
}