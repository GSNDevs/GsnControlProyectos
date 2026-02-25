import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class TasksService {
  final SupabaseClient _client = Supabase.instance.client;
  final String _tableName = 'tasks';

  Future<List<Map<String, dynamic>>> getIterationTasks(
    String iterationId,
  ) async {
    return await _client
        .from(_tableName)
        .select()
        .eq('iteration_id', iterationId)
        .order('created_at');
  }

  Future<void> createTask(Map<String, dynamic> taskData) async {
    await _client.from(_tableName).insert(taskData);
  }

  Future<void> updateTask(String id, Map<String, dynamic> updates) async {
    await _client.from(_tableName).update(updates).eq('id', id);
  }

  Future<void> deleteTask(String id) async {
    await _client.from(_tableName).delete().eq('id', id);
  }

  Future<String> uploadTaskEvidence(
    String taskId,
    Uint8List fileBytes,
    String fileName,
  ) async {
    final String path =
        '$taskId/${DateTime.now().millisecondsSinceEpoch}_$fileName';
    await _client.storage
        .from('task_evidence')
        .uploadBinary(
          path,
          fileBytes,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );
    final String url = _client.storage.from('task_evidence').getPublicUrl(path);
    await updateTask(taskId, {'evidence_url': url});
    return url;
  }
}
