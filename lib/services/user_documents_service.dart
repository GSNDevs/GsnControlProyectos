import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserDocumentsService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getUserDocuments(String profileId) async {
    final res = await _client
        .from('user_documents')
        .select()
        .eq('profile_id', profileId);
    return List<Map<String, dynamic>>.from(res);
  }
  
  Future<List<Map<String, dynamic>>> getProjectVisibleDocuments(String projectId) async {
    // Client view: gets physical documents linked to active project members
    final members = await _client
        .from('project_members')
        .select('profile_id')
        .eq('project_id', projectId)
        .eq('is_active', true);
    
    if ((members as List).isEmpty) return [];
    
    final List<String> profileIds = members.map((m) => m['profile_id'].toString()).toList();
    
    final res = await _client
        .from('user_documents')
        .select()
        .inFilter('profile_id', profileIds)
        .eq('is_visible_to_client', true);
    return List<Map<String, dynamic>>.from(res);
  }

  Future<String> uploadDocument(Uint8List bytes, String path) async {
    await _client.storage.from('safety_documents').uploadBinary(
      path,
      bytes,
      fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
    );
    return _client.storage.from('safety_documents').getPublicUrl(path);
  }
  
  Future<void> deleteStorageDocument(String url) async {
     try {
       // Extract path from public URL
       final uri = Uri.parse(url);
       final pathSegments = uri.pathSegments;
       final index = pathSegments.indexOf('safety_documents');
       if (index != -1 && index < pathSegments.length - 1) {
          final filePath = pathSegments.sublist(index + 1).join('/');
          await _client.storage.from('safety_documents').remove([filePath]);
       }
     } catch (e) {
       // ignore
     }
  }

  Future<Map<String, dynamic>> createUserDocument(Map<String, dynamic> docData) async {
    final res = await _client
        .from('user_documents')
        .insert(docData)
        .select()
        .single();
    return res;
  }

  Future<void> updateUserDocument(String id, Map<String, dynamic> updates) async {
    updates['updated_at'] = DateTime.now().toIso8601String();
    await _client.from('user_documents').update(updates).eq('id', id);
  }

  Future<void> deleteUserDocument(String id) async {
    await _client.from('user_documents').delete().eq('id', id);
  }
}
