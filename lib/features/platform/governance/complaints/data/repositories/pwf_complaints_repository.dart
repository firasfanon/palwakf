import '../models/pwf_complaint.dart';

abstract class PwfComplaintsRepository {
  Future<PwfComplaint> submitComplaint({
    required String unitSlug,
    required PwfComplaintType type,
    required PwfComplaintDepartment department,
    required String subject,
    required String description,
    required String email,
    String? name,
    String? phone,
    required int attachmentsCount,
  });

  Future<PwfComplaint?> trackByReference({
    required String unitSlug,
    required String reference,
  });

  /// Public list of suggestions (limited fields)
  Future<List<PwfComplaint>> listSuggestions({
    required String unitSlug,
    int limit = 50,
  });
}
