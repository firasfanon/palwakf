import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:waqf/features/platform/public_runtime/domain/pwf_service_center_runtime_source_closure_contract.dart';

class PwfServiceFormOption {
  const PwfServiceFormOption({
    required this.formKey,
    required this.titleAr,
    required this.serviceKey,
    required this.audience,
    this.versionNo = '1.0',
    this.sourceReference,
    this.requiredAttachments = const [],
    this.rpcBacked = false,
  });

  final String formKey;
  final String titleAr;
  final String serviceKey;
  final String audience;
  final String versionNo;
  final String? sourceReference;
  final List<String> requiredAttachments;
  final bool rpcBacked;

  static const fallback = [
    PwfServiceFormOption(
      formKey: 'general_service_request_v1',
      titleAr: 'نموذج طلب خدمة عامة',
      serviceKey: 'general_service',
      audience: 'public',
      requiredAttachments: [
        'إثبات شخصية عند الحاجة',
        'مرفقات داعمة حسب نوع الخدمة',
      ],
    ),
    PwfServiceFormOption(
      formKey: 'certificate_request_v1',
      titleAr: 'نموذج طلب إفادة',
      serviceKey: 'document_certificate',
      audience: 'public',
      requiredAttachments: ['إثبات شخصية', 'بيانات المرجع أو العقار إن وجدت'],
    ),
    PwfServiceFormOption(
      formKey: 'transaction_followup_v1',
      titleAr: 'نموذج متابعة معاملة',
      serviceKey: 'request_followup',
      audience: 'public',
      requiredAttachments: ['رقم متابعة سابق إن وجد'],
    ),
    PwfServiceFormOption(
      formKey: 'feedback_notice_v1',
      titleAr: 'نموذج ملاحظة أو بلاغ',
      serviceKey: 'complaint_feedback',
      audience: 'public',
      requiredAttachments: ['صور أو مستندات داعمة إن وجدت'],
    ),
  ];

  factory PwfServiceFormOption.fromRpcRow(Map<String, dynamic> row) {
    return PwfServiceFormOption(
      formKey: (row['form_key'] ?? '').toString(),
      titleAr: (row['title_ar'] ?? '').toString(),
      serviceKey: (row['service_key'] ?? '').toString(),
      audience: (row['audience'] ?? 'public').toString(),
      versionNo: (row['version_no'] ?? '1.0').toString(),
      sourceReference: row['source_reference']?.toString(),
      requiredAttachments: _jsonbTextList(row['required_attachments']),
      rpcBacked: true,
    );
  }

  static List<String> _jsonbTextList(dynamic value) {
    if (value is List) {
      return [for (final item in value) item.toString()];
    }
    return const [];
  }
}

class PwfServiceRequestSubmitDraft {
  const PwfServiceRequestSubmitDraft({
    required this.requesterName,
    required this.requesterContact,
    required this.requesterTypeAr,
    required this.serviceLabelAr,
    required this.formTitleAr,
    required this.requestSummary,
    required this.unitSlug,
    required this.formOptions,
  });

  final String requesterName;
  final String requesterContact;
  final String requesterTypeAr;
  final String serviceLabelAr;
  final String formTitleAr;
  final String requestSummary;
  final String unitSlug;
  final List<PwfServiceFormOption> formOptions;

  Map<String, dynamic> toRpcPayload() {
    final form = selectedForm;
    return {
      'requester_type': _requesterTypeKey(requesterTypeAr),
      'requester_name': requesterName.trim(),
      'requester_contact': requesterContact.trim(),
      'service_key': form?.serviceKey ?? _serviceKey(serviceLabelAr),
      'form_key': form?.formKey ?? _formKey(formTitleAr),
      'request_summary': requestSummary.trim(),
      'unit_slug': unitSlug,
      'ui_source': 'palwakf_public_services_request_entry',
      'ui_contract_version': 'draft-2026-05-08',
    };
  }

  PwfServiceFormOption? get selectedForm {
    for (final option in formOptions) {
      if (option.titleAr == formTitleAr || option.formKey == formTitleAr)
        return option;
    }
    return null;
  }

