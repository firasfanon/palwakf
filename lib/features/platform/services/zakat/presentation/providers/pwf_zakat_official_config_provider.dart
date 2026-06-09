import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/pwf_zakat_public_config_repository.dart';
import '../../domain/pwf_zakat_official_config_contract.dart';

final pwfZakatPublicConfigRepositoryProvider =
    Provider<PwfZakatPublicConfigRepository>((ref) {
      return PwfZakatPublicConfigRepository(Supabase.instance.client);
    });

final pwfZakatPublicConfigProvider = FutureProvider<PwfZakatPublicConfig>((
  ref,
) async {
  final repository = ref.watch(pwfZakatPublicConfigRepositoryProvider);
  return repository.fetchActiveConfig();
});
