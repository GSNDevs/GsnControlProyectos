import 'package:supabase_flutter/supabase_flutter.dart';

class ProjectsService {
  final SupabaseClient _client = Supabase.instance.client;
  final String _tableName = 'projects';

  Future<List<Map<String, dynamic>>> getProjects() async {
    return await _client
        .from(_tableName)
        .select('*, project_details_physical(*), project_details_software(*)')
        .order('created_at', ascending: false);
  }

  Future<Map<String, dynamic>?> getProjectById(String id) async {
    return await _client
        .from(_tableName)
        .select('*, project_details_physical(*), project_details_software(*)')
        .eq('id', id)
        .maybeSingle();
  }

  Future<String> createProject(Map<String, dynamic> projectData) async {
    final response = await _client
        .from(_tableName)
        .insert(projectData)
        .select()
        .single();
    return response['id'] as String;
  }

  Future<void> updateProject(String id, Map<String, dynamic> updates) async {
    await _client.from(_tableName).update(updates).eq('id', id);
  }

  Future<void> deleteProject(String id) async {
    await _client.from(_tableName).delete().eq('id', id);
  }

  Future<void> createProjectDetailsPhysical(Map<String, dynamic> data) async {
    await _client.from('project_details_physical').insert(data);
  }

  Future<void> createProjectDetailsSoftware(Map<String, dynamic> data) async {
    await _client.from('project_details_software').insert(data);
  }
}
