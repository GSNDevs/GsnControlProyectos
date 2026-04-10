import 'package:supabase_flutter/supabase_flutter.dart';

class ClientsService {
  final SupabaseClient _client = Supabase.instance.client;
  final String _tableName = 'clients';

  Future<List<Map<String, dynamic>>> getClients() async {
    return await _client.from(_tableName).select().order('name', ascending: true);
  }

  Future<Map<String, dynamic>?> getClientById(String id) async {
    return await _client
        .from(_tableName)
        .select()
        .eq('id', id)
        .maybeSingle();
  }

  Future<void> createClient(Map<String, dynamic> data) async {
    await _client.from(_tableName).insert(data);
  }

  Future<void> updateClient(String id, Map<String, dynamic> updates) async {
    await _client.from(_tableName).update(updates).eq('id', id);
  }

  Future<void> deleteClient(String id) async {
    await _client.from(_tableName).delete().eq('id', id);
  }
}
