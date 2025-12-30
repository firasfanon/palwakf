// lib/presentation/screens/admin/systems/tasks/screens/task_form_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waqf/core/services/task_service.dart';
import 'package:waqf/data/models/task.dart';
import 'package:waqf/data/models/case.dart';
import 'package:waqf/data/models/waqf_land.dart';
import 'package:waqf/app/routing/app_routes.dart';  // ⭐ هذا السطر

class TaskFormScreen extends ConsumerStatefulWidget {
  final String? taskId;

  const TaskFormScreen({super.key, this.taskId});

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TaskService _taskService = TaskService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _titleArController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _descriptionArController = TextEditingController();

  // ✅ حالة النموذج
  TaskType _selectedType = TaskType.other;
  TaskPriority _selectedPriority = TaskPriority.medium;
  RelatedEntityType _selectedEntityType = RelatedEntityType.none;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));

  // ✅ قوائم للاختيار
  List<Case> _cases = [];
  List<WaqfLand> _waqfLands = [];
  Case? _selectedCase;
  WaqfLand? _selectedWaqfLand;

  // ✅ حالة التحميل
  bool _isLoading = true;
  bool _isSaving = false;
  Task? _existingTask;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // جلب القضايا والأراضي (مؤقتاً - تحتاج خدمات حقيقية)
      await _loadCases();
      await _loadWaqfLands();

      // إذا كان هناك taskId، جلب البيانات
      if (widget.taskId != null) {
        await _loadTaskData();
      }

      setState(() => _isLoading = false);
    } catch (e) {
      print('❌ خطأ في تحميل البيانات: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadTaskData() async {
    final task = await _taskService.getTaskById(widget.taskId!);
    if (task != null) {
      _existingTask = task;
      _titleController.text = task.title;
      _titleArController.text = task.titleAr ?? '';
      _descriptionController.text = task.description ?? '';
      _descriptionArController.text = task.descriptionAr ?? '';
      _selectedType = task.type;
      _selectedPriority = task.priority;
      _selectedEntityType = task.relatedEntityType;
      _selectedDate = task.dueDate;

      // TODO: تعيين القضية والأرض المحددة
    }
  }

  Future<void> _loadCases() async {
    // مؤقتاً: بيانات تجريبية
    await Future.delayed(const Duration(milliseconds: 500));
    _cases = [
      Case(
        id: 1,
        caseNumber: '2024/001',
        title: 'نزاع على أرض وقفية في الخليل',
        description: 'نزاع بين الورثة على ملكية الأرض',
        type: CaseType.propertyDispute,
        status: CaseStatus.inCourt,
        priority: CasePriority.high,
        governorate: 'الخليل',
        plaintiff: const CaseParty(
          name: 'أحمد محمد',
          idNumber: '800123456',
          phoneNumber: '0599123456',
          address: 'الخليل - باب الزاوية',
        ),
        assignedTo: 'مدير القضايا',
        createdBy: 1,
        filingDate: DateTime.now().subtract(const Duration(days: 30)),
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
        attachedDocuments: [],
        notes: [],
        activities: [],
        metadata: {},
      ),
      Case(
        id: 2,
        caseNumber: '2024/002',
        title: 'ميراث وقف جامع العمرية',
        description: 'توزيع إيرادات وقف جامع العمرية',
        type: CaseType.inheritance,
        status: CaseStatus.underReview,
        priority: CasePriority.medium,
        governorate: 'رام الله',
        plaintiff: const CaseParty(
          name: 'وقف جامع العمرية',
          idNumber: 'WAQF001',
          phoneNumber: '022298765',
          address: 'رام الله - وسط البلد',
        ),
        assignedTo: 'مدير الأوقاف',
        createdBy: 1,
        filingDate: DateTime.now().subtract(const Duration(days: 15)),
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now(),
        attachedDocuments: [],
        notes: [],
        activities: [],
        metadata: {},
      ),
    ];
  }

  Future<void> _loadWaqfLands() async {
    // مؤقتاً: بيانات تجريبية
    await Future.delayed(const Duration(milliseconds: 500));
    _waqfLands = [
      WaqfLand(
        id: 1,
        referenceNumber: 'WL-2024-001',
        name: 'أرض وقف الخليل - شارع السلام',
        description: 'أرض زراعية وقفية',
        type: LandType.agricultural,
        status: LandStatus.registered,
        ownershipType: OwnershipType.waqfKhayri,
        area: 5000,
        governorate: 'الخليل',
        city: 'الخليل',
        district: 'باب الزاوية',
        address: 'شارع السلام - مقابل المستشفى',
        location: const LandLocation(latitude: 31.5326, longitude: 35.0998),
        documentation: const LandDocumentation(),
        registeredBy: 'مدير الأوقاف',
        registrationDate: DateTime.now().subtract(const Duration(days: 365)),
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        updatedAt: DateTime.now(),
        documents: [],
        images: [],
        metadata: {},
      ),
      WaqfLand(
        id: 2,
        referenceNumber: 'WL-2024-002',
        name: 'عقار وقف رام الله - وسط البلد',
        description: 'عقار تجاري وقفي',
        type: LandType.commercial,
        status: LandStatus.leased,
        ownershipType: OwnershipType.waqfKhayri,
        area: 800,
        governorate: 'رام الله',
        city: 'رام الله',
        district: 'وسط البلد',
        address: 'وسط البلد - بجانب البلدية',
        location: const LandLocation(latitude: 31.9029, longitude: 35.2062),
        documentation: const LandDocumentation(),
        registeredBy: 'مدير الأوقاف',
        registrationDate: DateTime.now().subtract(const Duration(days: 180)),
        createdAt: DateTime.now().subtract(const Duration(days: 180)),
        updatedAt: DateTime.now(),
        documents: [],
        images: [],
        metadata: {},
      ),
    ];
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      // ✅ تحضير بيانات المهمة
      final taskData = {
        'title': _titleController.text.trim(),
        'title_ar': _titleArController.text.trim(),
        'description': _descriptionController.text.trim(),
        'description_ar': _descriptionArController.text.trim(),
        'type': _selectedType.toString().split('.').last,
        'priority': _selectedPriority.toString().split('.').last,
        'related_entity_type': _selectedEntityType.toString().split('.').last,
        'due_date': _selectedDate.toIso8601String(),
        'case_id': _selectedCase?.id,
        'waqf_land_id': _selectedWaqfLand?.id,
        'progress_percentage': 0,
        'requires_approval': false,
        'followup_required': false,
        'created_by': 'current_user_id', // TODO: استبدال بمعرف المستخدم الحقيقي
      };

      Task? savedTask;

      if (widget.taskId != null) {
        // تحديث المهمة الموجودة
        savedTask = await _taskService.updateTask(widget.taskId!, taskData);
      } else {
        // إنشاء مهمة جديدة
        savedTask = await _taskService.createTask(taskData);
      }

      if (savedTask != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.taskId != null
                ? '✅ تم تحديث المهمة بنجاح'
                : '✅ تم إنشاء المهمة بنجاح'),
            backgroundColor: Colors.green,
          ),
        );

        // العودة للشاشة السابقة بعد تأخير بسيط
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.pop(context, savedTask);
        });
      } else {
        throw Exception('فشل في حفظ المهمة');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ حدث خطأ: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.green,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  void _showCourtVisitFields() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('معلومات الزيارة القضائية'),
          content: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('سيتم إضافة هذه الميزة في المرحلة القادمة'),
                SizedBox(height: 10),
                Text('(معلومات المحكمة، القاضي، تاريخ الجلسة)'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('موافق'),
            ),
          ],
        );
      },
    );
  }

  void _showSiteInspectionFields() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('معلومات التفتيش الميداني'),
          content: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('سيتم إضافة هذه الميزة في المرحلة القادمة'),
                SizedBox(height: 10),
                Text('(نوع التفتيش، حالة التحقق، تفاصيل التعدي)'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('موافق'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _titleArController.dispose();
    _descriptionController.dispose();
    _descriptionArController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('تحميل...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.taskId != null ? 'تعديل المهمة' : 'إضافة مهمة جديدة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveTask,
            tooltip: 'حفظ',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ القسم 1: المعلومات الأساسية
              _buildSectionTitle('المعلومات الأساسية'),

              // العنوان (إنجليزي)
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'عنوان المهمة (إنجليزي)',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'الرجاء إدخال عنوان المهمة';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              // العنوان (عربي)
              TextFormField(
                controller: _titleArController,
                decoration: const InputDecoration(
                  labelText: 'عنوان المهمة (عربي)',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 12),

              // الوصف
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'الوصف',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 12),

              // الوصف (عربي)
              TextFormField(
                controller: _descriptionArController,
                decoration: const InputDecoration(
                  labelText: 'الوصف (عربي)',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 16),

              // نوع المهمة
              DropdownButtonFormField<TaskType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'نوع المهمة',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: TaskType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.typeDisplayName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedType = value);

                    // عرض حقول إضافية حسب النوع
                    if (value == TaskType.courtVisit) {
                      _showCourtVisitFields();
                    } else if (value == TaskType.siteInspection) {
                      _showSiteInspectionFields();
                    }
                  }
                },
              ),

              const SizedBox(height: 12),

              // الأولوية
              DropdownButtonFormField<TaskPriority>(
                value: _selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'الأولوية',
                  prefixIcon: Icon(Icons.flag),
                  border: OutlineInputBorder(),
                ),
                items: TaskPriority.values.map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(priority.priorityDisplayName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedPriority = value);
                  }
                },
              ),

              const SizedBox(height: 12),

              // تاريخ الاستحقاق
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'تاريخ الاستحقاق',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ✅ القسم 2: الربط مع الأنظمة
              _buildSectionTitle('الربط مع الأنظمة'),

              // نوع الكيان المرتبط
              DropdownButtonFormField<RelatedEntityType>(
                value: _selectedEntityType,
                decoration: const InputDecoration(
                  labelText: 'نوع الكيان المرتبط',
                  prefixIcon: Icon(Icons.link),
                  border: OutlineInputBorder(),
                ),
                items: RelatedEntityType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedEntityType = value);
                  }
                },
              ),

              const SizedBox(height: 12),

              // اختيار قضية (يظهر عند اختيار قضية أو both)
              if (_selectedEntityType == RelatedEntityType.caseEntity ||
                  _selectedEntityType == RelatedEntityType.both)
                DropdownButtonFormField<Case?>(
                  value: _selectedCase,
                  decoration: const InputDecoration(
                    labelText: 'اختر قضية',
                    prefixIcon: Icon(Icons.gavel),
                    border: OutlineInputBorder(),
                  ),
                  hint: const Text('اختر قضية'),
                  items: [
                    const DropdownMenuItem<Case?>(
                      value: null,
                      child: Text('لا شيء'),
                    ),
                    ..._cases.map((caseItem) {
                      return DropdownMenuItem<Case?>(
                        value: caseItem,
                        child: SizedBox(
                          width: double.infinity,
                          child: Text(
                            '${caseItem.caseNumber} - ${caseItem.title}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedCase = value);
                  },
                ),

              if ((_selectedEntityType == RelatedEntityType.caseEntity ||
                  _selectedEntityType == RelatedEntityType.both) &&
                  _selectedCase != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 8),
                  child: Text(
                    'الحالة: ${_selectedCase!.status.displayName} | الأولوية: ${_selectedCase!.priority.displayName}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),

              const SizedBox(height: 12),

              // اختيار أرض وقفية (يظهر عند اختيار waqf_land أو both)
              if (_selectedEntityType == RelatedEntityType.waqfLand ||
                  _selectedEntityType == RelatedEntityType.both)
                DropdownButtonFormField<WaqfLand?>(
                  value: _selectedWaqfLand,
                  decoration: const InputDecoration(
                    labelText: 'اختر أرض وقفية',
                    prefixIcon: Icon(Icons.landscape),
                    border: OutlineInputBorder(),
                  ),
                  hint: const Text('اختر أرض وقفية'),
                  items: [
                    const DropdownMenuItem<WaqfLand?>(
                      value: null,
                      child: Text('لا شيء'),
                    ),
                    ..._waqfLands.map((land) {
                      return DropdownMenuItem<WaqfLand?>(
                        value: land,
                        child: SizedBox(
                          width: double.infinity,
                          child: Text(
                            '${land.referenceNumber} - ${land.name}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedWaqfLand = value);
                  },
                ),

              if ((_selectedEntityType == RelatedEntityType.waqfLand ||
                  _selectedEntityType == RelatedEntityType.both) &&
                  _selectedWaqfLand != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 8),
                  child: Text(
                    'النوع: ${_selectedWaqfLand!.type.displayName} | المساحة: ${_selectedWaqfLand!.area} م²',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),

              const SizedBox(height: 24),

              // ✅ رسالة تأكيد
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.taskId != null
                            ? 'سيتم تحديث المهمة الحالية'
                            : 'سيتم إنشاء مهمة جديدة في النظام',
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ✅ زر الحفظ الرئيسي
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveTask,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                  ),
                  icon: _isSaving
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(Icons.save),
                  label: Text(
                    _isSaving
                        ? 'جاري الحفظ...'
                        : widget.taskId != null
                        ? 'تحديث المهمة'
                        : 'إنشاء المهمة',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      ),
    );
  }
}