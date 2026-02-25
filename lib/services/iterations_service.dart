import 'package:supabase_flutter/supabase_flutter.dart';

class IterationsService {
  final SupabaseClient _client = Supabase.instance.client;
  final String _tableName = 'iterations';

  Future<List<Map<String, dynamic>>> getProjectIterations(
    String projectId,
  ) async {
    return await _client
        .from(_tableName)
        .select()
        .eq('project_id', projectId)
        .order('start_date');
  }

  Future<String> createIteration(Map<String, dynamic> iterationData) async {
    final response = await _client
        .from(_tableName)
        .insert(iterationData)
        .select()
        .single();
    return response['id'] as String;
  }

  Future<void> updateIteration(String id, Map<String, dynamic> updates) async {
    await _client.from(_tableName).update(updates).eq('id', id);
  }

  Future<void> deleteIteration(String id) async {
    await _client.from(_tableName).delete().eq('id', id);
  }

  Future<Map<String, dynamic>> getIterationDetails(String id) async {
    return await _client.from(_tableName).select().eq('id', id).single();
  }
}
