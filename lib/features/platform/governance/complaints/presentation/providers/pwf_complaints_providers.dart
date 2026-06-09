import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/pwf_complaint.dart';
import '../../data/repositories/pwf_complaints_repository.dart';
import '../../data/repositories/pwf_complaints_repository_impl.dart';

/// Current unit slug for this feature.
/// Default is 'home'. Override via ProviderScope in the screen or router.
final pwfComplaintsUnitSlugProvider = Provider<String>((ref) => 'home');

final pwfComplaintsRepositoryProvider = Provider<PwfComplaintsRepository>(
  (ref) => PwfComplaintsRepositoryImpl(Supabase.instance.client),
);

final pwfLastSubmittedReferenceProvider = StateProvider<String?>((ref) => null);

@immutable
class PwfSubmitResult {
  final String referenceCode;
  const PwfSubmitResult(this.referenceCode);
}

class PwfComplaintSubmitController
    extends StateNotifier<AsyncValue<PwfSubmitResult?>> {
  PwfComplaintSubmitController(this.ref) : super(const AsyncValue.data(null));
  final Ref ref;

  Future<PwfSubmitResult?> submit({
    required PwfComplaintType type,
    required PwfComplaintDepartment department,
    required String subject,
    required String description,
    required String email,
    String? name,
    String? phone,
    required int attachmentsCount,
  }) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(pwfComplaintsRepositoryProvider);
      final unitSlug = ref.read(pwfComplaintsUnitSlugProvider);

      final created = await repo.submitComplaint(
        unitSlug: unitSlug,
        type: type,
        department: department,
        subject: subject,
        description: description,
        email: email,
        name: name,
        phone: phone,
        attachmentsCount: attachmentsCount,
      );

      final result = PwfSubmitResult(created.referenceCode);
      state = AsyncValue.data(result);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  void clear() => state = const AsyncValue.data(null);
}

final pwfComplaintSubmitControllerProvider =
    StateNotifierProvider<
      PwfComplaintSubmitController,
      AsyncValue<PwfSubmitResult?>
    >((ref) => PwfComplaintSubmitController(ref));

class PwfComplaintTrackController
    extends StateNotifier<AsyncValue<PwfComplaint?>> {
  PwfComplaintTrackController(this.ref) : super(const AsyncValue.data(null));
  final Ref ref;

  Future<void> track(String reference) async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(pwfComplaintsRepositoryProvider);
      final unitSlug = ref.read(pwfComplaintsUnitSlugProvider);

      final complaint = await repo.trackByReference(
        unitSlug: unitSlug,
        reference: reference,
      );

      state = AsyncValue.data(complaint);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void clear() => state = const AsyncValue.data(null);
}

final pwfComplaintTrackControllerProvider =
    StateNotifierProvider<
      PwfComplaintTrackController,
      AsyncValue<PwfComplaint?>
    >((ref) => PwfComplaintTrackController(ref));

final pwfSuggestionsProvider = FutureProvider<List<PwfComplaint>>((ref) async {
  final repo = ref.read(pwfComplaintsRepositoryProvider);
  final unitSlug = ref.read(pwfComplaintsUnitSlugProvider);
  return repo.listSuggestions(unitSlug: unitSlug, limit: 50);
});
