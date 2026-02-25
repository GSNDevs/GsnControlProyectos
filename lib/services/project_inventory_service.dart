import 'package:supabase_flutter/supabase_flutter.dart';

class ProjectInventoryService {
  final SupabaseClient _client = Supabase.instance.client;
  final String _tableName = 'project_inventory';

  Future<List<Map<String, dynamic>>> getProjectInventory(
    String projectId,
  ) async {
    return await _client
        .from(_tableName)
        .select('*, inventory_catalog(*)')
        .eq('project_id', projectId);
  }

  Future<void> assignProduct(Map<String, dynamic> assignmentData) async {
    await _client.from(_tableName).insert(assignmentData);
  }

  Future<void> updateAssignment(String id, Map<String, dynamic> updates) async {
    await _client.from(_tableName).update(updates).eq('id', id);
  }

  Future<void> removeAssignment(String id) async {
    await _client.from(_tableName).delete().eq('id', id);
  }
}
