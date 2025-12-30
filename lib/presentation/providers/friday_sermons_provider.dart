import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/friday_sermons_repository.dart';
import '../../data/models/friday_sermon.dart';

final fridaySermonsRepositoryProvider = Provider<FridaySermonsRepository>((ref) {
  return FridaySermonsRepository(Supabase.instance.client);
});

final publicFridaySermonsProvider = FutureProvider<List<FridaySermon>>((ref) async {
  return ref.read(fridaySermonsRepositoryProvider).listPublic();
});

final adminFridaySermonsProvider = FutureProvider<List<FridaySermon>>((ref) async {
  return ref.read(fridaySermonsRepositoryProvider).listAdmin();
});