  static String _requesterTypeKey(String label) {
    return switch (label) {
      'مؤسسة' => 'entity',
      'وحدة داخلية' => 'unit',
      'مديرية' => 'unit',
      _ => 'citizen',
    };
  }

  static String _serviceKey(String label) {
    return switch (label) {
      'طلب إفادة أو وثيقة' => 'document_certificate',
      'استفسار خدمة' => 'service_inquiry',
      'طلب عام متعلق بخدمات الأوقاف' => 'awqaf_public_service',
      'طلب مرتبط بالأوقاف' => 'awqaf_public_service',
      'ملاحظة أو بلاغ' => 'complaint_feedback',
      _ => 'general_service',
    };
  }

  static String _formKey(String label) {
    return switch (label) {
      'نموذج طلب إفادة' => 'certificate_request_v1',
      'نموذج متابعة معاملة' => 'transaction_followup_v1',
      'نموذج ملاحظة أو بلاغ' => 'feedback_notice_v1',
      _ => 'general_service_request_v1',
    };
  }
}

class PwfServiceRequestSubmitResult {
  const PwfServiceRequestSubmitResult({
    required this.trackingCode,
    required this.status,
    required this.messageAr,
    required this.rpcBacked,
  });

  final String trackingCode;
  final String status;
  final String messageAr;
  final bool rpcBacked;

  String get sourceLabelAr =>
      rpcBacked ? 'RPC / قاعدة البيانات' : 'Fallback محلي مؤقت';
}

class PwfServiceRequestTrackingResult {
  const PwfServiceRequestTrackingResult({
    required this.trackingCode,
    required this.status,
    required this.publicNote,
    required this.rpcBacked,
    required this.steps,
  });

  final String trackingCode;
  final String status;
  final String publicNote;
  final bool rpcBacked;
  final List<PwfServiceRequestTimelineStep> steps;

  String get sourceLabelAr =>
      rpcBacked ? 'RPC / قاعدة البيانات' : 'Fallback محلي مؤقت';

  factory PwfServiceRequestTrackingResult.fromRpcRow(Map<String, dynamic> row) {
    final status = (row['status'] ?? 'received').toString();
    final note = (row['public_note'] ?? 'الطلب قيد المتابعة.').toString();
    final trackingCode = (row['tracking_code'] ?? '').toString();
    return PwfServiceRequestTrackingResult(
      trackingCode: trackingCode,
      status: status,
      publicNote: note,
      rpcBacked: true,
      steps: PwfServiceRequestTimelineStep.forStatus(status),
    );
  }

  factory PwfServiceRequestTrackingResult.fallback(String trackingCode) {
    return PwfServiceRequestTrackingResult(
      trackingCode: trackingCode,
      status: 'draft_preview',
      publicNote:
          'لم يتم ربط التتبع بقاعدة البيانات بعد. هذه نتيجة fallback لتثبيت تجربة المستخدم فقط.',
      rpcBacked: false,
      steps: PwfServiceRequestTimelineStep.forStatus('triage'),
    );
  }

  factory PwfServiceRequestTrackingResult.notFound(String trackingCode) {
    return PwfServiceRequestTrackingResult(
      trackingCode: trackingCode,
      status: 'not_found',
      publicNote: 'لم يتم العثور على طلب بهذا الرقم ضمن بيئة RPC الحالية.',
      rpcBacked: true,
      steps: PwfServiceRequestTimelineStep.forStatus('not_found'),
    );
  }
}

class PwfServiceRequestTimelineStep {
  const PwfServiceRequestTimelineStep({
    required this.titleAr,
    required this.descriptionAr,
    required this.done,
  });

  final String titleAr;
  final String descriptionAr;
  final bool done;

