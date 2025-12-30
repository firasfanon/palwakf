import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/friday_sermon.dart';

class FridaySermonsRepository {
  final SupabaseClient _client;
  FridaySermonsRepository(this._client);

  Future<List<FridaySermon>> listPublic({int limit = 50}) async {
    final res = await _client
        .from('friday_sermons')
        .select('*')
        .eq('is_published', true)
        .order('sermon_date', ascending: false)
        .limit(limit);
    return (res as List)
        .map((e) => FridaySermon.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<List<FridaySermon>> listAdmin({int limit = 200}) async {
    final res = await _client
        .from('friday_sermons')
        .select('*')
        .order('sermon_date', ascending: false)
        .limit(limit);
    return (res as List)
        .map((e) => FridaySermon.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<FridaySermon> create(FridaySermon sermon) async {
    final res = await _client
        .from('friday_sermons')
        .insert(sermon.toInsertMap())
        .select('*')
        .single();
    return FridaySermon.fromMap(Map<String, dynamic>.from(res));
  }

  Future<FridaySermon> update(String id, Map<String, dynamic> patch) async {
    final res = await _client
        .from('friday_sermons')
        .update(patch)
        .eq('id', id)
        .select('*')
        .single();
    return FridaySermon.fromMap(Map<String, dynamic>.from(res));
  }

  Future<void> delete(String id) async {
    await _client.from('friday_sermons').delete().eq('id', id);
  }
}
