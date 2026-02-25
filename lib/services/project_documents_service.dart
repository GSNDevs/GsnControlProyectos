import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProjectDocumentsService {
  final SupabaseClient _client = Supabase.instance.client;
  final String _tableName = 'project_documents';
  final String _bucketName = 'project_documents';

  Future<List<Map<String, dynamic>>> getProjectDocuments(
    String projectId,
  ) async {
    return await _client
        .from(_tableName)
        .select()
        .eq('project_id', projectId)
        .order('created_at', ascending: false);
  }

  Future<String> uploadDocument(
    String projectId,
    Uint8List fileBytes,
    String fileName,
    String fileType,
  ) async {
    // 1. Upload file to Supabase Storage
    final String path =
        '$projectId/${DateTime.now().millisecondsSinceEpoch}_$fileName';
    await _client.storage
        .from(_bucketName)
        .uploadBinary(
          path,
          fileBytes,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );

    // 2. Get public URL
    final String fileUrl = _client.storage.from(_bucketName).getPublicUrl(path);

    // 3. Insert into database
    final response = await _client
        .from(_tableName)
        .insert({
          'project_id': projectId,
          'file_name': fileName,
          'file_url': fileUrl,
          'file_type': fileType,
          // 'uploaded_by':  podríamos enviarlo si tenemos el usuario actual
        })
        .select()
        .single();

    return response['id'] as String;
  }

  Future<void> deleteDocument(String id, String fileUrl) async {
    // Para simplificar, obtenemos la ruta relativa del archivo desde la URL.
    // Esto dependerá de la estructura de URLs de Supabase, pero genéricamente:
    try {
      final uri = Uri.parse(fileUrl);
      final pathSegments = uri.pathSegments;
      // pathSegments usualmente será: [storage, v1, object, public, project_documents, projectId, fileName]
      // Solo necesitamos desde el projectId
      final bucketIndex = pathSegments.indexOf(_bucketName);
      if (bucketIndex != -1 && bucketIndex + 1 < pathSegments.length) {
        final filePath = pathSegments.sublist(bucketIndex + 1).join('/');
        await _client.storage.from(_bucketName).remove([filePath]);
      }
    } catch (e) {
      print("No se pudo eliminar de storage: $e");
    }

    await _client.from(_tableName).delete().eq('id', id);
  }
}
