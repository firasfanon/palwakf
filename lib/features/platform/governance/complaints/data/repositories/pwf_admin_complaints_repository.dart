import '../models/pwf_admin_complaint.dart';
import '../models/pwf_complaint.dart';

abstract class PwfAdminComplaintsRepository {
  Future<List<PwfAdminComplaintItem>> listComplaints({
    String? query,
    PwfComplaintStatus? status,
    int limit = 100,
  });

  Future<PwfAdminComplaintDetails?> fetchDetails({
    required String referenceCode,
  });

  /// Updates main complaint status and appends an update row.
  Future<void> setStatus({
    required String referenceCode,
    required PwfComplaintStatus status,
    required String messageKey,
  });
}
