import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
    // 1. Create Auth User use a SECONDARY SupabaseClient.
    // Note: This relies on flutter_dotenv being loaded in main.dart
    final url = dotenv.env['SUPABASE_URL']!;
    final key = dotenv.env['SUPABASE_ANON_KEY']!;

    final tempClient = SupabaseClient(
      url,
      key,
      authOptions: const AuthClientOptions(authFlowType: AuthFlowType.implicit),
    );

    final authResponse = await tempClient.auth.signUp(
      email: data['email'],
      password: data['password'],
      data: {'full_name': data['full_name']},
    );

    if (authResponse.user == null) {
      throw Exception("No se pudo crear el usuario de autenticación");
    }

    final newUserId = authResponse.user!.id;

    // 2. Insert/Update Profile
    final profileData = {
      'id': newUserId,
      'email': data['email'],
      'full_name': data['full_name'],
      'role': role,
      'rut': data['rut'],
      'company_name': data['company_name'],
      'fantasy_name': data['fantasy_name'],
      'address': data['address'],
      'created_at': DateTime.now().toIso8601String(),
    };

    // Upsert using the ADMIN (main) client to ensure we can write to the table
    // (Assuming the logged-in user has permission to create profiles, e.g., is admin/staff)
    await _client.from(_tableName).upsert(profileData);

    // Explicitly sign out the temp client just in case, though it shouldn't persist.
    await tempClient.dispose();
  }

  Future<void> updateProfile(String id, Map<String, dynamic> updates) async {
    await _client.from(_tableName).update(updates).eq('id', id);
  }
}
