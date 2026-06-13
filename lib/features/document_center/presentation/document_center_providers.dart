
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/document_center_repository.dart';
import '../domain/document_center_models.dart';

final documentCenterRepositoryProvider = Provider<DocumentCenterRepository>((ref) {
  return DocumentCenterRepository();
});

final documentCenterDashboardProvider =
    FutureProvider.autoDispose<DocumentCenterDashboard>((ref) async {
      final repository = ref.watch(documentCenterRepositoryProvider);
      return repository.loadDashboard();
    });
