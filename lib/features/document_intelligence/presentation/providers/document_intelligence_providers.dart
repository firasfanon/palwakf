import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/document_intelligence_models.dart';
import '../../data/repositories/document_intelligence_repository.dart';
import '../../data/services/document_processing_engine_adapter.dart';

const String _documentEngineMode = String.fromEnvironment(
  'PWF_DOCUMENT_ENGINE_MODE',
  defaultValue: 'local_review',
);

const String _documentEngineRpcName = String.fromEnvironment(
  'PWF_DOCUMENT_ENGINE_RPC_NAME',
  defaultValue: 'rpc_document_engine_process_v1',
);

final documentProcessingEngineAdapterProvider =
    Provider<PwfDocumentProcessingEngineAdapter>((ref) {
      if (_documentEngineMode == 'supabase_rpc') {
        return PwfSupabaseRpcDocumentProcessingEngineAdapter(
          client: Supabase.instance.client,
          rpcName: _documentEngineRpcName,
        );
      }
      return const PwfLocalReviewDocumentProcessingEngineAdapter();
    });

final documentIntelligenceRepositoryProvider =
    Provider<DocumentIntelligenceRepository>((ref) {
      return DocumentIntelligenceRepository(
        processingEngineAdapter: ref.watch(
          documentProcessingEngineAdapterProvider,
        ),
      );
    });

final documentDashboardMetricsProvider =
    FutureProvider.autoDispose<DocumentDashboardMetrics>((ref) async {
      final repo = ref.watch(documentIntelligenceRepositoryProvider);
      return repo.getDashboardMetrics();
    });

final documentProductionReadinessProvider =
    FutureProvider.autoDispose<List<DocumentProductionReadinessItem>>((
      ref,
    ) async {
      final repo = ref.watch(documentIntelligenceRepositoryProvider);
      return repo.listProductionReadiness();
    });

final documentJobsProvider =
    FutureProvider.autoDispose<List<DocumentJobSummary>>((ref) async {
      final repo = ref.watch(documentIntelligenceRepositoryProvider);
      return repo.listJobs();
    });

final documentReviewQueueProvider =
    FutureProvider.autoDispose<List<DocumentJobSummary>>((ref) async {
      final repo = ref.watch(documentIntelligenceRepositoryProvider);
      return repo.listJobs(status: DocumentJobStatus.needsReview);
    });

final documentFileTypeUatCoverageProvider =
    FutureProvider.autoDispose<List<DocumentFileTypeUatCoverage>>((ref) async {
      final repo = ref.watch(documentIntelligenceRepositoryProvider);
      return repo.listFileTypeUatCoverage();
    });

final documentJobDetailProvider = FutureProvider.autoDispose
    .family<DocumentJobDetail, String>((ref, jobId) async {
      final repo = ref.watch(documentIntelligenceRepositoryProvider);
      return repo.getJobDetail(jobId);
    });

final documentCandidateLinksProvider = FutureProvider.autoDispose
    .family<List<DocumentCandidateLink>, String>((ref, jobId) async {
      final repo = ref.watch(documentIntelligenceRepositoryProvider);
      return repo.getCandidateLinks(jobId);
    });
