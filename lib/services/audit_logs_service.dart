import 'package:supabase_flutter/supabase_flutter.dart';

class AuditLogsService {
  final SupabaseClient _client = Supabase.instance.client;
  final String _tableName = 'audit_logs';

  Future<void> logAction({
    required String tableName,
    required String action,
    String? recordId,
    Map<String, dynamic>? oldValue,
    Map<String, dynamic>? newValue,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    await _client.from(_tableName).insert({
      'user_id': user.id,
      'table_name': tableName,
      'record_id': recordId,
      'action': action,
      'old_value': oldValue,
      'new_value': newValue,
    });
  }

  Future<List<Map<String, dynamic>>> getLogs({int limit = 50}) async {
    return await _client
        .from(_tableName)
        .select()
        .order('timestamp', ascending: false)
        .limit(limit);
  }
}
