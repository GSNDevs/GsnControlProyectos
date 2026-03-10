import 'package:supabase_flutter/supabase_flutter.dart';

class ProjectMembersService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getProjectMembers(String projectId) async {
    final res = await _client
        .from('project_members')
        .select()
        .eq('project_id', projectId);
    return List<Map<String, dynamic>>.from(res);
  }

  Future<String> addProjectMember(String projectId, String profileId) async {
    final res = await _client
        .from('project_members')
        .insert({
          'project_id': projectId,
          'profile_id': profileId,
          'is_active': true,
        })
        .select('id')
        .single();
    return res['id'] as String;
  }

  Future<void> updateProjectMember(String id, Map<String, dynamic> updates) async {
    await _client.from('project_members').update(updates).eq('id', id);
  }

  Future<void> removeProjectMember(String id) async {
    // Note: The logic handles if it should soft delete or hard delete in the controller.
    // This just exposes the hard delete for specific cases.
    await _client.from('project_members').delete().eq('id', id);
  }
}