  static List<PwfServiceRequestTimelineStep> forStatus(String status) {
    final index = switch (status) {
      'received' => 0,
      'triage' => 1,
      'under_review' => 2,
      'waiting_applicant' => 2,
      'routed' => 3,
      'closed' => 4,
      'rejected' => 4,
      'cancelled' => 4,
      'not_found' => -1,
      _ => 1,
    };

    const titles = [
      ('تم استلام الطلب', 'تم تسجيل الطلب مبدئيًا ضمن مركز الخدمات.'),
      ('قيد الفرز', 'تحديد الخدمة والنموذج والجهة المسؤولة.'),
      ('بانتظار المراجعة', 'تدقيق المرفقات وتحويل الطلب للمعالجة.'),
      (
        'الإحالة أو المعالجة',
        'إحالة الطلب إلى الجهة المختصة أو إلى مهمة تشغيلية.',
      ),
      ('الإغلاق', 'إصدار نتيجة أو إغلاق الطلب وفق الإجراء المعتمد.'),
    ];

    return [
      for (int i = 0; i < titles.length; i++)
        PwfServiceRequestTimelineStep(
          titleAr: titles[i].$1,
          descriptionAr: titles[i].$2,
          done: index >= i,
        ),
    ];
  }
}

class PwfServiceRequestQueueItem {
  const PwfServiceRequestQueueItem({
    this.id,
    required this.trackingCode,
    required this.requesterLabel,
    required this.serviceLabelAr,
    required this.formTitleAr,
    required this.status,
    required this.priority,
    required this.assignedTo,
    required this.updatedAtLabel,
    required this.rpcBacked,
  });

  final String? id;
  final String trackingCode;
  final String requesterLabel;
  final String serviceLabelAr;
  final String formTitleAr;
  final String status;
  final String priority;
  final String assignedTo;
  final String updatedAtLabel;
  final bool rpcBacked;

  String get statusLabelAr => switch (status) {
    'received' => 'مستلم',
    'triage' => 'قيد الفرز',
    'under_review' => 'قيد المراجعة',
    'waiting_applicant' => 'بانتظار المستفيد',
    'routed' => 'محال',
    'closed' => 'مغلق',
    _ => 'مسودة',
  };

  String get priorityLabelAr => switch (priority) {
    'high' => 'عالية',
    'normal' => 'عادية',
    'low' => 'منخفضة',
    _ => 'عادية',
  };

  String get sourceLabelAr =>
      rpcBacked ? 'RPC / قاعدة البيانات' : 'Fallback إداري مؤقت';

  factory PwfServiceRequestQueueItem.fromRpcRow(Map<String, dynamic> row) {
    return PwfServiceRequestQueueItem(
      id: row['id']?.toString(),
      trackingCode: (row['tracking_code'] ?? '').toString(),
      requesterLabel:
          (row['requester_label'] ?? row['requester_type'] ?? 'مستفيد')
              .toString(),
      serviceLabelAr:
          (row['service_label_ar'] ?? row['service_key'] ?? 'خدمة عامة')
              .toString(),
      formTitleAr: (row['form_title_ar'] ?? row['form_key'] ?? 'نموذج خدمة')
          .toString(),
      status: (row['status'] ?? 'received').toString(),
      priority: (row['priority'] ?? 'normal').toString(),
      assignedTo: (row['assigned_to'] ?? 'غير مخصص').toString(),
      updatedAtLabel:
          (row['updated_at_label'] ?? row['updated_at'] ?? 'غير محدد')
              .toString(),
      rpcBacked: true,
    );
  }

  static const fallback = [
    PwfServiceRequestQueueItem(
      trackingCode: 'PWF-DRAFT-1001',
      requesterLabel: 'مواطن / طلب إفادة',
      serviceLabelAr: 'طلب إفادة أو وثيقة',
      formTitleAr: 'نموذج طلب إفادة',
      status: 'triage',
      priority: 'normal',
      assignedTo: 'مركز الخدمات',
      updatedAtLabel: 'Fallback — اليوم',
      rpcBacked: false,
    ),
    PwfServiceRequestQueueItem(
      trackingCode: 'PWF-DRAFT-1002',
      requesterLabel: 'مديرية / متابعة معاملة',
      serviceLabelAr: 'استفسار خدمة',
      formTitleAr: 'نموذج متابعة معاملة',
      status: 'under_review',
      priority: 'high',
      assignedTo: 'وحدة المتابعة',
      updatedAtLabel: 'Fallback — قيد المراجعة',
      rpcBacked: false,
    ),
    PwfServiceRequestQueueItem(
      trackingCode: 'PWF-DRAFT-1003',
      requesterLabel: 'جهة خارجية / مرفقات',
      serviceLabelAr: 'طلب عام متعلق بخدمات الأوقاف',
      formTitleAr: 'نموذج طلب خدمة عامة',
      status: 'waiting_applicant',
      priority: 'normal',
      assignedTo: 'تدقيق المرفقات',
      updatedAtLabel: 'Fallback — بانتظار استكمال',
      rpcBacked: false,
    ),
  ];
}

