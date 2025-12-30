// lib/core/services/task_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:waqf/data/models/task.dart';

class TaskService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ✅ يستخدم نفس Supabase client الموجود في main.dart
  Future<List<Task>> getTasks() async {
    final data = await _supabase
        .from('tasks')
        .select('''
          *,
          cases!case_id (*),          // ✅ نفس الجدول المستخدم في CasesScreen
          waqf_lands!waqf_land_id (*) // ✅ نفس الجدول المستخدم في WaqfLandsScreen
        ''')
        .order('created_at', ascending: false);

    return data.map(Task.fromJson).toList();
  }
}