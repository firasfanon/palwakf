// lib/core/services/task_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:waqf/data/models/task.dart';
import 'package:waqf/data/models/case.dart';
import 'package:waqf/data/models/waqf_land.dart';

class TaskService {
  final SupabaseClient _supabase;

  TaskService() : _supabase = Supabase.instance.client;

  // ✅ جلب جميع المهام (نسخة مبسطة تعمل)
  Future<List<Task>> getTasks() async {
    try {
      final response = await _supabase
          .from('tasks')
          .select()
          .order('created_at', ascending: false)
          .limit(50);

      final data = response as List<dynamic>;
      return data.map((json) => _taskFromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      print('❌ خطأ في جلب المهام: $e');
      return [];
    }
  }

  // ✅ جلب مهمة محددة
  Future<Task?> getTaskById(String taskId) async {
    try {
      final response = await _supabase
          .from('tasks')
          .select()
          .eq('id', taskId)
          .maybeSingle();

      if (response == null) return null;
      final data = response as Map<String, dynamic>;
      return _taskFromJson(data);
    } catch (e) {
      print('❌ خطأ في جلب المهمة $taskId: $e');
      return null;
    }
  }

  // ✅ إنشاء مهمة جديدة
  Future<Task?> createTask(Map<String, dynamic> taskData) async {
    try {
      final response = await _supabase
          .from('tasks')
          .insert(taskData)
          .select()
          .single();

      final data = response as Map<String, dynamic>;
      return _taskFromJson(data);
    } catch (e) {
      print('❌ خطأ في إنشاء المهمة: $e');
      return null;
    }
  }

  // ✅ تحديث مهمة
  Future<Task?> updateTask(String taskId, Map<String, dynamic> updates) async {
    try {
      final response = await _supabase
          .from('tasks')
          .update(updates)
          .eq('id', taskId)
          .select()
          .single();

      final data = response as Map<String, dynamic>;
      return _taskFromJson(data);
    } catch (e) {
      print('❌ خطأ في تحديث المهمة $taskId: $e');
      return null;
    }
  }

  // ✅ حذف مهمة
  Future<bool> deleteTask(String taskId) async {
    try {
      await _supabase.from('tasks').delete().eq('id', taskId);
      return true;
    } catch (e) {
      print('❌ خطأ في حذف المهمة $taskId: $e');
      return false;
    }
  }

  // ✅ تحويل JSON إلى Task
  Task _taskFromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      titleAr: json['title_ar'],
      descriptionAr: json['description_ar'],
      type: _stringToTaskType(json['type']),
      status: _stringToTaskStatus(json['status']),
      priority: _stringToTaskPriority(json['priority']),
      dueDate: DateTime.parse(json['due_date'] ?? DateTime.now().toIso8601String()),
      completionDate: json['completion_date'] != null
          ? DateTime.parse(json['completion_date'])
          : null,
      caseId: json['case_id'],
      caseReferenceNumber: json['case_reference_number'],
      linkedCase: null,
      waqfLandId: json['waqf_land_id'],
      waqfLandRegistryId: json['waqf_land_registry_id'],
      linkedWaqfLand: null,
      relatedEntityType: _stringToRelatedEntityType(json['related_entity_type']),
      courtName: json['court_name'],
      courtNameAr: json['court_name_ar'],
      judgeName: json['judge_name'],
      judgeNameAr: json['judge_name_ar'],
      courtHearingDate: json['court_hearing_date'] != null
          ? DateTime.parse(json['court_hearing_date'])
          : null,
      courtHearingTime: json['court_hearing_time'],
      visitPurpose: json['visit_purpose'],
      visitPurposeAr: json['visit_purpose_ar'],
      siteInspectionType: _stringToSiteInspectionType(json['site_inspection_type']),
      boundaryVerificationStatus: json['boundary_verification_status'],
      encroachmentDetails: json['encroachment_details'],
      encroachmentDetailsAr: json['encroachment_details_ar'],
      preservationStatus: json['preservation_status'],
      durationMinutes: json['duration_minutes'],
      requiresApproval: json['requires_approval'],
      progressPercentage: json['progress_percentage'],
      assignedTo: List<String>.from(json['assigned_to'] ?? []),
      estimatedHours: json['estimated_hours']?.toDouble(),
      actualHours: json['actual_hours']?.toDouble(),
      followupRequired: json['followup_required'],
      followupDeadline: json['followup_deadline'] != null
          ? DateTime.parse(json['followup_deadline'])
          : null,
      createdBy: json['created_by'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  // ✅ دوال مساعدة للتحويل
  TaskType _stringToTaskType(String? type) {
    if (type == null) return TaskType.other;

    switch (type) {
      case 'court_visit': return TaskType.courtVisit;
      case 'site_inspection': return TaskType.siteInspection;
      case 'document_followup': return TaskType.documentFollowup;
      case 'meeting': return TaskType.meeting;
      case 'administrative': return TaskType.administrative;
      default: return TaskType.other;
    }
  }

  TaskStatus _stringToTaskStatus(String? status) {
    if (status == null) return TaskStatus.newTask;

    switch (status) {
      case 'in_progress': return TaskStatus.inProgress;
      case 'under_action': return TaskStatus.underAction;
      case 'completed': return TaskStatus.completed;
      case 'cancelled': return TaskStatus.cancelled;
      default: return TaskStatus.newTask;
    }
  }

  TaskPriority _stringToTaskPriority(String? priority) {
    if (priority == null) return TaskPriority.medium;

    switch (priority) {
      case 'low': return TaskPriority.low;
      case 'high': return TaskPriority.high;
      case 'urgent': return TaskPriority.urgent;
      default: return TaskPriority.medium;
    }
  }

  RelatedEntityType _stringToRelatedEntityType(String? type) {
    if (type == null) return RelatedEntityType.none;

    switch (type) {
      case 'case': return RelatedEntityType.caseEntity;
      case 'waqf_land': return RelatedEntityType.waqfLand;
      case 'both': return RelatedEntityType.both;
      default: return RelatedEntityType.none;
    }
  }

  SiteInspectionType? _stringToSiteInspectionType(String? type) {
    if (type == null) return null;

    switch (type) {
      case 'initial': return SiteInspectionType.initial;
      case 'followup': return SiteInspectionType.followup;
      case 'routine': return SiteInspectionType.routine;
      case 'emergency': return SiteInspectionType.emergency;
      default: return null;
    }
  }

  // ✅ دوال مساعدة للتحويل العكسي
  String _taskStatusToString(TaskStatus status) {
    return status.toString().split('.').last;
  }

  String _taskPriorityToString(TaskPriority priority) {
    return priority.toString().split('.').last;
  }
}