import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class TaskDocumentsService {
  final SupabaseClient _client = Supabase.instance.client;
  final String _tableName = 'task_documents';
  final String _bucketName = 'task_evidence';

  Future<List<Map<String, dynamic>>> getTaskDocuments(String taskId) async {
    return await _client
        .from(_tableName)
        .select()
        .eq('task_id', taskId)
        .order('created_at', ascending: false);
  }

  Future<void> uploadDocument(
    String taskId,
    Uint8List fileBytes,
    String fileName,
  ) async {
    final String path =
        '$taskId/${DateTime.now().millisecondsSinceEpoch}_$fileName';
    await _client.storage
        .from(_bucketName)
        .uploadBinary(
          path,
          fileBytes,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );
    final String url = _client.storage.from(_bucketName).getPublicUrl(path);

    await _client.from(_tableName).insert({
      'task_id': taskId,
      'file_name': fileName,
      'file_url': url,
      'uploaded_by': _client.auth.currentUser?.id,
    });
  }

  Future<void> deleteDocument(String id, String fileUrl) async {
    // Extract path from public url
    final uri = Uri.parse(fileUrl);
    final pathSegments = uri.pathSegments;
    // Format is usually /storage/v1/object/public/bucketName/itemPath
    final index = pathSegments.indexOf(_bucketName);
    if (index != -1 && index + 1 < pathSegments.length) {
      final storagePath = pathSegments.sublist(index + 1).join('/');
      await _client.storage.from(_bucketName).remove([storagePath]);
    }
    await _client.from(_tableName).delete().eq('id', id);
  }
}
