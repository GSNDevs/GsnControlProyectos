import 'package:supabase_flutter/supabase_flutter.dart';

class ProjectDetailsSoftwareService {
  final SupabaseClient _client = Supabase.instance.client;
  final String _tableName = 'project_details_software';

  Future<Map<String, dynamic>?> getDetails(String projectId) async {
    return await _client
        .from(_tableName)
        .select()
        .eq('project_id', projectId)
        .maybeSingle();
  }

  Future<void> upsertDetails(Map<String, dynamic> details) async {
    await _client.from(_tableName).upsert(details);
  }

  Future<void> deleteDetails(String projectId) async {
    await _client.from(_tableName).delete().eq('project_id', projectId);
  }
}
