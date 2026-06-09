import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/pwf_admin_complaint.dart';
import '../../data/models/pwf_complaint.dart';
import '../../data/repositories/pwf_admin_complaints_repository.dart';
import '../../data/repositories/pwf_admin_complaints_repository_impl.dart';

final pwfAdminComplaintsRepositoryProvider =
    Provider<PwfAdminComplaintsRepository>(
      (ref) => PwfAdminComplaintsRepositoryImpl(Supabase.instance.client),
    );

class PwfAdminComplaintsFilter {
  final String query;
  final PwfComplaintStatus? status;

  const PwfAdminComplaintsFilter({this.query = '', this.status});

  PwfAdminComplaintsFilter copyWith({
    String? query,
    PwfComplaintStatus? status,
    bool clearStatus = false,
  }) {
    return PwfAdminComplaintsFilter(
      query: query ?? this.query,
      status: clearStatus ? null : (status ?? this.status),
    );
  }
}

final pwfAdminComplaintsFilterProvider =
    StateProvider<PwfAdminComplaintsFilter>(
      (ref) => const PwfAdminComplaintsFilter(),
    );

final pwfAdminComplaintsListProvider =
    FutureProvider.autoDispose<List<PwfAdminComplaintItem>>((ref) async {
      final repo = ref.read(pwfAdminComplaintsRepositoryProvider);
      final f = ref.watch(pwfAdminComplaintsFilterProvider);
      return repo.listComplaints(query: f.query, status: f.status, limit: 150);
    });

final pwfAdminComplaintDetailsProvider = FutureProvider.autoDispose
    .family<PwfAdminComplaintDetails?, String>((ref, refCode) async {
      final repo = ref.read(pwfAdminComplaintsRepositoryProvider);
      return repo.fetchDetails(referenceCode: refCode);
    });