class PwfServiceWorkflowActionResult {
  const PwfServiceWorkflowActionResult({
    required this.success,
    required this.messageAr,
    this.status,
  });

  final bool success;
  final String messageAr;
  final String? status;
}

class PwfServicesRequestRpcAdapter {
  PwfServicesRequestRpcAdapter({SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;

  SupabaseClient get _supabase => _client ?? Supabase.instance.client;

  Future<List<PwfServiceFormOption>> loadPublicForms() async {
    try {
      final result = await _supabase.rpc('rpc_services_forms_public_v1');
      final rows = _asList(result);
      final forms = rows
          .map((row) => PwfServiceFormOption.fromRpcRow(_asMap(row)))
          .where((form) => form.formKey.isNotEmpty && form.titleAr.isNotEmpty)
          .toList(growable: false);
      _emitSourceMarker(
        operation: 'public_forms_rpc_default',
        surface: PwfServiceCenterRuntimeSourceClosureContract.formsSurface,
        rows: forms.length,
      );
      return forms;
    } catch (error) {
      if (_shouldUseFallback(error)) {
        _emitFallbackMarker(
          operation: 'public_forms_rpc_default',
          surface: PwfServiceCenterRuntimeSourceClosureContract.formsSurface,
          reason: error,
        );
        return PwfServiceFormOption.fallback;
      }
      _emitSourceMarker(
        operation: 'public_forms_rpc_default_error',
        surface: PwfServiceCenterRuntimeSourceClosureContract.formsSurface,
        ownerRead: false,
        status: 'error',
      );
      return const <PwfServiceFormOption>[];
    }
  }

  Future<PwfServiceRequestSubmitResult> submitRequest(
    PwfServiceRequestSubmitDraft draft,
  ) async {
    try {
      final result = await _supabase.rpc(
        'rpc_services_submit_request_v1',
        params: {'payload': draft.toRpcPayload()},
      );
      final data = _asMap(result);
      final ok = data['ok'] != false && data['success'] != false;
      final trackingCode = (data['tracking_code'] ?? '').toString();
      if (ok && trackingCode.isNotEmpty) {
        _emitSourceMarker(
          operation: 'request_submit_rpc_default',
          surface: PwfServiceCenterRuntimeSourceClosureContract.submitSurface,
          status: (data['status'] ?? 'received').toString(),
        );
        return PwfServiceRequestSubmitResult(
          trackingCode: trackingCode,
          status: (data['status'] ?? 'received').toString(),
          messageAr:
              (data['message_ar'] ?? 'تم استلام الطلب. احتفظ برقم المتابعة.')
                  .toString(),
          rpcBacked: true,
        );
      }
      if (!ok) {
        _emitSourceMarker(
          operation: 'request_submit_rpc_rejected',
          surface: PwfServiceCenterRuntimeSourceClosureContract.submitSurface,
          status: (data['status'] ?? 'rejected').toString(),
        );
        return PwfServiceRequestSubmitResult(
          trackingCode: _localTrackingCode(),
          status: 'rejected',
          messageAr:
              (data['message_ar'] ?? 'تعذر إرسال الطلب من قاعدة البيانات.')
                  .toString(),
          rpcBacked: true,
        );
      }
    } catch (error) {
      if (_shouldUseFallback(error)) {
        _emitFallbackMarker(
          operation: 'request_submit_rpc_default',
          surface: PwfServiceCenterRuntimeSourceClosureContract.submitSurface,
          reason: error,
        );
        return PwfServiceRequestSubmitResult(
          trackingCode: _localTrackingCode(),
          status: 'draft_preview',
          messageAr:
              'تم إنشاء رقم متابعة محلي مؤقت لأن RPC غير مفعّل في قاعدة البيانات الحالية.',
          rpcBacked: false,
        );
      }
      _emitSourceMarker(
        operation: 'request_submit_rpc_default_error',
        surface: PwfServiceCenterRuntimeSourceClosureContract.submitSurface,
        ownerRead: false,
        status: 'error',
      );
      return PwfServiceRequestSubmitResult(
        trackingCode: _localTrackingCode(),
        status: 'rejected',
        messageAr: 'تعذر إرسال الطلب عبر قاعدة البيانات الحالية: $error',
        rpcBacked: true,
      );
    }

    _emitSourceMarker(
      operation: 'request_submit_rpc_empty_result',
      surface: PwfServiceCenterRuntimeSourceClosureContract.submitSurface,
      ownerRead: false,
      status: 'rejected',
    );
    return PwfServiceRequestSubmitResult(
      trackingCode: _localTrackingCode(),
      status: 'rejected',
      messageAr:
          'لم يرجع RPC رقم متابعة صالحًا. لم يتم استخدام fallback كمسار تشغيلي.',
      rpcBacked: true,
    );
  }

  Future<PwfServiceRequestTrackingResult> trackRequest(
    String trackingCode,
  ) async {
    final normalized = trackingCode.trim();
    if (normalized.isEmpty)
      return PwfServiceRequestTrackingResult.fallback('PWF-DRAFT');

    try {
      final result = await _supabase.rpc(
        'rpc_services_track_request_public_v1',
        params: {'p_tracking_code': normalized},
      );
      final rows = _asList(result);
      if (rows.isEmpty) {
        _emitSourceMarker(
          operation: 'request_tracking_rpc_not_found',
          surface: PwfServiceCenterRuntimeSourceClosureContract.trackingSurface,
          rows: 0,
          status: 'not_found',
        );
        return PwfServiceRequestTrackingResult.notFound(normalized);
      }
      final tracked = PwfServiceRequestTrackingResult.fromRpcRow(
        _asMap(rows.first),
      );
      _emitSourceMarker(
        operation: 'request_tracking_rpc_default',
        surface: PwfServiceCenterRuntimeSourceClosureContract.trackingSurface,
        rows: rows.length,
        status: tracked.status,
      );
      return tracked;
    } catch (error) {
      if (_shouldUseFallback(error)) {
        _emitFallbackMarker(
          operation: 'request_tracking_rpc_default',
          surface: PwfServiceCenterRuntimeSourceClosureContract.trackingSurface,
          reason: error,
        );
        return PwfServiceRequestTrackingResult.fallback(normalized);
      }
      _emitSourceMarker(
        operation: 'request_tracking_rpc_default_error',
        surface: PwfServiceCenterRuntimeSourceClosureContract.trackingSurface,
        ownerRead: false,
        status: 'error',
      );
      return PwfServiceRequestTrackingResult.notFound(normalized);
    }
  }

  Future<List<PwfServiceRequestQueueItem>> loadAdminQueueDraft({
    String? status,
  }) async {
    try {
      final result = await _supabase.rpc(
        'rpc_services_admin_request_queue_v1',
        params: {
          'p_status': status == null || status == 'all' ? null : status,
          'p_limit': 100,
        },
      );
      final rows = _asList(result);
      final items = rows
          .map((row) => PwfServiceRequestQueueItem.fromRpcRow(_asMap(row)))
          .where((item) => item.trackingCode.isNotEmpty)
          .toList(growable: false);
      _emitSourceMarker(
        operation: 'admin_queue_rpc_default',
        surface: PwfServiceCenterRuntimeSourceClosureContract.adminQueueSurface,
        rows: items.length,
      );
      return items;
    } catch (error) {
      if (_shouldUseFallback(error)) {
        _emitFallbackMarker(
          operation: 'admin_queue_rpc_default',
          surface:
              PwfServiceCenterRuntimeSourceClosureContract.adminQueueSurface,
          reason: error,
        );
        return PwfServiceRequestQueueItem.fallback;
      }
      _emitSourceMarker(
        operation: 'admin_queue_rpc_default_error',
        surface: PwfServiceCenterRuntimeSourceClosureContract.adminQueueSurface,
        ownerRead: false,
        status: 'error',
      );
      return const <PwfServiceRequestQueueItem>[];
    }
  }

  Future<PwfServiceWorkflowActionResult> transitionAdminRequest({
    required String trackingCode,
    required String action,
    String? publicNote,
    String? internalNote,
  }) async {
    try {
      final result = await _supabase.rpc(
        'rpc_services_admin_transition_request_v1',
        params: {
          'p_tracking_code': trackingCode,
          'p_action': action,
          'p_public_note': publicNote,
          'p_internal_note': internalNote,
        },
      );
      final data = _asMap(result);
      final success = data['success'] == true || data['ok'] == true;
      _emitSourceMarker(
        operation: 'admin_transition_rpc_default',
        surface:
            PwfServiceCenterRuntimeSourceClosureContract.adminTransitionSurface,
        status: success
            ? (data['status'] ?? 'transitioned').toString()
            : 'rejected',
      );
      return PwfServiceWorkflowActionResult(
        success: success,
        messageAr:
            (data['message_ar'] ?? data['message'] ?? 'تم تنفيذ الإجراء.')
                .toString(),
        status: data['status']?.toString(),
      );
    } catch (error) {
      _emitSourceMarker(
        operation: 'admin_transition_rpc_default_error',
        surface:
            PwfServiceCenterRuntimeSourceClosureContract.adminTransitionSurface,
        ownerRead: false,
        status: 'error',
      );
      return PwfServiceWorkflowActionResult(
        success: false,
        messageAr: 'تعذر تنفيذ الإجراء عبر قاعدة البيانات: $error',
      );
    }
  }

  static void _emitSourceMarker({
    required String operation,
    required String surface,
    int? rows,
    bool ownerRead = true,
    String? status,
  }) {
    debugPrint(
      '${PwfServiceCenterRuntimeSourceClosureContract.sourceMarker} '
      'operation=$operation owner_read=$ownerRead surface=$surface '
      'rows=${rows ?? '-'} status=${status ?? '-'} '
      'decision=${PwfServiceCenterRuntimeSourceClosureContract.ownerReadDecision}',
    );
  }

  static void _emitFallbackMarker({
    required String operation,
    required String surface,
    required Object reason,
  }) {
    final normalizedReason = _fallbackReason(reason);
    debugPrint(
      '${PwfServiceCenterRuntimeSourceClosureContract.fallbackMarker} '
      'operation=$operation fallback=true surface=$surface '
      'reason=$normalizedReason '
      'decision=${PwfServiceCenterRuntimeSourceClosureContract.fallbackDecision}',
    );
  }

  static String _fallbackReason(Object reason) {
    final message = reason.toString().toLowerCase();
    if (message.contains('could not find the function') ||
        message.contains('undefined function') ||
        message.contains('function public.')) {
      return 'rpc_missing';
    }
    if (message.contains('schema cache') ||
        message.contains('pgrst202') ||
        message.contains('pgrst204')) {
      return 'postgrest_schema_cache_or_signature_drift';
    }
    if (message.contains('undefined_table') ||
        message.contains('relation') && message.contains('does not exist')) {
      return 'platform_services_schema_missing';
    }
    return 'non_operational_preview_fallback';
  }

  static List<dynamic> _asList(dynamic value) {
    if (value is List) return value;
    if (value == null) return const [];
    return [value];
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, dynamic item) => MapEntry(key.toString(), item));
    }
    return <String, dynamic>{};
  }

  static bool _shouldUseFallback(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('could not find the function') ||
        message.contains('function public.') ||
        message.contains('does not exist') ||
        message.contains('undefined function') ||
        message.contains('undefined_table') ||
        message.contains('relation') && message.contains('does not exist') ||
        message.contains('schema cache') ||
        message.contains('pgrst202') ||
        message.contains('pgrst204');
  }

  static String _localTrackingCode() {
    final millis = DateTime.now().millisecondsSinceEpoch.toString();
    return 'PWF-DRAFT-${millis.substring(millis.length - 8)}';
  }
}
