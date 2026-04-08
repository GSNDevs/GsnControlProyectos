import 'package:supabase_flutter/supabase_flutter.dart';


class ProfilesService {
  final SupabaseClient _client = Supabase.instance.client;
  final String _tableName = 'profiles';

  Future<List<Map<String, dynamic>>> getProfiles() async {
    return await _client.from(_tableName).select();
  }

  Future<Map<String, dynamic>?> getProfileById(String id) async {
    final response = await _client
        .from(_tableName)
        .select()
        .eq('id', id)
        .maybeSingle();
    return response;
  }

  Future<List<Map<String, dynamic>>> getClients() async {
    return await _client.from(_tableName).select().eq('role', 'client');
  }

  Future<void> createProfileWithAuth(
    Map<String, dynamic> data,
    String role,
  ) async {
    try {
      await _client.rpc('admin_create_user', params: {
        'input_email': data['email'] ?? '',
        'input_password': data['password'] ?? '',
        'input_full_name': data['full_name'] ?? '',
        'input_role': role,
        'input_rut': data['rut'] ?? '',
        'input_company_name': data['company_name'] ?? '',
        'input_fantasy_name': data['fantasy_name'] ?? '',
        'input_address': data['address'] ?? '',
      });
    } on PostgrestException catch (pe) {
      throw Exception(pe.message);
    } catch (e) {
      String errorMessage = "Error desconocido";
      try {
        final dynamic err = e;
        if (err.message != null) {
          errorMessage = err.message.toString();
        } else {
          errorMessage = e.toString();
        }
      } catch (_) {
        errorMessage = e.toString();
      }
      throw Exception("Error al crear usuario: $errorMessage");
    }
  }

  Future<void> updateProfile(String id, Map<String, dynamic> updates) async {
    await _client.from(_tableName).update(updates).eq('id', id);
  }
}
